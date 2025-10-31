//
//  SubnetMenuView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

struct SubnetMenuView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SubnetMenuViewModel
    @StateObject private var subnetViewModel = SubnetListViewModel()
    
    init(viewModel: SubnetMenuViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if subnetViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else if let errorMessage = subnetViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else if subnetViewModel.subnets.isEmpty {
                        Text("No subnets yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(subnetViewModel.subnets) { subnet in
                            Button {
                                subnetViewModel.selectSubnet(subnet)
                                viewModel.showSubnet()
                            } label: {
                                HStack(spacing: 12) {
                                    // Icon based on visibility or default status
                                    Image(systemName: subnet.isDefault ? "star.circle.fill" : visibilityIcon(for: subnet.visibility))
                                        .font(.title2)
                                        .foregroundColor(subnet.isDefault ? .yellow : visibilityColor(for: subnet.visibility))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subnet.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        if let description = subnet.description, !description.isEmpty {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        // Show member/post counts
                                        HStack(spacing: 8) {
                                            Label("\(subnet.memberCount)", systemImage: "person.2")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            
                                            Label("\(subnet.postCount)", systemImage: "doc.text")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Subnets")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Subnets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await subnetViewModel.fetchSubnets()
            }
            .sheet(isPresented: $viewModel.showSubnetView) {
                let coordinator = SubnetCoordinator(subnetListViewModel: subnetViewModel)
                coordinator.start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // Helper functions for subnet visibility icons/colors
    private func visibilityIcon(for visibility: String) -> String {
        switch visibility {
        case "PUBLIC":
            return "globe"
        case "CONNECTIONS":
            return "person.2.fill"
        case "ACQUAINTANCES":
            return "person.fill"
        case "PRIVATE":
            return "lock.fill"
        default:
            return "lock.fill"
        }
    }
    
    private func visibilityColor(for visibility: String) -> Color {
        switch visibility {
        case "PUBLIC":
            return .blue
        case "CONNECTIONS":
            return .green
        case "ACQUAINTANCES":
            return .orange
        case "PRIVATE":
            return .purple
        default:
            return .purple
        }
    }
}

#Preview {
    SubnetMenuView(viewModel: SubnetMenuViewModel())
}

