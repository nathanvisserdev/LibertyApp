
import SwiftUI

struct GroupRoomView: View {
    @StateObject private var viewModel: GroupRoomViewModel
    
    init(viewModel: GroupRoomViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading group...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else if let group = viewModel.group {
                    VStack {
                        Text("Group View")
                        Text(group.name)
                            .font(.title)
                    }
                    .navigationTitle(group.name)
                } else {
                    Text("Group not found")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.onDoneTap?()
                    }
                }
            }
            .onDisappear {
                viewModel.onFinish?()
            }
        }
    }
}

//#Preview {
//    let group = UserGroup(
//        id: "1",
//        name: "Sample Group",
//        description: "A sample group",
//        groupType: "PUBLIC",
//        isHidden: false,
//        adminId: "admin123",
//        admin: GroupAdmin(
//            id: "admin123",
//            username: "admin",
//            firstName: "Admin",
//            lastName: "User"
//        ),
//        displayLabel: "Member",
//        joinedAt: Date()
//    )
//    let tokenProvider = AuthManager()
//    let authManager = AuthManager()
//    let model = GroupRoomModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
//    let viewModel = GroupRoomViewModel(groupId: groupId, model: model)
//    GroupRoomView(groupId: groupId, viewModel: viewModel)
//}
