//
//  RootViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine

@MainActor
final class RootViewModel: ObservableObject {
    private let model: RootModel
    init(model: RootModel) { self.model = model }
}
