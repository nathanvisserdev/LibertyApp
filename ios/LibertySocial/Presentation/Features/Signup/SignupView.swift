// import SwiftUI

// @MainActor
// final class SignupCoordinator {
//     var onFinished: (() -> Void)?
//     private var continueTapped: Bool = false
//     private var currentView: AnyView?
//     private var lastView: AnyView?
    
//     init() { }
    
//     func start(nextView: nextView) -> AnyView {
//         if currentView == nill || currentView != lastView {
//             currentView = buildView(nextView: nextView)
//         }
//         lastView = currentView
//         return AnyView(
//             NavigationStack {
//                 currentView!
//             }
//         )
//     }
        
//         private func handleNavTap(nextView: nextView){
//             let view = buildView(nextView: nextView)
//             pickView(viewModel: viewModel, nextView: nextView)
//         }
    
//     private func buildView(nextView: nextView) ->  AnyView {
//             let viewModel = buildVM()
//             let view = pickView(viewModel: viewModel, nextView: nextView)
//             currentView = view
//         }
        
//     private func buildVM() -> SignupViewModel {
//             let model = SignupModel()
//             let viewModel = SignupViewModel(model: model)
//             viewModel.onSignupComplete = { [weak self] in
//                 self?.onFinished?()
//             }
//             viewModel.onNavTap = { [weak self] nextView in
//                 self?.handleNavTap(nextView: nextView)
//             }
//             return viewModel
//         }
        
//         func pickView(viewModel: viewModel, nextView: nextView) -> Void {
//             switch nextView {
//             case .signupFlow:
//                 startSignupFlow(viewModel: viewModel)
//             case .credentials:
//                 startSignupCredentialsView(viewModel: viewModel)
//             case .name:
//                 startSignupNameView(viewModel: viewModel)
//             case .username:
//                 startSignupUsernameView(viewModel: viewModel)
//             case .demographics:
//                 startSignupDemographicsView(viewModel: viewModel)
//             case .photo:
//                 startSignupPhotoView(viewModel: viewModel)
//             case .about:
//                 startSignupAboutView(viewModel: viewModel)
//             case .phone:
//                 startSignupPhoneView(viewModel: viewModel)
//             case .complete:
//                 startSignupCompleteView(viewModel: viewModel)
//             }
//         }
    
//         private func startSignupFlow(viewModel: viewModel) -> Void {
//             currentView = SignupFlowView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupCredentialsView(viewModel: viewModel) -> Void {
//             currentView = SignupCredentialsView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupNameView(viewModel: viewModel) -> Void {
//             currentView = SignupNameView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupUsernameView(viewModel: viewModel) -> Void {
//             currentView = SignupUsernameView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupDemographicsView(viewModel: viewModel) -> Void {
//             currentView = SignupDemographicsView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupPhotoView(viewModel: viewModel) -> Void {
//             currentView = SignupPhotoView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupAboutView(viewModel: viewModel) -> Void {
//             currentView = SignupAboutView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupPhoneView(viewModel: viewModel) -> Void {
//             currentView = SignupPhoneView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
        
//         private func startSignupCompleteView(viewModel: viewModel) -> Void {
//             currentView = SignupWelcomeView(viewModel: viewModel)
//             start(nextView: nextView)
//         }
//     }
    

