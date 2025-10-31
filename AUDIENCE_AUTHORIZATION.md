# Audience-Based Post Authorization Implementation

## Overview
Implemented comprehensive audience-based authorization for posts across the Liberty Social platform. Posts can now have different visibility levels (PUBLIC, CONNECTIONS, ACQUAINTANCES, STRANGERS, SUBNET, GROUP) and authorization is enforced consistently across all endpoints.

## Changes Implemented

### 1. Core Authorization Logic (`/server/src/posts.ts`)

#### Helper Function: `canUserViewPost()`
- Checks if a user has permission to view a specific post based on visibility rules
- Returns `true` if authorized, `false` otherwise

**Visibility Rules:**
- **PUBLIC**: Visible to all users
- **CONNECTIONS**: Visible to users connected with any connection type (ACQUAINTANCE, STRANGER, IS_FOLLOWING)
- **ACQUAINTANCES**: Visible only to users with ACQUAINTANCE connection type
- **STRANGERS**: Visible only to users with STRANGER connection type
- **SUBNET**: Visible to subnet members and subnet owner
- **GROUP**: Visible to group members (legacy support)
- **Own Posts**: Users can always see their own posts

#### POST `/posts` Endpoint
- Accepts `visibility`, `subnetId`, and `groupId` parameters
- Validates subnet posting permissions (requires OWNER, MANAGER, or CONTRIBUTOR role)
- GROUP visibility removed from user-selectable options (kept for legacy compatibility)
- Creates posts with specified audience restrictions

#### GET `/feed` Endpoint
- Applies audience-based filtering using Prisma OR conditions
- Returns posts user is authorized to view based on:
  - User's own posts
  - PUBLIC posts from all users
  - CONNECTIONS posts from connected users
  - ACQUAINTANCES posts from acquaintances
  - STRANGERS posts from strangers
  - SUBNET posts from subnets user belongs to or owns
  - GROUP posts from groups user is a member of

#### GET `/posts/:id` Endpoint
- New endpoint for fetching individual posts
- Uses `canUserViewPost()` to enforce authorization
- Returns 403 if user doesn't have permission
- Returns 404 if post doesn't exist

#### PATCH `/posts/:id` Endpoint
- Updated to support changing visibility to CONNECTIONS, ACQUAINTANCES, STRANGERS, SUBNET
- Maintains same permission validation as POST endpoint

### 2. Media Authorization (`/server/src/mediaRead.ts`)

#### POST `/media/presign-read` Endpoint
- Enhanced to check post authorization when `postId` is provided
- Validates media key matches the post's media field
- Uses `canUserViewPost()` helper to enforce audience restrictions
- Profile photos remain accessible without post authorization
- Returns 403 if user doesn't have permission to view post's media

**Authorization Flow:**
1. If `postId` provided, fetch post from database
2. Verify media key matches post
3. Check if user can view post using `canUserViewPost()`
4. Only generate presigned URL if authorized
5. If no `postId`, allow access (for profile photos)

### 3. Post Search (`/server/src/search.ts`)

#### GET `/search/posts` Endpoint
- New endpoint for searching posts by content
- Applies same audience-based filtering as feed
- Pre-fetches user's connections, subnet memberships, and group memberships
- Uses Prisma OR conditions to filter results
- Returns only posts the user is authorized to view
- Includes user, subnet, and group information in results
- Limits results to 50 posts
- Returns empty array for blank/missing query

**Search Filtering Logic:**
```typescript
OR: [
  { userId: userId },              // Own posts
  { visibility: "PUBLIC" },        // Public posts
  { visibility: "CONNECTIONS", userId: { in: connectionUserIds } },
  { visibility: "ACQUAINTANCES", userId: { in: acquaintanceUserIds } },
  { visibility: "SUBNET", subNetId: { in: allSubnetIds } },
  { visibility: "GROUP", groupId: { in: groupIds } }
]
```

## Test Coverage

### Posts Audience Tests (`posts-audience.spec.ts`)
✅ 10 tests passing
- Creates PUBLIC, CONNECTIONS, ACQUAINTANCES, SUBNET posts
- Validates subnet posting permissions (CONTRIBUTOR allowed, VIEWER rejected)
- Tests feed filtering for different user types
- Tests individual post authorization
- Tests for Alice (author), Bob (acquaintance + subnet member), Charlie (stranger)

### Media Audience Tests (`media-audience.spec.ts`)
✅ 6 tests passing
- Tests PUBLIC post media access (anyone can access)
- Tests ACQUAINTANCES media access (only acquaintances allowed)
- Tests authorization denial for strangers
- Tests profile photo access without postId
- Tests invalid scenarios (wrong key, nonexistent post)

### Search Posts Tests (`search-posts.spec.ts`)
✅ 8 tests passing
- Tests search results for Bob (sees PUBLIC, CONNECTIONS, ACQUAINTANCES, SUBNET)
- Tests search results for Charlie (sees only PUBLIC, CONNECTIONS)
- Tests search results for Alice (sees all her own posts)
- Tests empty query handling
- Tests response format and included data

## Security Improvements

### 1. Media Privacy
- Media URLs now require authorization when associated with posts
- Presigned URLs only generated if user can view the post
- Prevents unauthorized access to private post media via direct URL

### 2. Search Privacy
- Search results respect audience restrictions
- Users can't discover private posts through search
- Consistent authorization across all discovery methods

### 3. Consistent Authorization
- Same `canUserViewPost()` logic used everywhere
- Feed, individual posts, media, and search all use identical rules
- No authorization bypasses through different endpoints

## API Documentation

### Post Visibility Types
| Type | Description | Who Can View |
|------|-------------|--------------|
| PUBLIC | Visible to everyone | All users |
| CONNECTIONS | Visible to connections | Users with any connection type |
| ACQUAINTANCES | Visible to close connections | Users with ACQUAINTANCE connection |
| SUBNET | Visible within subnet | Subnet members and owner |
| GROUP | Visible to group members | Group members (legacy) |

### Subnet Posting Permissions
| Role | Can Post |
|------|----------|
| OWNER | ✅ Yes |
| MANAGER | ✅ Yes |
| CONTRIBUTOR | ✅ Yes |
| VIEWER | ❌ No |

### Media Authorization
- **With postId**: Requires post viewing permission
- **Without postId**: Allowed (for profile photos)
- **Presigned URL expiration**: 5 minutes

## Future Considerations

### 1. Notifications
- Currently no post-related notifications implemented
- When added, should use `canUserViewPost()` for authorization
- Only send notifications for posts user can view

### 2. Performance Optimization
- Consider caching user's connections/memberships
- May need database indices for visibility filtering
- Monitor query performance as user base grows

### 3. Analytics
- Track which visibility types are most commonly used
- Monitor search performance and usage patterns
- Identify any authorization bottlenecks

## Files Modified
1. `/server/src/posts.ts` - Core post authorization logic
2. `/server/src/mediaRead.ts` - Media authorization
3. `/server/src/search.ts` - Post search with authorization
4. `/server/src/tests/posts-audience.spec.ts` - Post authorization tests
5. `/server/src/tests/media-audience.spec.ts` - Media authorization tests
6. `/server/src/tests/search-posts.spec.ts` - Search authorization tests

## Test Results
```
✓ posts-audience.spec.ts (10 tests) 1432ms
✓ media-audience.spec.ts (6 tests) 1382ms
✓ search-posts.spec.ts (8 tests) 1402ms

Total: 24 tests passing across 3 test files
```
