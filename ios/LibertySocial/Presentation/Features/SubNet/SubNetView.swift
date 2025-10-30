//
//  SubNetView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import SwiftUI

struct SubNetView: View {
    @ObservedObject var subNetListViewModel: SubNetListViewModel
    @StateObject private var viewModel = SubNetViewModel()
    
    var body: some View {
        Text("SubNet ID: \(viewModel.subnetId ?? "None")")
            .onAppear {
                subNetListViewModel.passSubnetIdToViewModel(viewModel)
            }
    }
}
