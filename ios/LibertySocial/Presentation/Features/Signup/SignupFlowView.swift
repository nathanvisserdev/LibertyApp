//
//  SignupFlowView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupFlowView: View {
    @StateObject private var coordinator = SignupFlowCoordinator()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Step views
                Group {
                    switch coordinator.currentStep {
                    case .credentials:
                        SignupCredentialsView(coordinator: coordinator)
                    case .name:
                        SignupNameView(coordinator: coordinator)
                    case .username:
                        SignupUsernameView(coordinator: coordinator)
                    case .demographics:
                        SignupDemographicsView(coordinator: coordinator)
                    case .photo:
                        SignupPhotoView(coordinator: coordinator)
                    case .about:
                        SignupAboutView(coordinator: coordinator)
                    case .phone:
                        SignupPhoneView(coordinator: coordinator)
                    case .complete:
                        SignupWelcomeView(coordinator: coordinator)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if coordinator.currentStep != .complete {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if coordinator.currentStep != .credentials && coordinator.currentStep != .complete {
                        // Progress indicator
                        Text("\(coordinator.currentStep.rawValue)/7")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
