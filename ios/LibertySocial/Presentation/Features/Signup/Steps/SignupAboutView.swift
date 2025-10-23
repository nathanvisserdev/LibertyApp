//
//  SignupAboutView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

struct SignupAboutView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell us about yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 6 of 7 (Optional)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.headline)
                
                TextEditor(text: $coordinator.about)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                
                Text("Share a bit about yourself, your interests, or what brings you to Liberty Social")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    if coordinator.about.isEmpty {
                        // Skip - complete signup without about
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
                        Text(coordinator.about.isEmpty ? "Skip and finish" : "Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(coordinator.isLoading)
                
                if !coordinator.about.isEmpty {
                    Button(action: {
                        coordinator.about = ""
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
