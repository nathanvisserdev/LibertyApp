//
//  SearchViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-13.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var users: [SearchUser] = []
    @Published var groups: [SearchGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func searchUsers(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            users = []
            groups = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await AuthService.searchUsers(query: query.trimmingCharacters(in: .whitespacesAndNewlines))
            users = result.users
            groups = result.groups
        } catch {
            errorMessage = error.localizedDescription
            users = []
            groups = []
        }
        
        isLoading = false
    }
}
