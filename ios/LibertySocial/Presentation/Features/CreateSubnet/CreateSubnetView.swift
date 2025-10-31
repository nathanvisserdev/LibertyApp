//
//  CreateSubnetView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

struct CreateSubnetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: CreateSubnetViewModel
    
    init(viewModel: CreateSubnetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Example: Family", text: $viewModel.name)
                        .autocorrectionDisabled()
                } header: {
                    Text("Name")
                } footer: {
                    Text("Choose a descriptive name for your subnet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Description Section
                Section {
                    TextField("Description (optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Description")
                }
                
                // Visibility Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(SubNetVisibilityOption.allCases, id: \.self) { visibility in
                            Button(action: {
                                viewModel.selectedVisibility = visibility
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: viewModel.selectedVisibility == visibility ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(viewModel.selectedVisibility == visibility ? .accentColor : .gray)
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(visibility.displayName)
                                            .foregroundColor(.primary)
                                            .font(.body)
                                        
                                        Text(visibility.description)
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Visibility")
                } footer: {
                    Text("Control who can see this subnet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Default Subnet Toggle
                Section {
                    Toggle(isOn: $viewModel.isDefault) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Set as Default Subnet")
                                .font(.body)
                            Text("Posts will be shared to this subnet by default")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Create Button
                Section {
                    Button(action: {
                        Task {
                            await viewModel.submit()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Subnet")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(viewModel.canSubmit && !viewModel.isSubmitting ? Color.blue : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create Subnet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    viewModel.dismissSuccessAlert()
                }
            } message: {
                Text(viewModel.successMessage)
            }
            .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - SubNetVisibilityOption Enum
enum SubNetVisibilityOption: String, CaseIterable {
    case privateVisibility = "PRIVATE"
    case acquaintances = "ACQUAINTANCES"
    case connections = "CONNECTIONS"
    case publicVisibility = "PUBLIC"
    
    var displayName: String {
        switch self {
        case .privateVisibility:
            return "Private"
        case .acquaintances:
            return "Acquaintances"
        case .connections:
            return "Connections"
        case .publicVisibility:
            return "Public"
        }
    }
    
    var description: String {
        switch self {
        case .privateVisibility:
            return "Only you can see this subnet"
        case .acquaintances:
            return "Visible to your acquaintances"
        case .connections:
            return "Visible to all your connections"
        case .publicVisibility:
            return "Visible to everyone"
        }
    }
}

#Preview {
    CreateSubnetView(viewModel: CreateSubnetViewModel())
}
