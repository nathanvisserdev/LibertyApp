//
//  SearchViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-13.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [User] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newQuery in
                self?.searchUsers(email: newQuery)
            }
            .store(in: &cancellables)
    }

    func searchUsers(email: String) {
        // Replace with your actual user fetching logic
        let allUsers: [User] = [
            User(id: 1, email: "alice@example.com"),
            User(id: 2, email: "bob@example.com"),
            User(id: 3, email: "carol@example.com")
        ]
        if email.isEmpty {
            results = []
        } else {
            results = allUsers.filter { $0.email.lowercased().contains(email.lowercased()) }
        }
    }
}

struct User: Identifiable {
    let id: Int
    let email: String
}
