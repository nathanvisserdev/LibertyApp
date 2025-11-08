
import SwiftUI

struct CommentRowView: View {
    let comment: CommentItem
    let isMine: Bool
    let formattedDate: String
    var onMore: (() -> Void)? = nil
    var onReply: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 4) {
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
                
                Text(comment.content)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}
