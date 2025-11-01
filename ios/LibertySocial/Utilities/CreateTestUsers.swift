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
        ),
        TestUserData(
            firstName: "Johnny",
            lastName: "Cash",
            email: "johnny@cash.com",
            password: "Password1",
            username: "JohnnyCash",
            dateOfBirth: "1932-02-26",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Johnny_Cash_1969.jpg/440px-Johnny_Cash_1969.jpg",
            about: "Country music legend. Singer-songwriter known for deep voice and somber themes. Walk the line."
        ),
        TestUserData(
            firstName: "Bob",
            lastName: "Marley",
            email: "bob@marley.com",
            password: "Password1",
            username: "BobMarley",
            dateOfBirth: "1945-02-06",
            gender: "MALE",
            isPrivate: true,
            profilePhoto: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Bob-Marley-in-Concert_Zurich_05-30-80.jpg/440px-Bob-Marley-in-Concert_Zurich_05-30-80.jpg",
            about: "Reggae icon and musical revolutionary. Spreading messages of love, unity, and peace through music."
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
              let tomToken = userTokens["tom@brady.com"],
              let johnnyCashToken = userTokens["johnny@cash.com"],
              let bobMarleyToken = userTokens["bob@marley.com"] else {
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
        
        guard let johnnyCashUserId = await getUserId(token: johnnyCashToken) else {
            print("❌ Failed to get Johnny Cash's user ID")
            return
        }
        
        guard let bobMarleyUserId = await getUserId(token: bobMarleyToken) else {
            print("❌ Failed to get Bob Marley's user ID")
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
        
        // Set up connections to Johnny Cash
        print("\n🎸 Setting up connections to Johnny Cash...")
        
        // Jack Johnson -> Johnny Cash (ACQUAINTANCE)
        await sendConnectionRequest(
            token: jackToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Jack Johnson to Johnny Cash"
        )
        
        // Jane Doe -> Johnny Cash (ACQUAINTANCE)
        await sendConnectionRequest(
            token: janeToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Jane Doe to Johnny Cash"
        )
        
        // Billy Bob -> Johnny Cash (STRANGER)
        await sendConnectionRequest(
            token: billyToken,
            requestedId: johnnyCashUserId,
            type: "STRANGER",
            senderName: "Billy Bob to Johnny Cash"
        )
        
        // Harry Truman -> Johnny Cash (FOLLOW)
        await sendConnectionRequest(
            token: harryToken,
            requestedId: johnnyCashUserId,
            type: "FOLLOW",
            senderName: "Harry Truman to Johnny Cash"
        )
        
        // John Smith -> Johnny Cash (FOLLOW)
        await sendConnectionRequest(
            token: johnSmithToken,
            requestedId: johnnyCashUserId,
            type: "FOLLOW",
            senderName: "John Smith to Johnny Cash"
        )
        
        // Wait for requests to settle
        print("⏳ Waiting for Johnny Cash requests to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Get Johnny Cash's pending requests
        print("📥 Fetching Johnny Cash's pending connection requests...")
        guard let pendingRequestsJohnnyCash = await getPendingRequests(token: johnnyCashToken) else {
            print("❌ Failed to get Johnny Cash's pending requests")
            return
        }
        
        print("   Found \(pendingRequestsJohnnyCash.count) pending request(s) for Johnny Cash")
        
        // Johnny Cash accepts all requests
        print("✋ Johnny Cash accepting all requests...")
        for request in pendingRequestsJohnnyCash {
            if let requestId = request["id"] as? String {
                await acceptConnectionRequest(token: johnnyCashToken, requestId: requestId, senderName: "various users")
            }
        }
        
        // Wait for acceptances to settle
        print("⏳ Waiting for acceptances to settle...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Create Musicians group
        print("\n🎵 Creating Musicians group...")
        guard let musiciansGroupId = await createGroup(
            token: jackToken,
            name: "Musicians",
            description: "A group for music lovers and musicians to connect and share",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) else {
            print("❌ Failed to create Musicians group")
            return
        }
        
        print("✅ Created Musicians group with ID: \(musiciansGroupId)")
        
        // Wait for group to settle
        print("⏳ Waiting for group creation to settle...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Invite musicians to the group (Jack is already a member as creator)
        print("\n📨 Inviting musicians to the group...")
        
        let musicianIds = [johnnyCashUserId, janeUserId, billyUserId, bobMarleyUserId]
        await inviteToGroup(token: jackToken, groupId: musiciansGroupId, userIds: musicianIds)
        
        // Wait for invites to settle
        print("⏳ Waiting for invites to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Each musician accepts their invite
        print("\n✋ Musicians accepting group invites...")
        await acceptGroupInvite(token: johnnyCashToken, groupId: musiciansGroupId, userName: "Johnny Cash")
        await acceptGroupInvite(token: janeToken, groupId: musiciansGroupId, userName: "Jane Doe")
        await acceptGroupInvite(token: billyToken, groupId: musiciansGroupId, userName: "Billy Bob")
        await acceptGroupInvite(token: bobMarleyToken, groupId: musiciansGroupId, userName: "Bob Marley")
        
        // Create posts from various users
        print("\n📝 Creating posts from users...")
        await createPosts(userTokens: userTokens)
        
        print("\n✅ Connection setup complete!")
    }
    
    private static func createPosts(userTokens: [String: String]) async {
        // Johnny Cash posts
        if let token = userTokens["johnny@cash.com"] {
            await createPost(token: token, content: "Just finished recording a new track. There's something special about that deep, resonant sound. Walk the line, friends. 🎸", userName: "Johnny Cash")
            await createPost(token: token, content: "Music has always been my way of telling stories. Every song is a journey, every chord a memory.", userName: "Johnny Cash")
        }
        
        // Bob Marley posts
        if let token = userTokens["bob@marley.com"] {
            await createPost(token: token, content: "One good thing about music, when it hits you, you feel no pain. Keep spreading the love and positivity. ✌️", userName: "Bob Marley")
            await createPost(token: token, content: "Don't worry about a thing, cause every little thing is gonna be alright. Have a blessed day everyone!", userName: "Bob Marley")
        }
        
        // Jack Johnson posts
        if let token = userTokens["jack@johnson.com"] {
            await createPost(token: token, content: "Beach session today with the guitar. Nothing beats the sound of waves and strings together 🌊🎸", userName: "Jack Johnson")
            await createPost(token: token, content: "Just discovered an amazing local band. Supporting live music is so important!", userName: "Jack Johnson")
        }
        
        // Jane Doe posts
        if let token = userTokens["jane@doe.com"] {
            await createPost(token: token, content: "Working on a new design project inspired by music and visual art. The creative process is magical! 🎨", userName: "Jane Doe")
            await createPost(token: token, content: "Sometimes the best designs come from unexpected places. Stay curious, stay inspired!", userName: "Jane Doe")
        }
        
        // Billy Bob posts
        if let token = userTokens["billy@bob.com"] {
            await createPost(token: token, content: "Hiked 12 miles today and the views were absolutely worth it! Nature is the best medicine. 🏔️", userName: "Billy Bob")
            await createPost(token: token, content: "Planning next weekend's camping trip. Who else loves sleeping under the stars?", userName: "Billy Bob")
        }
        
        // Harry Truman posts
        if let token = userTokens["harry@truman.com"] {
            await createPost(token: token, content: "Reading a fascinating biography on American political history. The past has so much to teach us about the present.", userName: "Harry Truman")
            await createPost(token: token, content: "Coffee and philosophy this morning. What's everyone reading these days?", userName: "Harry Truman")
        }
        
        // John Smith posts
        if let token = userTokens["john@smith.com"] {
            await createPost(token: token, content: "Just learned about a new technology that could revolutionize how we approach problem-solving. Innovation never stops!", userName: "John Smith")
            await createPost(token: token, content: "Sharing knowledge is one of the most powerful things we can do. Always happy to help others learn.", userName: "John Smith")
        }
        
        // Dave Chappelle posts
        if let token = userTokens["dave@chappelle.com"] {
            await createPost(token: token, content: "You know what's funny? Life. Just pay attention and you'll see the comedy everywhere. 😄", userName: "Dave Chappelle")
            await createPost(token: token, content: "Laughter is the best medicine. Unless you're diabetic, then insulin is pretty important too. But after that, laughter!", userName: "Dave Chappelle")
        }
        
        // Tom Brady posts
        if let token = userTokens["tom@brady.com"] {
            await createPost(token: token, content: "Another day, another opportunity to be better than yesterday. Hard work and discipline pay off! 💪", userName: "Tom Brady")
            await createPost(token: token, content: "Success isn't just about talent—it's about commitment, preparation, and never giving up.", userName: "Tom Brady")
        }
        
        // John Doe posts
        if let token = userTokens["john@doe.com"] {
            await createPost(token: token, content: "Solved a really challenging coding problem today. There's nothing quite like that 'aha!' moment when everything clicks.", userName: "John Doe")
            await createPost(token: token, content: "Building software that helps people is incredibly rewarding. Love what I do!", userName: "John Doe")
        }
        
        // John Kennedy posts
        if let token = userTokens["john@kennedy.com"] {
            await createPost(token: token, content: "Community engagement event was a success! When we work together, amazing things happen. 🇺🇸", userName: "John Kennedy")
            await createPost(token: token, content: "Ask not what your community can do for you, but what you can do for your community.", userName: "John Kennedy")
        }
    }
    
    private static func createPost(token: String, content: String, userName: String) async {
        let url = AppConfig.baseURL.appendingPathComponent("posts")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let postData: [String: Any] = [
            "content": content,
            "visibility": "PUBLIC"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postData)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ Created post from \(userName)")
            } else {
                print("❌ Failed to create post from \(userName)")
            }
        } catch {
            print("❌ Error creating post from \(userName): \(error.localizedDescription)")
        }
    }
    
    private static func createGroup(token: String, name: String, description: String, groupType: String, privacy: String) async -> String? {
        let url = AppConfig.baseURL.appendingPathComponent("groups")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let groupData: [String: Any] = [
            "name": name,
            "description": description,
            "groupType": groupType,
            "groupPrivacy": privacy
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: groupData)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let groupId = json["id"] as? String {
                    return groupId
                }
            }
        } catch {
            print("❌ Error creating group: \(error.localizedDescription)")
        }
        return nil
    }
    
    private static func inviteToGroup(token: String, groupId: String, userIds: [String]) async {
        let url = AppConfig.baseURL.appendingPathComponent("groups/\(groupId)/invite")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let inviteData: [String: Any] = ["userIds": userIds]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: inviteData)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ Sent \(userIds.count) group invites")
            } else {
                print("❌ Failed to send group invites")
            }
        } catch {
            print("❌ Error sending group invites: \(error.localizedDescription)")
        }
    }
    
    private static func acceptGroupInvite(token: String, groupId: String, userName: String) async {
        let url = AppConfig.baseURL.appendingPathComponent("groups/\(groupId)/accept-invite")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ \(userName) accepted group invite")
            } else {
                print("❌ \(userName) failed to accept group invite")
            }
        } catch {
            print("❌ Error accepting group invite for \(userName): \(error.localizedDescription)")
        }
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
        
        print("🔄 [\(index)/11] Creating user: \(user.username)...")
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
                    print("✅ [\(index)/11] Created user: \(user.username) (private: \(user.isPrivate))")
                    
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
                    print("❌ [\(index)/11] Failed to create \(user.username): HTTP \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Server response: \(responseString)")
                    }
                    return (false, nil)
                }
            }
            print("❌ [\(index)/11] Invalid response type for \(user.username)")
            return (false, nil)
        } catch let error as NSError {
            print("❌ [\(index)/11] Network error creating \(user.username):")
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
