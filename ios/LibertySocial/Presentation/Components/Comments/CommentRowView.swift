//
//  CommentRowView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import SwiftUI

struct CommentRowView: View {
    let comment: CommentItem
    let isMine: Bool
    let formattedDate: String
    var onMore: (() -> Void)? = nil
    var onReply: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 28, height: 28)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Author line
                HStack(spacing: 4) {
                    if let user = comment.user {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("@\(user.username)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("·")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Text(formattedDate)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Ellipsis button for own comments
                    if isMine {
                        Button {
                            onMore?()
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Comment text
                Text(comment.content)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}
