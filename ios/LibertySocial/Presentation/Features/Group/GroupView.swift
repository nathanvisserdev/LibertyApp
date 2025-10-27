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
    
    init(group: UserGroup) {
        self.group = group
        _viewModel = StateObject(wrappedValue: GroupViewModel(group: group))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Group View")
                Text(group.name)
                    .font(.title)
            }
            .navigationTitle(group.name)
        }
    }
}

#Preview {
    GroupView(group: UserGroup(
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
    ))
}
