//
//  TabView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

// TabBarView.swift
import SwiftUI

struct TabBarView: View {
    var onQuillTap: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onQuillTap) {
                Image("quill") // in Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
                    )
            }
            .accessibilityLabel("Compose")
            Spacer()
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
