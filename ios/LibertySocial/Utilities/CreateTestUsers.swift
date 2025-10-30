//
//  CreateTestUsers.swift
//  LibertySocial
//
//  Created for testing purposes - quickly creates test users after DB wipe
//

import Foundation

struct TestUsersResult {
    let success: Bool
    let message: String
}

struct TestUserData {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let username: String
    let dateOfBirth: String
    let gender: String
    let isPrivate: Bool
    let profilePhoto: String
    let about: String?
}

class CreateTestUsers {
    static let testUsers: [TestUserData] = [
        TestUserData(
            firstName: "John",
            lastName: "Smith",
            email: "john@smith.com",
            password: "Password1",
            username: "JohnSmith",
            dateOfBirth: "1985-03-15",
            gender: "MALE",
            isPrivate: true,
            profilePhoto: "https://i.pravatar.cc/150?img=12",
            about: "Passionate about technology and innovation. Always learning something new and sharing knowledge with others."
        ),
        TestUserData(
            firstName: "Billy",
            lastName: "Bob",
            email: "billy@bob.com",
            password: "Password1",
            username: "BillyBob",
            dateOfBirth: "1992-07-22",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=33",
            about: "Outdoor enthusiast and adventure seeker. Love hiking, camping, and exploring new trails on the weekends."
        ),
        TestUserData(
            firstName: "Harry",
            lastName: "Truman",
            email: "harry@truman.com",
            password: "Password1",
            username: "HarryTruman",
            dateOfBirth: "1988-11-08",
            gender: "MALE",
            isPrivate: true,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Harry_S_Truman_-_NARA_-_530677_%282%29.jpg/440px-Harry_S_Truman_-_NARA_-_530677_%282%29.jpg",
            about: "History buff and lifelong learner. Enjoy reading biographies and discussing political philosophy over coffee."
        ),
        TestUserData(
            firstName: "Jane",
            lastName: "Doe",
            email: "jane@doe.com",
            password: "Password1",
            username: "JaneDoe",
            dateOfBirth: "1995-05-20",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=47",
            about: "Creative designer and artist. Passionate about visual storytelling and creating meaningful user experiences."
        ),
        TestUserData(
            firstName: "Jack",
            lastName: "Johnson",
            email: "jack@johnson.com",
            password: "Password1",
            username: "JackJohnson",
            dateOfBirth: "1990-09-14",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Jack_Johnson_playing_guitar_%28cropped%29.jpg/440px-Jack_Johnson_playing_guitar_%28cropped%29.jpg",
            about: "Music lover and guitar enthusiast. Always jamming and looking for the next great concert to attend."
        ),
        TestUserData(
            firstName: "John",
            lastName: "Doe",
            email: "john@doe.com",
            password: "Password1",
            username: "JohnDoe",
            dateOfBirth: "1987-12-03",
            gender: "MALE",
            isPrivate: true,
            profilePhoto: "https://i.pravatar.cc/150?img=68",
            about: "Software engineer and problem solver. Enjoy building things that make people's lives easier."
        ),
        TestUserData(
            firstName: "Dave",
            lastName: "Chappelle",
            email: "dave@chappelle.com",
            password: "Password1",
            username: "DaveChappelle",
            dateOfBirth: "1973-08-24",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Dave_Chappelle_2017.jpg/440px-Dave_Chappelle_2017.jpg",
            about: "Comedian and storyteller. Love making people laugh and sharing perspectives on life."
        ),
        TestUserData(
            firstName: "John",
            lastName: "Kennedy",
            email: "john@kennedy.com",
            password: "Password1",
            username: "JohnKennedy",
            dateOfBirth: "1985-05-29",
            gender: "MALE",
            isPrivate: true,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/John_F._Kennedy%2C_White_House_color_photo_portrait.jpg/440px-John_F._Kennedy%2C_White_House_color_photo_portrait.jpg",
            about: "Public servant and history enthusiast. Believe in the power of community and civic engagement."
        ),
        TestUserData(
            firstName: "Tom",
            lastName: "Brady",
            email: "tom@brady.com",
            password: "Password1",
            username: "TomBrady",
            dateOfBirth: "1977-08-03",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Tom_Brady_2021.jpg/440px-Tom_Brady_2021.jpg",
            about: "Athlete and competitor. Passionate about fitness, discipline, and striving for excellence in everything."
        )
    ]
    
