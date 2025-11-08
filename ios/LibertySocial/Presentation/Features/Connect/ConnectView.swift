
import SwiftUI

struct ConnectView: View {
    @StateObject private var viewModel: ConnectViewModel
    let firstName: String
    let userId: String
    let isPrivate: Bool
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: ConnectViewModel, firstName: String, userId: String, isPrivate: Bool) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.firstName = firstName
        self.userId = userId
        self.isPrivate = isPrivate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Connection Type")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 50)
                
                VStack(spacing: 16) {
                    ConnectionTypeButton(
                        title: "Friendly acquaintances",
                        isSelected: viewModel.selectedType == "ACQUAINTANCE",
                        action: { viewModel.selectedType = "ACQUAINTANCE" }
                    )
                    
                    ConnectionTypeButton(
                        title: "Cordial strangers",
                        isSelected: viewModel.selectedType == "STRANGER",
                        action: { viewModel.selectedType = "STRANGER" }
                    )
                    
                    if !isPrivate {
                        ConnectionTypeButton(
                            title: "Follow",
                            isSelected: viewModel.selectedType == "IS_FOLLOWING",
                            action: { viewModel.selectedType = "IS_FOLLOWING" }
                        )
                    }
                }
                .padding(.horizontal)
                
                if let type = viewModel.selectedType {
                    Button(action: {
                        Task {
                            await viewModel.sendConnectionRequest(userId: userId, type: type)
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(buttonText(for: type))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                }
                
                VStack(spacing: 12) {
                    Image("liberty_bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    Text("Why we ask?")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("We want our users to draw a distinction between people they know personally and friendly strangers they don't.")
                        .font(.body)
                    
                    Text("We categorize your connections to emphasize that.")
                        .font(.body)
                    
                    Text("Stay safe.")
                        .font(.body)
                }
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.successMessage = nil
                dismiss()
            }
        } message: {
            if let success = viewModel.successMessage {
                Text(success)
            }
        }
    }
    
    private func buttonText(for type: String) -> String {
        switch type {
        case "ACQUAINTANCE":
            return "Connect as acquaintances"
        case "STRANGER":
            return "Connect as strangers"
        case "IS_FOLLOWING":
            return "Follow \(firstName)"
        default:
            return "Send Request"
        }
    }
}

struct ConnectionTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    let model = ConnectModel()
    let viewModel = ConnectViewModel(model: model, userId: "123")
    return ConnectView(viewModel: viewModel, firstName: "John", userId: "123", isPrivate: false)
}
