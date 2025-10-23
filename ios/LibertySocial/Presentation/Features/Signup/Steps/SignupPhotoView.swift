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
                    // Just move to next step, don't signup yet
                    coordinator.nextStep()
                }) {
                    Text(coordinator.photo.isEmpty ? "Opt-out" : "Continue")
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
