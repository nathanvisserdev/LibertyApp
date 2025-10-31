//
//  SignupAboutView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

struct SignupAboutView: View {
    @ObservedObject var viewModel: SignupViewModel
    
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
                
                TextEditor(text: $viewModel.about)
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
                    // Just move to next step, don't signup yet
                    viewModel.nextStep()
                }) {
                    Text(viewModel.about.isEmpty ? "Opt-out" : "Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}
