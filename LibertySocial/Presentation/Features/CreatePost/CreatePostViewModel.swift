//
//  CreatePostVM.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation
import Combine

final class CreatePostViewModel: ObservableObject {
    @Published var text: String = ""
    let maxCharacters: Int = 1000
    var remainingCharacters: Int { maxCharacters - text.count }
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil

    func submit() {
        // TODO: wire later
    }
}

