//
//  SearchView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-13.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedUserId: String?

    var body: some View {
        NavigationView {
            VStack {
                TextField("User or Group", text: $viewModel.query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal)
                    .padding(.top)
                
                Button(action: {
                    Task {
                        await viewModel.searchUsers(query: viewModel.query)
                    }
                    isTextFieldFocused = false
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                    } else {
                        Text("Submit")
                            .fontWeight(.semibold)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                    }
                }
                .background(viewModel.query.isEmpty ? Color.gray : Color(red: 0.2, green: 0.5, blue: 0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.query.isEmpty || viewModel.isLoading)
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                // Results
                if viewModel.users.isEmpty && viewModel.groups.isEmpty && !viewModel.query.isEmpty && !viewModel.isLoading {
                    VStack {
                        Spacer()
                        Text("No results found")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    List {
                        if !viewModel.users.isEmpty {
                            Section(header: Text("Users")) {
                                ForEach(viewModel.users, id: \.id) { user in
                                    Button(action: {
                                        selectedUserId = user.id
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(user.firstName) \(user.lastName)")
                                                .font(.headline)
                                            Text("@\(user.username)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        if !viewModel.groups.isEmpty {
                            Section(header: Text("Groups")) {
                                ForEach(viewModel.groups, id: \.id) { group in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(group.name)
                                            .font(.headline)
                                        Text(group.groupType)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: Binding(
                get: { selectedUserId.map { UserIdWrapper(id: $0) } },
                set: { selectedUserId = $0?.id }
            )) { wrapper in
                ProfileView(viewModel: ProfileViewModel(), userId: wrapper.id)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
