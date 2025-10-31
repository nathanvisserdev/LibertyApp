//
//  SignupWelcomeView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupWelcomeView: View {
    @ObservedObject var viewModel: SignupViewModel
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Welcome to Liberty Social \(viewModel.firstName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your account has been successfully created. Let's get started connecting with friends and exploring the community.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Photo upload status message
            if let photoMessage = viewModel.photoUploadMessage {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.photoUploadSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(viewModel.photoUploadSuccess ? .green : .orange)
                    Text(photoMessage)
                        .font(.subheadline)
                        .foregroundColor(viewModel.photoUploadSuccess ? .green : .orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.photoUploadSuccess ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                )
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await sessionStore.refresh()
                    dismiss()
                }
            }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal)
    }
}
