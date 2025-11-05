//
//  ProfileViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: ProfileModel
    private let makeMediaVM: (String) -> MediaViewModel
    private let authenticationManager: AuthManaging

    // MARK: - Published
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOwnProfile: Bool = false

    // MARK: - Init
    init(
        model: ProfileModel,
        makeMediaVM: @escaping (String) -> MediaViewModel,
        authenticationManager: AuthManaging
    ) {
        self.model = model
        self.makeMediaVM = makeMediaVM
        self.authenticationManager = authenticationManager
    }

    // MARK: - Media VM Factory
    func makeMediaViewModel(for mediaKey: String) -> MediaViewModel {
        makeMediaVM(mediaKey)
    }

    // MARK: - Intents
    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            profile = try await model.fetchUserProfile(userId: userId)
            isOwnProfile = await checkIfOwnProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers
    private func checkIfOwnProfile(userId: String) async -> Bool {
        do {
            let currentUser = try await authenticationManager.fetchCurrentUserTyped()
            // Assumes the typed user has an `id: String` property.
            return currentUser.id == userId
        } catch {
            print("❌ Failed to check if own profile: \(error)")
            return false
        }
    }
}
