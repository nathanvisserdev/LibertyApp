//
//  ConnectView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct ConnectView: View {
    @StateObject var viewModel = ConnectViewModel()
    let firstName: String
    let userId: String
    let isPrivate: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("How do you know \(firstName)?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 50)
                
                // Connection Type Options
                VStack(spacing: 16) {
                    ConnectionTypeButton(
                        title: "I know \(firstName) personally",
                        isSelected: viewModel.selectedType == "ACQUAINTANCE",
                        action: { viewModel.selectedType = "ACQUAINTANCE" }
                    )
                    
                    ConnectionTypeButton(
                        title: "We're strangers but I'd like to connect!",
                        isSelected: viewModel.selectedType == "STRANGER",
                        action: { viewModel.selectedType = "STRANGER" }
                    )
                    
                    // Only show follow option if the user's account is public
                    if !isPrivate {
                        ConnectionTypeButton(
                            title: "I just want to follow this person",
                            isSelected: viewModel.selectedType == "IS_FOLLOWING",
                            action: { viewModel.selectedType = "IS_FOLLOWING" }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Submit Button
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
                
                // Why we ask section
                VStack(spacing: 12) {
                    Image("liberty_bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    Text("Why we ask?")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Sensible users draw a distinction between acquaintances and internet strangers.")
                        .font(.body)
                    
                    Text("We categorize your connections to reflect that.")
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
    ConnectView(firstName: "John", userId: "123", isPrivate: false)
}
