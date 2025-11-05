//
//  SearchView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-13.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @ObservedObject private var coordinator: SearchCoordinator
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    init(
        viewModel: SearchViewModel,
        coordinator: SearchCoordinator
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack {
            VStack {
                queryField
                submitButton
                errorBanner
                resultsContainer
            }
            .navigationTitle("Search")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .sheet(isPresented: $coordinator.isShowingProfile) {
                coordinator.makeProfileView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Pieces

    private var queryField: some View {
        TextField("User or Group", text: $viewModel.query)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($isTextFieldFocused)
            .padding(.horizontal)
            .padding(.top)
    }

    private var submitButton: some View {
        Button {
            Task { await viewModel.performSearch() }
            isTextFieldFocused = false
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Submit").fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(viewModel.query.isEmpty ? Color.gray : Color(red: 0.2, green: 0.5, blue: 0.9))
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(viewModel.query.isEmpty || viewModel.isLoading)
        .padding(.horizontal)
    }

    private var errorBanner: some View {
        Group {
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red).font(.caption).padding(.horizontal)
            }
        }
    }

    private var resultsContainer: some View {
        Group {
            if viewModel.users.isEmpty,
               viewModel.groups.isEmpty,
               !viewModel.query.isEmpty,
               !viewModel.isLoading {
                VStack { Spacer(); Text("No results found").foregroundColor(.gray); Spacer() }
            } else {
                resultsList
            }
        }
    }

    private var resultsList: some View {
        List {
            if !viewModel.users.isEmpty { usersSection }
            if !viewModel.groups.isEmpty { groupsSection }
        }
        .listStyle(.plain)
    }

    private var usersSection: some View {
        Section(header: Text("Users")) {
            ForEach(viewModel.users, id: \.id) { user in
                Button {
                    viewModel.selectUser(userId: user.id)
                } label: {
                    UserRow(
                        fullName: "\(user.firstName) \(user.lastName)",
                        username: user.username
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var groupsSection: some View {
        Section(header: Text("Groups")) {
            ForEach(viewModel.groups, id: \.id) { group in
                SearchGroupRow(name: group.name, type: group.groupType)
            }
        }
    }
}

// MARK: - Rows

private struct UserRow: View {
    let fullName: String
    let username: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(fullName).font(.headline)
            Text("@\(username)").font(.subheadline).foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

private struct SearchGroupRow: View {
    let name: String
    let type: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.headline)
            Text(type).font(.caption).foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
