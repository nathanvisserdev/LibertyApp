
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
        ),
        TestUserData(
            firstName: "Marie",
            lastName: "Curie",
            email: "marie@curie.com",
            password: "Password1",
            username: "MarieCurie",
            dateOfBirth: "1867-11-07",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=45",
            about: "Scientist and researcher. Pioneer in radioactivity. Two-time Nobel Prize winner. Science is my passion!"
        ),
        TestUserData(
            firstName: "Albert",
            lastName: "Einstein",
            email: "albert@einstein.com",
            password: "Password1",
            username: "AlbertEinstein",
            dateOfBirth: "1879-03-14",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=13",
            about: "Theoretical physicist. Imagination is more important than knowledge. E=mc². Relativity enthusiast."
        ),
        TestUserData(
            firstName: "Amelia",
            lastName: "Earhart",
            email: "amelia@earhart.com",
            password: "Password1",
            username: "AmeliaEarhart",
            dateOfBirth: "1897-07-24",
            gender: "FEMALE",
            isPrivate: true,
            profilePhoto: "https://i.pravatar.cc/150?img=48",
            about: "Aviation pioneer and adventurer. The most difficult thing is the decision to act. Flying is freedom!"
        ),
        TestUserData(
            firstName: "Leonardo",
            lastName: "da Vinci",
            email: "leonardo@davinci.com",
            password: "Password1",
            username: "LeonardoDaVinci",
            dateOfBirth: "1452-04-15",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=60",
            about: "Renaissance artist and inventor. Painter, sculptor, architect, scientist. Art is never finished, only abandoned."
        ),
        TestUserData(
            firstName: "Rosa",
            lastName: "Parks",
            email: "rosa@parks.com",
            password: "Password1",
            username: "RosaParks",
            dateOfBirth: "1913-02-04",
            gender: "FEMALE",
            isPrivate: true,
            profilePhoto: "https://i.pravatar.cc/150?img=20",
            about: "Civil rights activist. Stand up for what is right, even if you're standing alone. Change maker."
        ),
        TestUserData(
            firstName: "Winston",
            lastName: "Churchill",
            email: "winston@churchill.com",
            password: "Password1",
            username: "WinstonChurchill",
            dateOfBirth: "1874-11-30",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=59",
            about: "Statesman and orator. Success is not final, failure is not fatal. History enthusiast and writer."
        ),
        TestUserData(
            firstName: "Frida",
            lastName: "Kahlo",
            email: "frida@kahlo.com",
            password: "Password1",
            username: "FridaKahlo",
            dateOfBirth: "1907-07-06",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=44",
            about: "Artist and icon. I paint my own reality. Self-portraits are my way of expressing inner emotions."
        ),
        TestUserData(
            firstName: "Muhammad",
            lastName: "Ali",
            email: "muhammad@ali.com",
            password: "Password1",
            username: "MuhammadAli",
            dateOfBirth: "1942-01-17",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=51",
            about: "The Greatest. Float like a butterfly, sting like a bee. Champion inside and outside the ring."
        ),
        TestUserData(
            firstName: "Maya",
            lastName: "Angelou",
            email: "maya@angelou.com",
            password: "Password1",
            username: "MayaAngelou",
            dateOfBirth: "1928-04-04",
            gender: "FEMALE",
            isPrivate: true,
            profilePhoto: "https://i.pravatar.cc/150?img=49",
            about: "Poet and civil rights activist. Still I rise. Words have power to change the world and heal souls."
        ),
        TestUserData(
            firstName: "Nelson",
            lastName: "Mandela",
            email: "nelson@mandela.com",
            password: "Password1",
            username: "NelsonMandela",
            dateOfBirth: "1918-07-18",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=56",
            about: "Freedom fighter and humanitarian. Education is the most powerful weapon. Peace and reconciliation advocate."
        ),
        TestUserData(
            firstName: "Harriet",
            lastName: "Tubman",
            email: "harriet@tubman.com",
            password: "Password1",
            username: "HarrietTubman",
            dateOfBirth: "1822-03-10",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=47",
            about: "Freedom fighter and Underground Railroad conductor. Every great dream begins with a dreamer."
        ),
        TestUserData(
            firstName: "Nikola",
            lastName: "Tesla",
            email: "nikola@tesla.com",
            password: "Password1",
            username: "NikolaTesla",
            dateOfBirth: "1856-07-10",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=33",
            about: "Inventor and electrical engineer. The present is theirs; the future is mine. Innovation through electricity."
        ),
        TestUserData(
            firstName: "Ella",
            lastName: "Fitzgerald",
            email: "ella@fitzgerald.com",
            password: "Password1",
            username: "EllaFitzgerald",
            dateOfBirth: "1917-04-25",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=45",
            about: "First Lady of Song. Jazz vocalist with a voice like no other. Music is my passion and joy."
        ),
        TestUserData(
            firstName: "Martin",
            lastName: "Luther King Jr",
            email: "martin@king.com",
            password: "Password1",
            username: "MartinLutherKing",
            dateOfBirth: "1929-01-15",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=52",
            about: "Civil rights leader. I have a dream. Darkness cannot drive out darkness; only light can do that."
        ),
        TestUserData(
            firstName: "Cleopatra",
            lastName: "VII",
            email: "cleopatra@egypt.com",
            password: "Password1",
            username: "Cleopatra",
            dateOfBirth: "0069-01-01",
            gender: "FEMALE",
            isPrivate: false,
            profilePhoto: "https://i.pravatar.cc/150?img=26",
            about: "Last pharaoh of Egypt. Leader, strategist, and polyglot. History is written by the bold."
        )
    ]
    
    static func createAllUsers() async -> TestUsersResult {
        print("🚀 Starting to create test users...")
        print("   Server: \(AppConfig.baseURL.absoluteString)")
        
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
              let bobMarleyToken = userTokens["bob@marley.com"],
              let marieToken = userTokens["marie@curie.com"],
              let albertToken = userTokens["albert@einstein.com"],
              let ameliaToken = userTokens["amelia@earhart.com"],
              let leonardoToken = userTokens["leonardo@davinci.com"],
              let rosaToken = userTokens["rosa@parks.com"],
              let winstonToken = userTokens["winston@churchill.com"],
              let fridaToken = userTokens["frida@kahlo.com"],
              let muhammadToken = userTokens["muhammad@ali.com"],
              let mayaToken = userTokens["maya@angelou.com"],
              let nelsonToken = userTokens["nelson@mandela.com"] else {
            print("❌ Missing user tokens for connection setup")
            return
        }
        
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
        
        guard let marieUserId = await getUserId(token: marieToken) else {
            print("❌ Failed to get Marie Curie's user ID")
            return
        }
        
        guard let albertUserId = await getUserId(token: albertToken) else {
            print("❌ Failed to get Albert Einstein's user ID")
            return
        }
        
        guard let ameliaUserId = await getUserId(token: ameliaToken) else {
            print("❌ Failed to get Amelia Earhart's user ID")
            return
        }
        
        guard let leonardoUserId = await getUserId(token: leonardoToken) else {
            print("❌ Failed to get Leonardo da Vinci's user ID")
            return
        }
        
        guard let rosaUserId = await getUserId(token: rosaToken) else {
            print("❌ Failed to get Rosa Parks's user ID")
            return
        }
        
        guard let winstonUserId = await getUserId(token: winstonToken) else {
            print("❌ Failed to get Winston Churchill's user ID")
            return
        }
        
        guard let fridaUserId = await getUserId(token: fridaToken) else {
            print("❌ Failed to get Frida Kahlo's user ID")
            return
        }
        
        guard let muhammadUserId = await getUserId(token: muhammadToken) else {
            print("❌ Failed to get Muhammad Ali's user ID")
            return
        }
        
        guard let mayaUserId = await getUserId(token: mayaToken) else {
            print("❌ Failed to get Maya Angelou's user ID")
            return
        }
        
        guard let nelsonUserId = await getUserId(token: nelsonToken) else {
            print("❌ Failed to get Nelson Mandela's user ID")
            return
        }
        
        guard let johnnyCashUserId = await getUserId(token: johnnyCashToken) else {
            print("❌ Failed to get Johnny Cash's user ID")
            return
        }
        
        guard let harrietToken = userTokens["harriet@tubman.com"],
              let harrietUserId = await getUserId(token: harrietToken) else {
            print("❌ Failed to get Harriet Tubman's user ID")
            return
        }
        
        guard let nikolaToken = userTokens["nikola@tesla.com"],
              let nikolaUserId = await getUserId(token: nikolaToken) else {
            print("❌ Failed to get Nikola Tesla's user ID")
            return
        }
        
        guard let ellaToken = userTokens["ella@fitzgerald.com"],
              let ellaUserId = await getUserId(token: ellaToken) else {
            print("❌ Failed to get Ella Fitzgerald's user ID")
            return
        }
        
        guard let martinToken = userTokens["martin@king.com"],
              let martinUserId = await getUserId(token: martinToken) else {
            print("❌ Failed to get Martin Luther King's user ID")
            return
        }
        
        guard let cleopatraToken = userTokens["cleopatra@egypt.com"],
              let cleopatraUserId = await getUserId(token: cleopatraToken) else {
            print("❌ Failed to get Cleopatra's user ID")
            return
        }
        
        var sentRequestsToJohnSmith: [String: (userId: String, type: String, name: String)] = [:]
        
        if await sendConnectionRequest(
            token: billyToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Billy Bob"
        ) {
            sentRequestsToJohnSmith[billyUserId] = (billyUserId, "ACQUAINTANCE", "Billy Bob")
        }
        
        if await sendConnectionRequest(
            token: harryToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "Harry Truman"
        ) {
            sentRequestsToJohnSmith[harryUserId] = (harryUserId, "STRANGER", "Harry Truman")
        }
        
        if await sendConnectionRequest(
            token: janeToken,
            requestedId: johnSmithUserId,
            type: "FOLLOW",
            senderName: "Jane Doe"
        ) {
            sentRequestsToJohnSmith[janeUserId] = (janeUserId, "FOLLOW", "Jane Doe")
        }
        
        if await sendConnectionRequest(
            token: jackToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Jack Johnson"
        ) {
            sentRequestsToJohnSmith[jackUserId] = (jackUserId, "ACQUAINTANCE", "Jack Johnson")
        }
        
        if await sendConnectionRequest(
            token: johnDoeToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "John Doe"
        ) {
            sentRequestsToJohnSmith[johnDoeUserId] = (johnDoeUserId, "STRANGER", "John Doe")
        }
        
        if await sendConnectionRequest(
            token: daveToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Dave Chappelle"
        ) {
            sentRequestsToJohnSmith[daveUserId] = (daveUserId, "ACQUAINTANCE", "Dave Chappelle")
        }
        
        if await sendConnectionRequest(
            token: jfkToken,
            requestedId: johnSmithUserId,
            type: "STRANGER",
            senderName: "John Kennedy"
        ) {
            sentRequestsToJohnSmith[jfkUserId] = (jfkUserId, "STRANGER", "John Kennedy")
        }
        
        if await sendConnectionRequest(
            token: tomToken,
            requestedId: johnSmithUserId,
            type: "ACQUAINTANCE",
            senderName: "Tom Brady"
        ) {
            sentRequestsToJohnSmith[tomUserId] = (tomUserId, "ACQUAINTANCE", "Tom Brady")
        }
        
        print("\n⏳ Waiting for requests to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        print("\n📥 Fetching John Smith's pending connection requests...")
        guard let pendingRequestsJohnSmith = await getPendingRequests(token: johnSmithToken) else {
            print("❌ Failed to get John Smith's pending requests")
            return
        }
        
        print("   Found \(pendingRequestsJohnSmith.count) pending request(s) for John Smith")
        
        print("\n✋ Processing John Smith's acceptances...")
        for request in pendingRequestsJohnSmith {
            if let requesterId = request["requesterId"] as? String,
               let requestId = request["id"] as? String,
               let senderInfo = sentRequestsToJohnSmith[requesterId] {
                
                if senderInfo.type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                else if senderInfo.type == "FOLLOW" {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                else if senderInfo.type == "STRANGER" && (senderInfo.name == "John Doe" || senderInfo.name == "John Kennedy") {
                    await acceptConnectionRequest(token: johnSmithToken, requestId: requestId, senderName: senderInfo.name)
                }
                else if senderInfo.type == "STRANGER" && senderInfo.name == "Harry Truman" {
                    print("⏸️  Leaving STRANGER request from \(senderInfo.name) pending")
                }
            }
        }
        
        print("\n⏳ Waiting for acceptances to settle...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        print("\n🔗 Setting up John Doe -> Jane Doe connection...")
        
        let johnDoeToJaneSuccess = await sendConnectionRequest(
            token: johnDoeToken,
            requestedId: janeUserId,
            type: "ACQUAINTANCE",
            senderName: "John Doe to Jane Doe"
        )
        
        if johnDoeToJaneSuccess {
            print("⏳ Waiting for John Doe's request to settle...")
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            print("📥 Fetching Jane Doe's pending connection requests...")
            guard let pendingRequestsJane = await getPendingRequests(token: janeToken) else {
                print("❌ Failed to get Jane Doe's pending requests")
                return
            }
            
            print("   Found \(pendingRequestsJane.count) pending request(s) for Jane Doe")
            
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
        
        print("\n🎸 Setting up connections to Johnny Cash...")
        
        await sendConnectionRequest(
            token: jackToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Jack Johnson to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: janeToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Jane Doe to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: harrietToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Harriet Tubman to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: nikolaToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Nikola Tesla to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: ellaToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Ella Fitzgerald to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: martinToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Martin Luther King to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: cleopatraToken,
            requestedId: johnnyCashUserId,
            type: "ACQUAINTANCE",
            senderName: "Cleopatra to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: billyToken,
            requestedId: johnnyCashUserId,
            type: "STRANGER",
            senderName: "Billy Bob to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: harryToken,
            requestedId: johnnyCashUserId,
            type: "FOLLOW",
            senderName: "Harry Truman to Johnny Cash"
        )
        
        await sendConnectionRequest(
            token: johnSmithToken,
            requestedId: johnnyCashUserId,
            type: "FOLLOW",
            senderName: "John Smith to Johnny Cash"
        )
        
        await sendConnectionRequest(token: marieToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Marie Curie to Johnny Cash")
        await sendConnectionRequest(token: albertToken, requestedId: johnnyCashUserId, type: "ACQUAINTANCE", senderName: "Albert Einstein to Johnny Cash")
        await sendConnectionRequest(token: ameliaToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Amelia Earhart to Johnny Cash")
        await sendConnectionRequest(token: leonardoToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Leonardo da Vinci to Johnny Cash")
        await sendConnectionRequest(token: rosaToken, requestedId: johnnyCashUserId, type: "ACQUAINTANCE", senderName: "Rosa Parks to Johnny Cash")
        await sendConnectionRequest(token: winstonToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Winston Churchill to Johnny Cash")
        await sendConnectionRequest(token: fridaToken, requestedId: johnnyCashUserId, type: "ACQUAINTANCE", senderName: "Frida Kahlo to Johnny Cash")
        await sendConnectionRequest(token: muhammadToken, requestedId: johnnyCashUserId, type: "ACQUAINTANCE", senderName: "Muhammad Ali to Johnny Cash")
        await sendConnectionRequest(token: mayaToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Maya Angelou to Johnny Cash")
        await sendConnectionRequest(token: nelsonToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Nelson Mandela to Johnny Cash")
        await sendConnectionRequest(token: daveToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Dave Chappelle to Johnny Cash")
        await sendConnectionRequest(token: tomToken, requestedId: johnnyCashUserId, type: "FOLLOW", senderName: "Tom Brady to Johnny Cash")
        
        print("\n🎸 Johnny Cash following other inspiring people...")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: bobMarleyUserId, type: "FOLLOW", senderName: "Johnny Cash to Bob Marley")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: mayaUserId, type: "FOLLOW", senderName: "Johnny Cash to Maya Angelou")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: nelsonUserId, type: "FOLLOW", senderName: "Johnny Cash to Nelson Mandela")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: muhammadUserId, type: "FOLLOW", senderName: "Johnny Cash to Muhammad Ali")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: winstonUserId, type: "FOLLOW", senderName: "Johnny Cash to Winston Churchill")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: fridaUserId, type: "FOLLOW", senderName: "Johnny Cash to Frida Kahlo")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: leonardoUserId, type: "FOLLOW", senderName: "Johnny Cash to Leonardo da Vinci")
        await sendConnectionRequest(token: johnnyCashToken, requestedId: rosaUserId, type: "FOLLOW", senderName: "Johnny Cash to Rosa Parks")
        
        print("⏳ Waiting for Johnny Cash requests to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        print("📥 Fetching Johnny Cash's pending connection requests...")
        guard let pendingRequestsJohnnyCash = await getPendingRequests(token: johnnyCashToken) else {
            print("❌ Failed to get Johnny Cash's pending requests")
            return
        }
        
        print("   Found \(pendingRequestsJohnnyCash.count) pending request(s) for Johnny Cash")
        
        print("✋ Johnny Cash accepting all requests...")
        for request in pendingRequestsJohnnyCash {
            if let requestId = request["id"] as? String {
                await acceptConnectionRequest(token: johnnyCashToken, requestId: requestId, senderName: "various users")
            }
        }
        
        print("⏳ Waiting for acceptances to settle and adjacency table to update...")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        print("\n✋ Users accepting Johnny Cash's follow requests...")
        
        if let pendingBob = await getPendingRequests(token: bobMarleyToken) {
            for request in pendingBob {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: bobMarleyToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingMaya = await getPendingRequests(token: mayaToken) {
            for request in pendingMaya {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: mayaToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingNelson = await getPendingRequests(token: nelsonToken) {
            for request in pendingNelson {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: nelsonToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingMuhammad = await getPendingRequests(token: muhammadToken) {
            for request in pendingMuhammad {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: muhammadToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingWinston = await getPendingRequests(token: winstonToken) {
            for request in pendingWinston {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: winstonToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingFrida = await getPendingRequests(token: fridaToken) {
            for request in pendingFrida {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: fridaToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingLeonardo = await getPendingRequests(token: leonardoToken) {
            for request in pendingLeonardo {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: leonardoToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        if let pendingRosa = await getPendingRequests(token: rosaToken) {
            for request in pendingRosa {
                if let requesterId = request["requesterId"] as? String, requesterId == johnnyCashUserId,
                   let requestId = request["id"] as? String {
                    await acceptConnectionRequest(token: rosaToken, requestId: requestId, senderName: "Johnny Cash")
                }
            }
        }
        
        print("⏳ Waiting for Johnny's following acceptances to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        print("\n🌐 Creating additional connections between users...")
        
        await sendConnectionRequest(token: albertToken, requestedId: marieUserId, type: "ACQUAINTANCE", senderName: "Albert Einstein to Marie Curie")
        await sendConnectionRequest(token: albertToken, requestedId: nikolaUserId, type: "ACQUAINTANCE", senderName: "Albert Einstein to Nikola Tesla")
        await sendConnectionRequest(token: marieToken, requestedId: nikolaUserId, type: "ACQUAINTANCE", senderName: "Marie Curie to Nikola Tesla")
        
        await sendConnectionRequest(token: leonardoToken, requestedId: fridaUserId, type: "ACQUAINTANCE", senderName: "Leonardo da Vinci to Frida Kahlo")
        await sendConnectionRequest(token: leonardoToken, requestedId: mayaUserId, type: "ACQUAINTANCE", senderName: "Leonardo da Vinci to Maya Angelou")
        await sendConnectionRequest(token: fridaToken, requestedId: mayaUserId, type: "ACQUAINTANCE", senderName: "Frida Kahlo to Maya Angelou")
        
        await sendConnectionRequest(token: rosaToken, requestedId: martinUserId, type: "ACQUAINTANCE", senderName: "Rosa Parks to Martin Luther King")
        await sendConnectionRequest(token: rosaToken, requestedId: nelsonUserId, type: "ACQUAINTANCE", senderName: "Rosa Parks to Nelson Mandela")
        await sendConnectionRequest(token: martinToken, requestedId: nelsonUserId, type: "ACQUAINTANCE", senderName: "Martin Luther King to Nelson Mandela")
        await sendConnectionRequest(token: martinToken, requestedId: harrietUserId, type: "ACQUAINTANCE", senderName: "Martin Luther King to Harriet Tubman")
        
        await sendConnectionRequest(token: muhammadToken, requestedId: tomUserId, type: "ACQUAINTANCE", senderName: "Muhammad Ali to Tom Brady")
        
        await sendConnectionRequest(token: bobMarleyToken, requestedId: ellaUserId, type: "ACQUAINTANCE", senderName: "Bob Marley to Ella Fitzgerald")
        await sendConnectionRequest(token: bobMarleyToken, requestedId: jackUserId, type: "ACQUAINTANCE", senderName: "Bob Marley to Jack Johnson")
        await sendConnectionRequest(token: ellaToken, requestedId: jackUserId, type: "ACQUAINTANCE", senderName: "Ella Fitzgerald to Jack Johnson")
        
        await sendConnectionRequest(token: daveToken, requestedId: mayaUserId, type: "ACQUAINTANCE", senderName: "Dave Chappelle to Maya Angelou")
        await sendConnectionRequest(token: daveToken, requestedId: muhammadUserId, type: "ACQUAINTANCE", senderName: "Dave Chappelle to Muhammad Ali")
        
        await sendConnectionRequest(token: winstonToken, requestedId: jfkUserId, type: "ACQUAINTANCE", senderName: "Winston Churchill to JFK")
        await sendConnectionRequest(token: winstonToken, requestedId: harryUserId, type: "ACQUAINTANCE", senderName: "Winston Churchill to Harry Truman")
        await sendConnectionRequest(token: cleopatraToken, requestedId: leonardoUserId, type: "ACQUAINTANCE", senderName: "Cleopatra to Leonardo da Vinci")
        
        await sendConnectionRequest(token: ameliaToken, requestedId: janeUserId, type: "ACQUAINTANCE", senderName: "Amelia Earhart to Jane Doe")
        await sendConnectionRequest(token: ameliaToken, requestedId: harrietUserId, type: "ACQUAINTANCE", senderName: "Amelia Earhart to Harriet Tubman")
        
        await sendConnectionRequest(token: billyToken, requestedId: bobMarleyUserId, type: "FOLLOW", senderName: "Billy Bob to Bob Marley")
        await sendConnectionRequest(token: johnSmithToken, requestedId: albertUserId, type: "FOLLOW", senderName: "John Smith to Albert Einstein")
        await sendConnectionRequest(token: janeToken, requestedId: fridaUserId, type: "FOLLOW", senderName: "Jane Doe to Frida Kahlo")
        await sendConnectionRequest(token: johnDoeToken, requestedId: leonardoUserId, type: "FOLLOW", senderName: "John Doe to Leonardo da Vinci")
        
        print("⏳ Waiting for additional connection requests to settle...")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        print("✋ Auto-accepting mutual connection requests...")
        
        if let pendingMarie = await getPendingRequests(token: marieToken) {
            for request in pendingMarie {
                if let requesterId = request["requesterId"] as? String,
                   let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: marieToken, requestId: requestId, senderName: "Scientists")
                }
            }
        }
        
        if let pendingNikola = await getPendingRequests(token: nikolaToken) {
            for request in pendingNikola {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: nikolaToken, requestId: requestId, senderName: "Scientists")
                }
            }
        }
        
        if let pendingFrida = await getPendingRequests(token: fridaToken) {
            for request in pendingFrida {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: fridaToken, requestId: requestId, senderName: "Artists")
                }
            }
        }
        
        if let pendingMaya = await getPendingRequests(token: mayaToken) {
            for request in pendingMaya {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: mayaToken, requestId: requestId, senderName: "Writers/Artists")
                }
            }
        }
        
        if let pendingMartin = await getPendingRequests(token: martinToken) {
            for request in pendingMartin {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: martinToken, requestId: requestId, senderName: "Civil Rights Leaders")
                }
            }
        }
        
        if let pendingNelson = await getPendingRequests(token: nelsonToken) {
            for request in pendingNelson {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: nelsonToken, requestId: requestId, senderName: "Civil Rights Leaders")
                }
            }
        }
        
        if let pendingHarriet = await getPendingRequests(token: harrietToken) {
            for request in pendingHarriet {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: harrietToken, requestId: requestId, senderName: "Freedom Fighters")
                }
            }
        }
        
        if let pendingBob = await getPendingRequests(token: bobMarleyToken) {
            for request in pendingBob {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: bobMarleyToken, requestId: requestId, senderName: "Musicians")
                }
            }
        }
        
        if let pendingElla = await getPendingRequests(token: ellaToken) {
            for request in pendingElla {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: ellaToken, requestId: requestId, senderName: "Musicians")
                }
            }
        }
        
        if let pendingJack = await getPendingRequests(token: jackToken) {
            for request in pendingJack {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: jackToken, requestId: requestId, senderName: "Musicians")
                }
            }
        }
        
        if let pendingTom = await getPendingRequests(token: tomToken) {
            for request in pendingTom {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: tomToken, requestId: requestId, senderName: "Athletes")
                }
            }
        }
        
        if let pendingMuhammad = await getPendingRequests(token: muhammadToken) {
            for request in pendingMuhammad {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: muhammadToken, requestId: requestId, senderName: "Athletes")
                }
            }
        }
        
        if let pendingDave = await getPendingRequests(token: daveToken) {
            for request in pendingDave {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: daveToken, requestId: requestId, senderName: "Entertainers")
                }
            }
        }
        
        if let pendingWinston = await getPendingRequests(token: winstonToken) {
            for request in pendingWinston {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: winstonToken, requestId: requestId, senderName: "Leaders")
                }
            }
        }
        
        if let pendingJFK = await getPendingRequests(token: jfkToken) {
            for request in pendingJFK {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: jfkToken, requestId: requestId, senderName: "Leaders")
                }
            }
        }
        
        if let pendingHarry = await getPendingRequests(token: harryToken) {
            for request in pendingHarry {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: harryToken, requestId: requestId, senderName: "Leaders")
                }
            }
        }
        
        if let pendingLeonardo = await getPendingRequests(token: leonardoToken) {
            for request in pendingLeonardo {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: leonardoToken, requestId: requestId, senderName: "Renaissance People")
                }
            }
        }
        
        if let pendingCleopatra = await getPendingRequests(token: cleopatraToken) {
            for request in pendingCleopatra {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: cleopatraToken, requestId: requestId, senderName: "Historical Figures")
                }
            }
        }
        
        if let pendingAmelia = await getPendingRequests(token: ameliaToken) {
            for request in pendingAmelia {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: ameliaToken, requestId: requestId, senderName: "Adventurers")
                }
            }
        }
        
        if let pendingJane = await getPendingRequests(token: janeToken) {
            for request in pendingJane {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "ACQUAINTANCE" {
                    await acceptConnectionRequest(token: janeToken, requestId: requestId, senderName: "Modern Users")
                }
            }
        }
        
        if let pendingBobFollows = await getPendingRequests(token: bobMarleyToken) {
            for request in pendingBobFollows {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "FOLLOW" {
                    await acceptConnectionRequest(token: bobMarleyToken, requestId: requestId, senderName: "Followers")
                }
            }
        }
        
        if let pendingAlbertFollows = await getPendingRequests(token: albertToken) {
            for request in pendingAlbertFollows {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "FOLLOW" {
                    await acceptConnectionRequest(token: albertToken, requestId: requestId, senderName: "Followers")
                }
            }
        }
        
        if let pendingFridaFollows = await getPendingRequests(token: fridaToken) {
            for request in pendingFridaFollows {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "FOLLOW" {
                    await acceptConnectionRequest(token: fridaToken, requestId: requestId, senderName: "Followers")
                }
            }
        }
        
        if let pendingLeonardoFollows = await getPendingRequests(token: leonardoToken) {
            for request in pendingLeonardoFollows {
                if let requestId = request["id"] as? String,
                   let type = request["type"] as? String,
                   type == "FOLLOW" {
                    await acceptConnectionRequest(token: leonardoToken, requestId: requestId, senderName: "Followers")
                }
            }
        }
        
        print("✅ Additional connections created and accepted!")
        print("⏳ Waiting for all connections to fully settle...")
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
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
        
        print("⏳ Waiting for group creation to settle...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        print("\n📨 Inviting musicians to the group...")
        
        let musicianIds = [johnnyCashUserId, janeUserId, billyUserId, bobMarleyUserId]
        await inviteToGroup(token: jackToken, groupId: musiciansGroupId, userIds: musicianIds)
        
        print("⏳ Waiting for invites to settle...")
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        print("\n✋ Musicians accepting group invites...")
        await acceptGroupInvite(token: johnnyCashToken, groupId: musiciansGroupId, userName: "Johnny Cash")
        await acceptGroupInvite(token: janeToken, groupId: musiciansGroupId, userName: "Jane Doe")
        await acceptGroupInvite(token: billyToken, groupId: musiciansGroupId, userName: "Billy Bob")
        await acceptGroupInvite(token: bobMarleyToken, groupId: musiciansGroupId, userName: "Bob Marley")
        
        await createAdditionalGroups(userTokens: userTokens)
        
        await createSubnets(userTokens: userTokens)
        
        print("\n📝 Creating posts from users...")
        await createPosts(userTokens: userTokens)
        
        print("\n✅ Connection setup complete!")
    }
    
    private static func createPosts(userTokens: [String: String]) async {
        if let token = userTokens["johnny@cash.com"] {
            await createPost(token: token, content: "Just finished recording a new track. There's something special about that deep, resonant sound. Walk the line, friends. 🎸", userName: "Johnny Cash")
            await createPost(token: token, content: "Music has always been my way of telling stories. Every song is a journey, every chord a memory.", userName: "Johnny Cash")
        }
        
        if let token = userTokens["bob@marley.com"] {
            await createPost(token: token, content: "One good thing about music, when it hits you, you feel no pain. Keep spreading the love and positivity. ✌️", userName: "Bob Marley")
            await createPost(token: token, content: "Don't worry about a thing, cause every little thing is gonna be alright. Have a blessed day everyone!", userName: "Bob Marley")
        }
        
        if let token = userTokens["jack@johnson.com"] {
            await createPost(token: token, content: "Beach session today with the guitar. Nothing beats the sound of waves and strings together 🌊🎸", userName: "Jack Johnson")
            await createPost(token: token, content: "Just discovered an amazing local band. Supporting live music is so important!", userName: "Jack Johnson")
        }
        
        if let token = userTokens["jane@doe.com"] {
            await createPost(token: token, content: "Working on a new design project inspired by music and visual art. The creative process is magical! 🎨", userName: "Jane Doe")
            await createPost(token: token, content: "Sometimes the best designs come from unexpected places. Stay curious, stay inspired!", userName: "Jane Doe")
        }
        
        if let token = userTokens["billy@bob.com"] {
            await createPost(token: token, content: "Hiked 12 miles today and the views were absolutely worth it! Nature is the best medicine. 🏔️", userName: "Billy Bob")
            await createPost(token: token, content: "Planning next weekend's camping trip. Who else loves sleeping under the stars?", userName: "Billy Bob")
        }
        
        if let token = userTokens["harry@truman.com"] {
            await createPost(token: token, content: "Reading a fascinating biography on American political history. The past has so much to teach us about the present.", userName: "Harry Truman")
            await createPost(token: token, content: "Coffee and philosophy this morning. What's everyone reading these days?", userName: "Harry Truman")
        }
        
        if let token = userTokens["john@smith.com"] {
            await createPost(token: token, content: "Just learned about a new technology that could revolutionize how we approach problem-solving. Innovation never stops!", userName: "John Smith")
            await createPost(token: token, content: "Sharing knowledge is one of the most powerful things we can do. Always happy to help others learn.", userName: "John Smith")
        }
        
        if let token = userTokens["dave@chappelle.com"] {
            await createPost(token: token, content: "You know what's funny? Life. Just pay attention and you'll see the comedy everywhere. 😄", userName: "Dave Chappelle")
            await createPost(token: token, content: "Laughter is the best medicine. Unless you're diabetic, then insulin is pretty important too. But after that, laughter!", userName: "Dave Chappelle")
        }
        
        if let token = userTokens["tom@brady.com"] {
            await createPost(token: token, content: "Another day, another opportunity to be better than yesterday. Hard work and discipline pay off! 💪", userName: "Tom Brady")
            await createPost(token: token, content: "Success isn't just about talent—it's about commitment, preparation, and never giving up.", userName: "Tom Brady")
        }
        
        if let token = userTokens["john@doe.com"] {
            await createPost(token: token, content: "Solved a really challenging coding problem today. There's nothing quite like that 'aha!' moment when everything clicks.", userName: "John Doe")
            await createPost(token: token, content: "Building software that helps people is incredibly rewarding. Love what I do!", userName: "John Doe")
        }
        
        if let token = userTokens["john@kennedy.com"] {
            await createPost(token: token, content: "Community engagement event was a success! When we work together, amazing things happen. 🇺🇸", userName: "John Kennedy")
            await createPost(token: token, content: "Ask not what your community can do for you, but what you can do for your community.", userName: "John Kennedy")
        }
        
        if let token = userTokens["marie@curie.com"] {
            await createPost(token: token, content: "In science, we must be interested in things, not in persons. The work is what matters! 🔬", userName: "Marie Curie")
            await createPost(token: token, content: "Nothing in life is to be feared, it is only to be understood. Keep learning and exploring!", userName: "Marie Curie")
        }
        
        if let token = userTokens["albert@einstein.com"] {
            await createPost(token: token, content: "The important thing is not to stop questioning. Curiosity has its own reason for existing. 🌌", userName: "Albert Einstein")
            await createPost(token: token, content: "Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.", userName: "Albert Einstein")
        }
        
        if let token = userTokens["amelia@earhart.com"] {
            await createPost(token: token, content: "The most effective way to do it, is to do it. Adventure is worthwhile in itself! ✈️", userName: "Amelia Earhart")
            await createPost(token: token, content: "Flying solo across new territories. The sky isn't the limit—it's just the beginning.", userName: "Amelia Earhart")
        }
        
        if let token = userTokens["leonardo@davinci.com"] {
            await createPost(token: token, content: "Learning never exhausts the mind. Art and science are not opposites—they complement each other. 🎨", userName: "Leonardo da Vinci")
            await createPost(token: token, content: "Simplicity is the ultimate sophistication. Working on a new piece inspired by nature.", userName: "Leonardo da Vinci")
        }
        
        if let token = userTokens["rosa@parks.com"] {
            await createPost(token: token, content: "Stand for something or you will fall for anything. Each person must live their life as a model for others. ✊", userName: "Rosa Parks")
            await createPost(token: token, content: "I have learned over the years that when one's mind is made up, this diminishes fear.", userName: "Rosa Parks")
        }
        
        if let token = userTokens["winston@churchill.com"] {
            await createPost(token: token, content: "Success is not final, failure is not fatal: it is the courage to continue that counts. 🎖️", userName: "Winston Churchill")
            await createPost(token: token, content: "We make a living by what we get, but we make a life by what we give. Stay determined!", userName: "Winston Churchill")
        }
        
        if let token = userTokens["frida@kahlo.com"] {
            await createPost(token: token, content: "I paint myself because I am so often alone and because I am the subject I know best. 🌺", userName: "Frida Kahlo")
            await createPost(token: token, content: "Feet, what do I need you for when I have wings to fly? Art is my freedom!", userName: "Frida Kahlo")
        }
        
        if let token = userTokens["muhammad@ali.com"] {
            await createPost(token: token, content: "Float like a butterfly, sting like a bee! The fight is won or lost far away from witnesses. 🥊", userName: "Muhammad Ali")
            await createPost(token: token, content: "Don't count the days, make the days count. Champions aren't made in gyms—they're made from something deep inside.", userName: "Muhammad Ali")
        }
        
        if let token = userTokens["maya@angelou.com"] {
            await createPost(token: token, content: "There is no greater agony than bearing an untold story inside you. Write, speak, create! ✍️", userName: "Maya Angelou")
            await createPost(token: token, content: "We delight in the beauty of the butterfly, but rarely admit the changes it has gone through to achieve that beauty.", userName: "Maya Angelou")
        }
        
        if let token = userTokens["nelson@mandela.com"] {
            await createPost(token: token, content: "Education is the most powerful weapon which you can use to change the world. 📚", userName: "Nelson Mandela")
            await createPost(token: token, content: "It always seems impossible until it's done. Keep fighting for what's right!", userName: "Nelson Mandela")
        }
        
        if let token = userTokens["harriet@tubman.com"] {
            await createPost(token: token, content: "Every great dream begins with a dreamer. Always remember, you have within you the strength to reach for the stars. 🌟", userName: "Harriet Tubman")
            await createPost(token: token, content: "I freed a thousand slaves. I could have freed a thousand more if only they knew they were slaves.", userName: "Harriet Tubman")
        }
        
        if let token = userTokens["nikola@tesla.com"] {
            await createPost(token: token, content: "The present is theirs; the future, for which I really worked, is mine. ⚡", userName: "Nikola Tesla")
            await createPost(token: token, content: "If you want to find the secrets of the universe, think in terms of energy, frequency and vibration.", userName: "Nikola Tesla")
        }
        
        if let token = userTokens["ella@fitzgerald.com"] {
            await createPost(token: token, content: "It isn't where you came from, it's where you're going that counts. 🎵", userName: "Ella Fitzgerald")
            await createPost(token: token, content: "Just don't give up trying to do what you really want to do. Where there is love and inspiration, you can't go wrong.", userName: "Ella Fitzgerald")
        }
        
        if let token = userTokens["martin@king.com"] {
            await createPost(token: token, content: "I have a dream that one day this nation will rise up and live out the true meaning of its creed. ✊", userName: "Martin Luther King")
            if let postId = await createPost(token: token, content: "Darkness cannot drive out darkness; only light can do that. Hate cannot drive out hate; only love can do that.", userName: "Martin Luther King") {
                if let rosaToken = userTokens["rosa@parks.com"] {
                    await createComment(token: rosaToken, postId: postId, content: "Powerful words that still ring true today. Thank you for your leadership.", userName: "Rosa Parks")
                }
                if let nelsonToken = userTokens["nelson@mandela.com"] {
                    await createComment(token: nelsonToken, postId: postId, content: "Your message of nonviolence and love inspired my own journey. We must continue this work.", userName: "Nelson Mandela")
                }
                if let mayaToken = userTokens["maya@angelou.com"] {
                    await createComment(token: mayaToken, postId: postId, content: "Light and love are the only weapons that truly transform hearts. Beautiful reminder!", userName: "Maya Angelou")
                }
            }
        }
        
        if let token = userTokens["cleopatra@egypt.com"] {
            await createPost(token: token, content: "I will not be triumphed over. Leadership is about vision, strategy, and the courage to act. 👑", userName: "Cleopatra")
            if let postId = await createPost(token: token, content: "All strange and terrible events are welcome, but comforts we despise. History favors the bold!", userName: "Cleopatra") {
                if let winstonToken = userTokens["winston@churchill.com"] {
                    await createComment(token: winstonToken, postId: postId, content: "Courage is what it takes to stand up and speak. Well said!", userName: "Winston Churchill")
                }
                if let leonardoToken = userTokens["leonardo@davinci.com"] {
                    await createComment(token: leonardoToken, postId: postId, content: "Boldness has genius, power, and magic in it. The bold create history.", userName: "Leonardo da Vinci")
                }
            }
        }
    }
    
    private static func createAdditionalGroups(userTokens: [String: String]) async {
        print("\n🎯 Creating additional groups...")
        
        guard let johnnyCashToken = userTokens["johnny@cash.com"],
              let johnnyCashUserId = await getUserId(token: johnnyCashToken),
              let albertToken = userTokens["albert@einstein.com"],
              let albertUserId = await getUserId(token: albertToken),
              let marieUserId = await getUserId(token: userTokens["marie@curie.com"] ?? ""),
              let leonardoUserId = await getUserId(token: userTokens["leonardo@davinci.com"] ?? ""),
              let rosaToken = userTokens["rosa@parks.com"],
              let rosaUserId = await getUserId(token: rosaToken),
              let nelsonUserId = await getUserId(token: userTokens["nelson@mandela.com"] ?? ""),
              let mayaUserId = await getUserId(token: userTokens["maya@angelou.com"] ?? ""),
              let muhammadToken = userTokens["muhammad@ali.com"],
              let muhammadUserId = await getUserId(token: muhammadToken),
              let tomUserId = await getUserId(token: userTokens["tom@brady.com"] ?? ""),
              let billyUserId = await getUserId(token: userTokens["billy@bob.com"] ?? ""),
              let ameliaUserId = await getUserId(token: userTokens["amelia@earhart.com"] ?? ""),
              let fridaUserId = await getUserId(token: userTokens["frida@kahlo.com"] ?? ""),
              let janeUserId = await getUserId(token: userTokens["jane@doe.com"] ?? ""),
              let winstonToken = userTokens["winston@churchill.com"],
              let winstonUserId = await getUserId(token: winstonToken),
              let harrietUserId = await getUserId(token: userTokens["harriet@tubman.com"] ?? ""),
              let nikolaUserId = await getUserId(token: userTokens["nikola@tesla.com"] ?? ""),
              let ellaUserId = await getUserId(token: userTokens["ella@fitzgerald.com"] ?? ""),
              let martinUserId = await getUserId(token: userTokens["martin@king.com"] ?? ""),
              let cleopatraUserId = await getUserId(token: userTokens["cleopatra@egypt.com"] ?? "") else {
            print("❌ Failed to get required user IDs for additional groups")
            return
        }
        
        if let scienceGroupId = await createGroup(
            token: albertToken,
            name: "Science & Innovation",
            description: "For curious minds exploring the mysteries of the universe",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created Science & Innovation group")
            await inviteToGroup(token: albertToken, groupId: scienceGroupId, userIds: [marieUserId, leonardoUserId, janeUserId, nikolaUserId, harrietUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let marieToken = userTokens["marie@curie.com"] {
                await acceptGroupInvite(token: marieToken, groupId: scienceGroupId, userName: "Marie Curie")
            }
            if let leonardoToken = userTokens["leonardo@davinci.com"] {
                await acceptGroupInvite(token: leonardoToken, groupId: scienceGroupId, userName: "Leonardo da Vinci")
            }
            if let janeToken = userTokens["jane@doe.com"] {
                await acceptGroupInvite(token: janeToken, groupId: scienceGroupId, userName: "Jane Doe")
            }
            if let nikolaToken = userTokens["nikola@tesla.com"] {
                await acceptGroupInvite(token: nikolaToken, groupId: scienceGroupId, userName: "Nikola Tesla")
            }
            if let harrietToken = userTokens["harriet@tubman.com"] {
                await acceptGroupInvite(token: harrietToken, groupId: scienceGroupId, userName: "Harriet Tubman")
            }
        }
        
        if let championsGroupId = await createGroup(
            token: muhammadToken,
            name: "Champions Circle",
            description: "Winners supporting winners. Discipline, dedication, excellence.",
            groupType: "AUTOCRATIC",
            privacy: "PRIVATE"
        ) {
            print("✅ Created Champions Circle group")
            await inviteToGroup(token: muhammadToken, groupId: championsGroupId, userIds: [tomUserId, johnnyCashUserId, ameliaUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let tomToken = userTokens["tom@brady.com"] {
                await acceptGroupInvite(token: tomToken, groupId: championsGroupId, userName: "Tom Brady")
            }
            await acceptGroupInvite(token: johnnyCashToken, groupId: championsGroupId, userName: "Johnny Cash")
            if let ameliaToken = userTokens["amelia@earhart.com"] {
                await acceptGroupInvite(token: ameliaToken, groupId: championsGroupId, userName: "Amelia Earhart")
            }
        }
        
        if let changeMakersGroupId = await createGroup(
            token: rosaToken,
            name: "Change Makers",
            description: "Those who stand up, speak out, and make a difference",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created Change Makers group")
            await inviteToGroup(token: rosaToken, groupId: changeMakersGroupId, userIds: [nelsonUserId, mayaUserId, winstonUserId, janeUserId, martinUserId, harrietUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let nelsonToken = userTokens["nelson@mandela.com"] {
                await acceptGroupInvite(token: nelsonToken, groupId: changeMakersGroupId, userName: "Nelson Mandela")
            }
            if let mayaToken = userTokens["maya@angelou.com"] {
                await acceptGroupInvite(token: mayaToken, groupId: changeMakersGroupId, userName: "Maya Angelou")
            }
            await acceptGroupInvite(token: winstonToken, groupId: changeMakersGroupId, userName: "Winston Churchill")
            if let janeToken = userTokens["jane@doe.com"] {
                await acceptGroupInvite(token: janeToken, groupId: changeMakersGroupId, userName: "Jane Doe")
            }
            if let martinToken = userTokens["martin@king.com"] {
                await acceptGroupInvite(token: martinToken, groupId: changeMakersGroupId, userName: "Martin Luther King")
            }
            if let harrietToken = userTokens["harriet@tubman.com"] {
                await acceptGroupInvite(token: harrietToken, groupId: changeMakersGroupId, userName: "Harriet Tubman")
            }
        }
        
        if let fridaToken = userTokens["frida@kahlo.com"],
           let creativeSoulsGroupId = await createGroup(
            token: fridaToken,
            name: "Creative Souls",
            description: "Artists, dreamers, and creators sharing inspiration",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created Creative Souls group")
            await inviteToGroup(token: fridaToken, groupId: creativeSoulsGroupId, userIds: [leonardoUserId, janeUserId, johnnyCashUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let leonardoToken = userTokens["leonardo@davinci.com"] {
                await acceptGroupInvite(token: leonardoToken, groupId: creativeSoulsGroupId, userName: "Leonardo da Vinci")
            }
            if let janeToken = userTokens["jane@doe.com"] {
                await acceptGroupInvite(token: janeToken, groupId: creativeSoulsGroupId, userName: "Jane Doe")
            }
            await acceptGroupInvite(token: johnnyCashToken, groupId: creativeSoulsGroupId, userName: "Johnny Cash")
        }
        
        if let ameliaToken = userTokens["amelia@earhart.com"],
           let adventureGroupId = await createGroup(
            token: ameliaToken,
            name: "Adventure Seekers",
            description: "For those who dare to explore the unknown",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created Adventure Seekers group")
            await inviteToGroup(token: ameliaToken, groupId: adventureGroupId, userIds: [billyUserId, janeUserId, cleopatraUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if let billyToken = userTokens["billy@bob.com"] {
                await acceptGroupInvite(token: billyToken, groupId: adventureGroupId, userName: "Billy Bob")
            }
            if let janeToken = userTokens["jane@doe.com"] {
                await acceptGroupInvite(token: janeToken, groupId: adventureGroupId, userName: "Jane Doe")
            }
            if let cleopatraToken = userTokens["cleopatra@egypt.com"] {
                await acceptGroupInvite(token: cleopatraToken, groupId: adventureGroupId, userName: "Cleopatra")
            }
        }
        
        if let ellaToken = userTokens["ella@fitzgerald.com"],
           let jazzGroupId = await createGroup(
            token: ellaToken,
            name: "Jazz & Soul",
            description: "For lovers of jazz, blues, and soulful music",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created Jazz & Soul group")
            if let bobMarleyUserId = await getUserId(token: userTokens["bob@marley.com"] ?? ""),
               let mayaUserId = await getUserId(token: userTokens["maya@angelou.com"] ?? "") {
                await inviteToGroup(token: ellaToken, groupId: jazzGroupId, userIds: [bobMarleyUserId, mayaUserId, nikolaUserId])
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if let bobMarleyToken = userTokens["bob@marley.com"] {
                    await acceptGroupInvite(token: bobMarleyToken, groupId: jazzGroupId, userName: "Bob Marley")
                }
                if let mayaToken = userTokens["maya@angelou.com"] {
                    await acceptGroupInvite(token: mayaToken, groupId: jazzGroupId, userName: "Maya Angelou")
                }
                if let nikolaToken = userTokens["nikola@tesla.com"] {
                    await acceptGroupInvite(token: nikolaToken, groupId: jazzGroupId, userName: "Nikola Tesla")
                }
            }
        }
        
        if let cleopatraToken = userTokens["cleopatra@egypt.com"],
           let historyGroupId = await createGroup(
            token: cleopatraToken,
            name: "History Buffs",
            description: "Discussing and celebrating history's greatest moments",
            groupType: "AUTOCRATIC",
            privacy: "PUBLIC"
        ) {
            print("✅ Created History Buffs group")
            await inviteToGroup(token: cleopatraToken, groupId: historyGroupId, userIds: [winstonUserId, nelsonUserId, harrietUserId, martinUserId])
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await acceptGroupInvite(token: winstonToken, groupId: historyGroupId, userName: "Winston Churchill")
            if let nelsonToken = userTokens["nelson@mandela.com"] {
                await acceptGroupInvite(token: nelsonToken, groupId: historyGroupId, userName: "Nelson Mandela")
            }
            if let harrietToken = userTokens["harriet@tubman.com"] {
                await acceptGroupInvite(token: harrietToken, groupId: historyGroupId, userName: "Harriet Tubman")
            }
            if let martinToken = userTokens["martin@king.com"] {
                await acceptGroupInvite(token: martinToken, groupId: historyGroupId, userName: "Martin Luther King")
            }
        }
    }
    
    private static func createSubnets(userTokens: [String: String]) async {
        print("\n🔗 Creating subnets...")
        
        guard let johnnyCashToken = userTokens["johnny@cash.com"],
              let johnnyCashUserId = await getUserId(token: johnnyCashToken),
              let jackToken = userTokens["jack@johnson.com"],
              let jackUserId = await getUserId(token: jackToken),
              let johnSmithToken = userTokens["john@smith.com"],
              let johnSmithUserId = await getUserId(token: johnSmithToken),
              let janeUserId = await getUserId(token: userTokens["jane@doe.com"] ?? ""),
              let bobMarleyUserId = await getUserId(token: userTokens["bob@marley.com"] ?? ""),
              let albertUserId = await getUserId(token: userTokens["albert@einstein.com"] ?? ""),
              let fridaUserId = await getUserId(token: userTokens["frida@kahlo.com"] ?? "") else {
            print("❌ Failed to get required user IDs for subnets")
            return
        }
        
        if let musicProjectsSubnet = await createSubnet(
            token: johnnyCashToken,
            name: "Music Projects",
            description: "My ongoing musical endeavors and collaborations",
            visibility: "PUBLIC"
        ) {
            print("✅ Created Johnny's Music Projects subnet")
            await addSubnetMembers(token: johnnyCashToken, subnetId: musicProjectsSubnet, userIds: [jackUserId, bobMarleyUserId])
        }
        
        if let tourMemoriesSubnet = await createSubnet(
            token: johnnyCashToken,
            name: "Tour Memories",
            description: "Stories and photos from the road",
            visibility: "CONNECTIONS"
        ) {
            print("✅ Created Johnny's Tour Memories subnet")
            await addSubnetMembers(token: johnnyCashToken, subnetId: tourMemoriesSubnet, userIds: [jackUserId, janeUserId])
        }
        
        if let creativesSubnet = await createSubnet(
            token: johnnyCashToken,
            name: "Fellow Creatives",
            description: "Connecting with other artists and thinkers",
            visibility: "ACQUAINTANCES"
        ) {
            print("✅ Created Johnny's Fellow Creatives subnet")
            await addSubnetMembers(token: johnnyCashToken, subnetId: creativesSubnet, userIds: [fridaUserId, albertUserId, janeUserId])
        }
        
        if let surfAndSoundSubnet = await createSubnet(
            token: jackToken,
            name: "Surf & Sound",
            description: "Where music meets the ocean",
            visibility: "PUBLIC"
        ) {
            print("✅ Created Jack's Surf & Sound subnet")
            await addSubnetMembers(token: jackToken, subnetId: surfAndSoundSubnet, userIds: [johnnyCashUserId, bobMarleyUserId])
        }
        
        if let techInnovatorsSubnet = await createSubnet(
            token: johnSmithToken,
            name: "Tech Innovators",
            description: "Exploring cutting-edge technology and innovation",
            visibility: "PUBLIC"
        ) {
            print("✅ Created John Smith's Tech Innovators subnet")
            await addSubnetMembers(token: johnSmithToken, subnetId: techInnovatorsSubnet, userIds: [albertUserId, johnnyCashUserId])
        }
    }
    
    private static func createPost(token: String, content: String, userName: String) async -> String? {
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
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ Created post from \(userName)")
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let postId = json["postId"] as? String {
                    return postId
                }
            } else {
                print("❌ Failed to create post from \(userName)")
            }
        } catch {
            print("❌ Error creating post from \(userName): \(error.localizedDescription)")
        }
        return nil
    }
    
    private static func createComment(token: String, postId: String, content: String, userName: String) async {
        let url = AppConfig.baseURL.appendingPathComponent("posts/\(postId)/comments")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let commentData: [String: Any] = [
            "content": content
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: commentData)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ Created comment from \(userName)")
            } else {
                print("❌ Failed to create comment from \(userName)")
            }
        } catch {
            print("❌ Error creating comment from \(userName): \(error.localizedDescription)")
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
        let url = AppConfig.baseURL
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5 // 5 second timeout
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
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
    
    private static func createSubnet(token: String, name: String, description: String, visibility: String) async -> String? {
        let url = AppConfig.baseURL.appendingPathComponent("subnets")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let subnetData: [String: Any] = [
            "name": name,
            "description": description,
            "visibility": visibility
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: subnetData)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let subnetId = json["id"] as? String {
                    return subnetId
                }
            }
        } catch {
            print("❌ Error creating subnet: \(error.localizedDescription)")
        }
        return nil
    }
    
    private static func addSubnetMembers(token: String, subnetId: String, userIds: [String]) async {
        let url = AppConfig.baseURL.appendingPathComponent("subnets/\(subnetId)/members")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let memberData: [String: Any] = ["userIds": userIds]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: memberData)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("✅ Added \(userIds.count) member(s) to subnet")
            } else {
                print("❌ Failed to add members to subnet")
            }
        } catch {
            print("❌ Error adding subnet members: \(error.localizedDescription)")
        }
    }
}
