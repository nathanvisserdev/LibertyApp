//
//  SignupPhoneView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

struct SignupPhoneView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a phone number")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 7 of 7 (Optional)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.headline)
                
                TextField("Enter your phone number", text: $coordinator.phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Text("We'll never share your phone number without your permission")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await coordinator.completeSignup()
                        if coordinator.errorMessage == nil {
                            coordinator.nextStep()
                        }
                    }
                }) {
                    if coordinator.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(coordinator.phoneNumber.isEmpty ? "Skip and finish" : "Finish")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(coordinator.isLoading)
                
                if !coordinator.phoneNumber.isEmpty {
                    Button(action: {
                        coordinator.phoneNumber = ""
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
