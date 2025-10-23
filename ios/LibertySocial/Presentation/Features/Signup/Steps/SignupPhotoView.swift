//
//  SignupPhotoView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupPhotoView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a profile photo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 5 of 7 (Optional)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Photo URL")
                    .font(.headline)
                
                TextField("Enter a URL to your photo", text: $coordinator.photo)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Text("You can add a photo later from your profile")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    if coordinator.photo.isEmpty {
                        // Skip - complete signup without photo
                        Task {
                            await coordinator.completeSignup()
                            if coordinator.errorMessage == nil {
                                coordinator.nextStep()
                            }
                        }
                    } else {
                        // Continue to next step
                        coordinator.nextStep()
                    }
                }) {
                    if coordinator.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(coordinator.photo.isEmpty ? "Skip and finish" : "Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(coordinator.isLoading)
                
                if !coordinator.photo.isEmpty {
                    Button(action: {
                        coordinator.photo = ""
                        Task {
                            await coordinator.completeSignup()
                            if coordinator.errorMessage == nil {
                                coordinator.nextStep()
                            }
                        }
                    }) {
                        Text("Skip")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .disabled(coordinator.isLoading)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .alert("Error", isPresented: .constant(coordinator.errorMessage != nil)) {
            Button("OK") {
                coordinator.errorMessage = nil
            }
        } message: {
            if let error = coordinator.errorMessage {
                Text(error)
            }
        }
    }
}
