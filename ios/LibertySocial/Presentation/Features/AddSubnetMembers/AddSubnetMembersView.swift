//
//  AddSubnetMembersView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import SwiftUI

struct AddSubnetMembersView: View {
    @StateObject private var viewModel = AddSubnetMembersViewModel()
    let subnetId: String
    
    var body: some View {
        Text("Add Subnet Members")
            .onAppear {
                viewModel.setSubnetId(subnetId)
            }
    }
}

#Preview {
    AddSubnetMembersView(subnetId: "preview-subnet-id")
}
