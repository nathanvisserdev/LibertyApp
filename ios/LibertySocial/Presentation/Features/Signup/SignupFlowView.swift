
import SwiftUI

struct SignupFlowView: View {
    @StateObject private var viewModel: SignupViewModel
    
    init(viewModel: SignupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
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
                        viewModel.onSignupComplete?()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.currentStep != .credentials && viewModel.currentStep != .complete {
                    Text("\(viewModel.currentStep.rawValue)/7")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
