//
//  SignupNameView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupNameView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    
    private var canProceed: Bool {
        !coordinator.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !coordinator.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 2 of 7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("First Name")
                    .font(.headline)
                
                TextField("Enter your first name", text: $coordinator.firstName)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Name")
                    .font(.headline)
                
                TextField("Enter your last name", text: $coordinator.lastName)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: {
                coordinator.nextStep()
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!canProceed)
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
}
