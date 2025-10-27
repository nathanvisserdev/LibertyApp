//
//  CreateGroupView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: CreateGroupViewModel
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        _viewModel = StateObject(wrappedValue: CreateGroupViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $viewModel.name)
                        .autocorrectionDisabled()
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.remainingNameCharacters)")
                            .font(.caption)
                            .foregroundStyle(viewModel.remainingNameCharacters < 0 ? .red : .secondary)
                    }
                } header: {
                    Text("Name")
                } footer: {
                    Text("Maximum \(viewModel.maxNameCharacters) characters")
                        .font(.caption)
                }
                
                Section {
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 100)
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.remainingDescriptionCharacters)")
                            .font(.caption)
                            .foregroundStyle(viewModel.remainingDescriptionCharacters < 0 ? .red : .secondary)
                    }
                } header: {
                    Text("Description (Optional)")
                } footer: {
                    Text("Maximum \(viewModel.maxDescriptionCharacters) characters")
                        .font(.caption)
                }
                
                Section {
                    Picker("Privacy", selection: $viewModel.selectedGroupType) {
                        ForEach(GroupType.allCases, id: \.self) { type in
                            VStack(alignment: .leading) {
                                Text(type.displayName)
                                    .font(.body)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Privacy")
                }
                
                Section {
                    Toggle("Hidden Group", isOn: $viewModel.isHidden)
                } header: {
                    Text("Visibility")
                } footer: {
                    Text("Hidden groups are not visible in search results and require premium membership")
                        .font(.caption)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            let success = await viewModel.submit()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                }
            }
            .disabled(viewModel.isSubmitting)
        }
    }
}

#Preview {
    CreateGroupView()
}

