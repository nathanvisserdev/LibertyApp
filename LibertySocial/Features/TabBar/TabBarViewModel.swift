import SwiftUI
import Combine

class TabBarViewModel: ObservableObject {
    @Published var isComposePresented: Bool = false
    @Published var postContent: String = ""
    let maxCharacters: Int = 1000

    var remainingCharacters: Int {
        maxCharacters - postContent.count
    }

    func showCompose() {
        isComposePresented = true
    }

    func hideCompose() {
        isComposePresented = false
        postContent = ""
    }

    func updatePostContent(_ text: String) {
        if text.count <= maxCharacters {
            postContent = text
        } else {
            postContent = String(text.prefix(maxCharacters))
        }
    }
}
