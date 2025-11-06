//
//  GroupView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import SwiftUI

struct GroupView: View {
    let group: UserGroup
    @StateObject private var viewModel: GroupViewModel
    
    init(group: UserGroup, viewModel: GroupViewModel) {
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
    return GroupView(group: group, viewModel: GroupViewModel(group: group))
}
