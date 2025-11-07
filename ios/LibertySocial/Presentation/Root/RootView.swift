//
//  RootView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        viewModel.contentView
    }
}
