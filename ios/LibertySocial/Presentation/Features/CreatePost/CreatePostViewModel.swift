//
//  CreatePostVM.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation
import Combine

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    let maxCharacters = 1000
    private let useCase = CreatePostUseCase()

    var remainingCharacters: Int {
        maxCharacters - text.count
    }

    func submit() async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        do {
            try await useCase.execute(text: text)
            text = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}


