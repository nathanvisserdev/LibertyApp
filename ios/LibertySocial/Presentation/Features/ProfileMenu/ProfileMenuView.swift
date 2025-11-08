
import SwiftUI

struct ProfileMenuView: View {
    @StateObject private var viewModel: ProfileMenuViewModel
    @Environment(\.dismiss) var dismiss

    init(viewModel: ProfileMenuViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Button { viewModel.tapProfile() } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person").font(.title2).foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profile").font(.body).fontWeight(.medium).foregroundColor(.primary)
                            Text("View profile").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                Button { viewModel.tapSettings() } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape").font(.title2).foregroundColor(.gray)
                        Text("Settings").font(.body).fontWeight(.medium).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $viewModel.isShowingProfile) {
                viewModel.onShowProfile()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
