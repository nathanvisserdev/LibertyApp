
import SwiftUI

struct GroupRoomView: View {
    let group: UserGroup
    @StateObject private var viewModel: GroupRoomViewModel
    
    init(group: UserGroup, viewModel: GroupRoomViewModel) {
        self.group = group
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Group View")
                Text(group.name)
                    .font(.title)
            }
            .navigationTitle(group.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.close()
                    }
                }
            }
        }
    }
}

#Preview {
    let group = UserGroup(
        id: "1",
        name: "Sample Group",
        description: "A sample group",
        groupType: "PUBLIC",
        isHidden: false,
        adminId: "admin123",
        admin: GroupAdmin(
            id: "admin123",
            username: "admin",
            firstName: "Admin",
            lastName: "User"
        ),
        displayLabel: "Member",
        joinedAt: Date()
    )
    let tokenProvider = AuthManager()
    let authManager = AuthManager()
    let model = GroupRoomModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
    let viewModel = GroupRoomViewModel(group: group, model: model)
    GroupRoomView(group: group, viewModel: viewModel)
}
