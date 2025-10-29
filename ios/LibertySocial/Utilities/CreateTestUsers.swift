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
}

class CreateTestUsers {
    static let testUsers: [TestUserData] = [
        TestUserData(
            firstName: "Jack",
            lastName: "Johnson",
            email: "Jack@johnson.com",
            password: "Password1",
            username: "JackJohnson",
            dateOfBirth: "1990-10-22",
            gender: "MALE",
            isPrivate: false,
            profilePhoto: "default_profile.jpg"
        )
    ]
    
    static func createAllUsers() async -> TestUsersResult {
        print("🚀 Starting to create test users...")
        
        var successCount = 0
        var failedUsers: [String] = []
        
        for (index, user) in testUsers.enumerated() {
            let success = await createUser(user, index: index + 1)
            if success {
                successCount += 1
            } else {
                failedUsers.append(user.username)
            }
        }
        
        let totalUsers = testUsers.count
        
        if successCount == totalUsers {
            let message = "✅ Successfully created all \(totalUsers) test users!"
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
    
    private static func createUser(_ user: TestUserData, index: Int) async -> Bool {
        let url = AppConfig.baseURL.appendingPathComponent("signup")
        
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
            "profilePhoto": user.profilePhoto
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: signupData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("✅ [\(index)/5] Created user: \(user.username) (private: \(user.isPrivate))")
                    return true
                } else {
                    print("❌ [\(index)/5] Failed to create \(user.username): Status \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   Response: \(responseString)")
                    }
                    return false
                }
            }
            return false
        } catch {
            print("❌ [\(index)/5] Error creating \(user.username): \(error.localizedDescription)")
            return false
        }
    }
}
