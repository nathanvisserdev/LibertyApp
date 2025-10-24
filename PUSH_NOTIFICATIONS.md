# Push Notification Implementation Summary

## Overview
This implementation adds full push notification support for connection requests in the Liberty Social app. When a user receives a new connection request, they get an APNs notification and a badge appears on the connections tab icon.

## Backend Changes

### 1. Database Schema (`prisma/schema.prisma`)
Added two new components to the Users model:
- `DeviceToken` model: Stores device tokens for push notifications
  - `id`: Unique identifier
  - `userId`: Foreign key to Users
  - `token`: APNs device token (unique)
  - `platform`: "ios" or "android"
  - `createdAt`, `updatedAt`: Timestamps

- `pendingRequestCount` field on Users: Tracks number of unread connection requests

### 2. Push Notification Service (`src/pushNotifications.ts`)
Created service using `@parse/node-apn` library:
- `sendConnectionNotification(userId)`: Sends push notification and increments pending count
- `resetPendingRequestCount(userId)`: Resets count to 0 when user views requests
- Handles APNs configuration using P8 key authentication
- Automatically removes invalid device tokens (status 410)

### 3. Device Registration Endpoints (`src/devices.ts`)
- `POST /devices/register`: Register device token for push notifications
  - Body: `{ token: string, platform: "ios" | "android" }`
  - Upserts device token in database
  
- `DELETE /devices/unregister`: Remove device token on logout
  - Body: `{ token: string }`
  - Deletes token from database

- `GET /devices/pending-count`: Get current pending request count
  - Returns: `{ pendingRequestCount: number }`

### 4. Connection Request Integration (`src/connections.ts`)
- Updated `POST /connections/request` to call `sendConnectionNotification()`
- Updated `GET /connections/pending/incoming` to reset pending count when viewed

## iOS Changes

### 1. Push Notification Manager (`Services/PushNotificationManager.swift`)
Singleton service that handles all push notification logic:
- `requestAuthorization()`: Requests permission from user
- `didRegisterForRemoteNotifications()`: Handles successful token registration
- `registerDeviceWithBackend()`: Sends token to backend API
- `unregisterDevice()`: Removes token from backend on logout
- `didReceiveRemoteNotification()`: Processes incoming notifications
  - Sets `UserDefaults` flag for badge display
  - Updates app badge count
  - Posts local notification for UI updates

### 2. App Delegate (`App/AppDelegate.swift`)
Implements `UIApplicationDelegate` and `UNUserNotificationCenterDelegate`:
- Requests push permission on app launch
- Handles APNs registration callbacks
- Processes notifications in all app states (foreground, background, terminated)
- Shows notifications even when app is in foreground

### 3. App Integration (`App/LibertySocialApp.swift`)
- Added `@UIApplicationDelegateAdaptor` to connect AppDelegate

### 4. Tab Bar Updates (`Presentation/Components/TabBar/`)
**TabBarView.swift:**
- Changed from `@State` to `@AppStorage("newConnectionRequest")` for persistent badge state
- Added red bell icon badge when `newConnectionRequest = true`
- Listens to `NotificationCenter` for real-time badge updates
- Clears badge when user opens connection requests view

**TabBarViewModel.swift:**
- Added `isShowingConnectionRequests` state
- Added `showConnectionRequests()` and `hideConnectionRequests()` methods

### 5. Connection Requests View (`Presentation/Features/Connections/ConnectionRequestsView.swift`)
New view to display pending connection requests:
- Shows list of incoming requests with user info
- Displays request type (acquaintance, stranger, follow)
- Automatically clears badge when opened
- Calls backend to fetch requests and reset pending count

### 6. Session Management (`App/Session/SessionStore.swift`)
Updated logout flow:
- Calls `PushNotificationManager.unregisterDevice()`
- Clears `newConnectionRequest` from UserDefaults
- Removes auth token from keychain

## Environment Variables Required

Add to `.env` file:
```
APN_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
APN_KEY_ID=XXXXXXXXXX
APN_TEAM_ID=XXXXXXXXXX
APN_BUNDLE_ID=com.libertysocial.app
```

## Notification Payload Structure

```json
{
  "aps": {
    "alert": {
      "title": "New Connection Request",
      "body": "Someone wants to connect with you!"
    },
    "badge": 1,
    "sound": "default",
    "content-available": 1
  },
  "type": "connection_request"
}
```

## User Flow

1. **App Launch:**
   - App requests push permission
   - If granted, registers with APNs
   - Sends device token to backend

2. **Connection Request Sent:**
   - Backend increments `pendingRequestCount` for recipient
   - Sends push notification with badge count
   - Notification appears on device

3. **Notification Received:**
   - Sets `newConnectionRequest = true` in UserDefaults
   - Red bell badge appears on connections tab icon
   - Badge persists across app launches

4. **User Opens Requests:**
   - Opens ConnectionRequestsView
   - Backend resets `pendingRequestCount` to 0
   - Badge cleared from tab icon
   - Lists all pending requests

5. **User Logs Out:**
   - Device token removed from backend
   - Badge state cleared locally
   - Will re-register on next login

## Testing Notes

- Push notifications require a physical iOS device (not simulator)
- Requires Apple Developer account with push notification capability enabled
- Need to generate APNs P8 key from Apple Developer portal
- Test in both foreground and background app states
- Verify badge appears/disappears correctly
- Check that logout properly unregisters device

## Security Considerations

- Device tokens are unique per device and tied to authenticated users
- Tokens automatically removed when invalid (410 status)
- Backend validates auth token before sending notifications
- Sensitive user data not included in notification payload
- Connection request details only fetched when user opens requests view
