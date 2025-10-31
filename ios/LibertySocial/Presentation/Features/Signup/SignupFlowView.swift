//
//  SignupFlowView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI

struct SignupFlowView: View {
    @StateObject private var viewModel: SignupViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: SignupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Step views
                Group {
                    switch viewModel.currentStep {
                    case .credentials:
                        SignupCredentialsView(viewModel: viewModel)
                    case .name:
                        SignupNameView(viewModel: viewModel)
                    case .username:
                        SignupUsernameView(viewModel: viewModel)
                    case .demographics:
                        SignupDemographicsView(viewModel: viewModel)
                    case .photo:
                        SignupPhotoView(viewModel: viewModel)
                    case .about:
                        SignupAboutView(viewModel: viewModel)
                    case .phone:
                        SignupPhoneView(viewModel: viewModel)
                    case .complete:
                        SignupWelcomeView(viewModel: viewModel)
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
                    if viewModel.currentStep != .complete {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStep != .credentials && viewModel.currentStep != .complete {
                        // Progress indicator
                        Text("\(viewModel.currentStep.rawValue)/7")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
