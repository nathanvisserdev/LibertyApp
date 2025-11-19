
import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel: TabBarViewModel

    init(viewModel: TabBarViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Button { viewModel.onNotificationsMenuTap() } label: {
                Image(systemName: "bell").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button { viewModel.onNetworkMenuTap() } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "person.3").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
                }
            }
            Spacer(minLength: 0)
            Button { viewModel.onCreatePostTap() } label: {
                Image(systemName: "square.and.arrow.up").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            .accessibilityLabel("Compose")
            Spacer(minLength: 0)
            Button { viewModel.onSearchTap() } label: {
                Image(systemName: "magnifyingglass").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
            Button { viewModel.onMainMenuTap() } label: {
                Image(systemName: "person").font(.system(size: 28, weight: .regular)).foregroundColor(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .task { await viewModel.fetchCurrentUserInfo() }
        .sheet(isPresented: $viewModel.isShowingNotifications) {
            viewModel.onShowNotificationsMenu?()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingNetworkMenu) {
            viewModel.onShowNetworkMenu?()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingSearch) {
            viewModel.onShowSearch?()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingProfile) {
            viewModel.onShowProfile?()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingCreatePost) {
            viewModel.onShowCreatePost?()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
