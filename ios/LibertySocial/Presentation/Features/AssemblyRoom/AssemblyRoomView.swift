
import SwiftUI

struct AssemblyRoomView: View {
    let group: UserGroup
    @StateObject private var viewModel: AssemblyRoomViewModel
    
    init(group: UserGroup, viewModel: AssemblyRoomViewModel) {
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
    let model = AssemblyRoomModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
    let viewModel = AssemblyRoomViewModel(group: group, model: model)
    AssemblyRoomView(group: group, viewModel: viewModel)
}
