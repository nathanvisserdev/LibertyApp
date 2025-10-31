//
//  SearchViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-13.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: SearchModel
    
    // MARK: - Published (Input State)
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State)
    @Published var users: [SearchUser] = []
    @Published var groups: [SearchGroup] = []
    
    // MARK: - Init
    init(model: SearchModel = SearchModel()) {
        self.model = model
    }

    // MARK: - Intents (User Actions)
    func performSearch() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            users = []
            groups = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await model.searchUsers(query: trimmedQuery)
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