    static func createAllUsers() async -> TestUsersResult {
        print("🚀 Starting to create test users...")
        print("   Server: \(AppConfig.baseURL.absoluteString)")
        
        // First, verify server is reachable
        print("🔍 Checking server connection...")
        let serverReachable = await checkServerConnection()
        if !serverReachable {
            let message = "❌ Cannot reach server at \(AppConfig.baseURL.absoluteString). Make sure the server is running."
            print(message)
            return TestUsersResult(success: false, message: message)
        }
        print("✅ Server is reachable")
        
        var successCount = 0
        var failedUsers: [String] = []
        var userTokens: [String: String] = [:] // Store tokens for each user
        
        for (index, user) in testUsers.enumerated() {
            let (success, token) = await createUser(user, index: index + 1)
            if success, let token = token {
                successCount += 1
                userTokens[user.email] = token
            } else {
                failedUsers.append(user.username)
            }
        }
        
        let totalUsers = testUsers.count
        
        if successCount == totalUsers {
            // Set up connection requests
            await setupConnectionRequests(userTokens: userTokens)
            
            let message = "✅ Successfully created all \(totalUsers) test users and set up connections!"
            print(message)
            return TestUsersResult(success: true, message: message)
        } else if successCount > 0 {
            let message = "⚠️ Created \(successCount)/\(totalUsers) users. Failed: \(failedUsers.joined(separator: ", "))"
            print(message)
            return TestUsersResult(success: false, message: message)
        } else {
            let message = "❌ Failed to create any test users. Check server connection."
            print(message)
            return TestUsersResult(success: false, message: message)
        }
    }
    
