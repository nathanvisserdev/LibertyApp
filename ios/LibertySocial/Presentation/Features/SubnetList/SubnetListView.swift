
import SwiftUI

struct SubnetListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SubnetListViewModel
    
    init(viewModel: SubnetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Button {
                    viewModel.showCreateSubnetView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Create Subnet")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else if viewModel.subnets.isEmpty {
                        Text("No subnets yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(Array(viewModel.subnets.enumerated()), id: \.element.id) { index, subnet in
                            Button {
                                viewModel.showSubnet(subnet)
                            } label: {
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            Circle()
                                                .fill(priorityColor(for: index))
                                        )
                                    
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
                        .onDelete { indexSet in
                            for index in indexSet {
                                let subnet = viewModel.subnets[index]
                                Task {
                                    await viewModel.deleteSubnet(subnet)
                                }
                            }
                        }
                        .onMove { source, destination in
                            viewModel.moveSubnet(from: source, to: destination)
                        }
                    }
                } header: {
                    Text("Subnets")
                } footer: {
                    Text("Drag to order")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Subnets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchSubnets()
            }
            .sheet(isPresented: $viewModel.showCreateSubnet) {
                CreateSubnetCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showSubnetView) {
                if let subnet = viewModel.selectedSubnet {
                    SubnetCoordinator(subnet: subnet).start()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
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
    
    private func priorityColor(for index: Int) -> Color {
        switch index {
        case 0:
            return Color(.systemGray)      // Highest priority
        case 1:
            return Color(.systemGray2)
        case 2:
            return Color(.systemGray3)
        default:
            return Color(.systemGray4)     // Lower priority
        }
    }
}

#Preview {
    SubnetListView(viewModel: SubnetListViewModel())
}