    private static func setupConnectionRequests(userTokens: [String: String]) async {
        print("\n🔗 Setting up connection requests...")
        
        guard let billyToken = userTokens["billy@bob.com"],
              let harryToken = userTokens["harry@truman.com"],
              let janeToken = userTokens["jane@doe.com"],
              let johnSmithToken = userTokens["john@smith.com"],
              let jackToken = userTokens["jack@johnson.com"],
              let johnDoeToken = userTokens["john@doe.com"],
              let daveToken = userTokens["dave@chappelle.com"],
              let jfkToken = userTokens["john@kennedy.com"],
              let tomToken = userTokens["tom@brady.com"] else {
            print("❌ Missing user tokens for connection setup")
            return
        }
        
        // Get all user IDs
        guard let johnSmithUserId = await getUserId(token: johnSmithToken) else {
            print("❌ Failed to get John Smith's user ID")
            return
        }
        
        guard let billyUserId = await getUserId(token: billyToken) else {
            print("❌ Failed to get Billy Bob's user ID")
            return
        }
        
        guard let harryUserId = await getUserId(token: harryToken) else {
            print("❌ Failed to get Harry Truman's user ID")
            return
        }
        
        guard let janeUserId = await getUserId(token: janeToken) else {
            print("❌ Failed to get Jane Doe's user ID")
            return
        }
        
        guard let jackUserId = await getUserId(token: jackToken) else {
            print("❌ Failed to get Jack Johnson's user ID")
            return
        }
        
        guard let johnDoeUserId = await getUserId(token: johnDoeToken) else {
            print("❌ Failed to get John Doe's user ID")
            return
        }
        
        guard let daveUserId = await getUserId(token: daveToken) else {
            print("❌ Failed to get Dave Chappelle's user ID")
            return
        }
        
        guard let jfkUserId = await getUserId(token: jfkToken) else {
            print("❌ Failed to get John Kennedy's user ID")
            return
        }
        
        guard let tomUserId = await getUserId(token: tomToken) else {
            print("❌ Failed to get Tom Brady's user ID")
            return
        }
        
        // Track which requests were successfully sent to John Smith
        var sentRequestsToJohnSmith: [String: (userId: String, type: String, name: String)] = [:]
        
        // Billy Bob sends ACQUAINTANCE request to John Smith
        if await sendConnectionRequest(
            token: billyToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Billy Bob"
        ) {
            sentRequestsToJohnSmith[billyUserId] = (billyUserId, "ACQUAINTANCE", "Billy Bob")
        }
        
        // Harry Truman sends STRANGER request to John Smith
        if await sendConnectionRequest(
            token: harryToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "Harry Truman"
        ) {
            sentRequestsToJohnSmith[harryUserId] = (harryUserId, "STRANGER", "Harry Truman")
        }
        
        // Jane Doe sends FOLLOW request to John Smith
        if await sendConnectionRequest(
            token: janeToken,
            requestedId: johnSmithUserId,
            type: "FOLLOW",
            senderName: "Jane Doe"
        ) {
            sentRequestsToJohnSmith[janeUserId] = (janeUserId, "FOLLOW", "Jane Doe")
        }
        
        // Jack Johnson sends ACQUAINTANCE request to John Smith
        if await sendConnectionRequest(
            token: jackToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Jack Johnson"
        ) {
            sentRequestsToJohnSmith[jackUserId] = (jackUserId, "ACQUAINTANCE", "Jack Johnson")
        }
        
        // John Doe sends STRANGER request to John Smith
        if await sendConnectionRequest(
            token: johnDoeToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "John Doe"
        ) {
            sentRequestsToJohnSmith[johnDoeUserId] = (johnDoeUserId, "STRANGER", "John Doe")
        }
        
        // Dave Chappelle sends ACQUAINTANCE request to John Smith
        if await sendConnectionRequest(
            token: daveToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Dave Chappelle"
        ) {
            sentRequestsToJohnSmith[daveUserId] = (daveUserId, "ACQUAINTANCE", "Dave Chappelle")
        }
        
        // John Kennedy sends STRANGER request to John Smith
        if await sendConnectionRequest(
            token: jfkToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "John Kennedy"
        ) {
            sentRequestsToJohnSmith[jfkUserId] = (jfkUserId, "STRANGER", "John Kennedy")
        }
        
        // Tom Brady sends ACQUAINTANCE request to John Smith
        if await sendConnectionRequest(
            token: tomToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Tom Brady"
        ) {
            sentRequestsToJohnSmith[tomUserId] = (tomUserId, "ACQUAINTANCE", "Tom Brady")
        }
        
        // Wait a moment for requests to settle
        print("\n⏳ Waiting for requests to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Get John Smith's pending requests
        print("\n📥 Fetching John Smith's pending connection requests...")
        guard let pendingRequestsJohnSmith = await getPendingRequests(token: johnSmithToken) else {
            print("❌ Failed to get John Smith's pending requests")
            return
        }
        
        print("   Found \(pendingRequestsJohnSmith.count) pending request(s) for John Smith")
        
        // John Smith accepts specific requests
        print("\n✋ Processing John Smith's acceptances...")
        for request in pendingRequestsJohnSmith {
            if let requesterId = request["requesterId"] as? String,
               let requestId = request["id"] as? String,
               let senderInfo = sentRequestsToJohnSmith[requesterId] {
                
                // Accept all ACQUAINTANCE requests (Billy, Jack, Dave, Tom)
                if senderInfo.type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                // Accept Jane's FOLLOW request
                else if senderInfo.type == "FOLLOW" {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                // Accept STRANGER requests from John Doe and John Kennedy
                else if senderInfo.type == "STRANGER" && (senderInfo.name == "John Doe" || senderInfo.name == "John Kennedy") {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                // Leave Harry's STRANGER request pending (do nothing)
                else if senderInfo.type == "STRANGER" && senderInfo.name == "Harry Truman" {
                    print("⏸️  Leaving STRANGER request from \(senderInfo.name) pending")
                }
            }
        }
        
        // Wait for acceptances to settle
        print("\n⏳ Waiting for acceptances to settle...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Now set up John Doe -> Jane Doe connection
        print("\n🔗 Setting up John Doe -> Jane Doe connection...")
        
        // John Doe sends ACQUAINTANCE request to Jane Doe
        let johnDoeToJaneSuccess = await sendConnectionRequest(
            token: johnDoeToken,
            requestedId: janeUserId,
            type: "ACQUAINTANCE",
            senderName: "John Doe to Jane Doe"
        )
        
        if johnDoeToJaneSuccess {
            // Wait for request to settle
            print("⏳ Waiting for John Doe's request to settle...")
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Get Jane's pending requests
            print("📥 Fetching Jane Doe's pending connection requests...")
            guard let pendingRequestsJane = await getPendingRequests(token: janeToken) else {
                print("❌ Failed to get Jane Doe's pending requests")
                return
            }
            
            print("   Found \(pendingRequestsJane.count) pending request(s) for Jane Doe")
            
            // Jane accepts John Doe's request
            print("✋ Processing Jane Doe's acceptances...")
            for request in pendingRequestsJane {
                if let requesterId = request["requesterId"] as? String,
                   let requestId = request["id"] as? String,
                   requesterId == johnDoeUserId {
                    await acceptConnectionRequest(token: janeToken, requestId: requestId, senderName: "John Doe")
                    break
                }
            }
        }
        
        print("\n✅ Connection setup complete!")
    }
    
    private static func getUserId(token: String) async -> String? {
        let url = AppConfig.baseURL.appendingPathComponent("user/me")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let userId = json["id"] as? String {
                return userId
            }
        } catch {
            print("❌ Error getting user ID: \(error.localizedDescription)")
        }
        return nil
    }
    
    private static func sendConnectionRequest(token: String, requestedId: String, type: String, senderName: String) async -> Bool {
        let url = AppConfig.baseURL.appendingPathComponent("connections/request")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestData: [String: Any] = [
            "requestedId": requestedId,
            "requestType": type
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ \(senderName) sent \(type) request to John Smith")
                return true
            } else {
                print("❌ Failed to send \(type) request from \(senderName)")
                return false
            }
        } catch {
            print("❌ Error sending connection request from \(senderName): \(error.localizedDescription)")
            return false
        }
    }
    
    private static func getPendingRequests(token: String) async -> [[String: Any]]? {
        let url = AppConfig.baseURL.appendingPathComponent("connections/pending/incoming")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let requests = json["incomingRequests"] as? [[String: Any]] {
                        return requests
                    } else {
                        print("   Failed to parse JSON response")
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("   Response: \(responseString)")
                        }
                    }
                } else {
                    print("   HTTP \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Response: \(responseString)")
                    }
                }
            }
        } catch {
            print("   Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    private static func acceptConnectionRequest(token: String, requestId: String, senderName: String) async {
        let url = AppConfig.baseURL.appendingPathComponent("connections/\(requestId)/accept")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ John Smith accepted request from \(senderName)")
            } else {
                print("❌ Failed to accept request from \(senderName)")
            }
        } catch {
            print("❌ Error accepting request from \(senderName): \(error.localizedDescription)")
        }
    }
    
    private static func checkServerConnection() async -> Bool {
        // Try to reach the base URL health endpoint or just the base URL
        let url = AppConfig.baseURL
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5 // 5 second timeout
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                // Any response from the server means it's reachable
                return httpResponse.statusCode < 500
            }
            return false
        } catch {
            print("   Server connection error: \(error.localizedDescription)")
            return false
        }
    }
    
    private static func createUser(_ user: TestUserData, index: Int) async -> (Bool, String?) {
        let url = AppConfig.baseURL.appendingPathComponent("signup")
        
        print("🔄 [\(index)/9] Creating user: \(user.username)...")
        print("   URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let signupData: [String: Any] = [
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email,
            "password": user.password,
            "username": user.username,
            "dateOfBirth": user.dateOfBirth,
            "gender": user.gender,
            "isPrivate": user.isPrivate,
            "profilePhoto": user.profilePhoto,
            "about": user.about ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: signupData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("✅ [\(index)/9] Created user: \(user.username) (private: \(user.isPrivate))")
                    
                    // Extract accessToken from response (server returns "accessToken" not "token")
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["accessToken"] as? String {
                        return (true, token)
                    }
                    print("⚠️  Token extraction failed for \(user.username)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Response body: \(responseString)")
                    }
                    return (true, nil)
                } else {
                    print("❌ [\(index)/9] Failed to create \(user.username): HTTP \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Server response: \(responseString)")
                    }
                    return (false, nil)
                }
            }
            print("❌ [\(index)/9] Invalid response type for \(user.username)")
            return (false, nil)
        } catch let error as NSError {
            print("❌ [\(index)/9] Network error creating \(user.username):")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                print("   Underlying: \(underlyingError.localizedDescription)")
            }
            return (false, nil)
        }
    }
}
