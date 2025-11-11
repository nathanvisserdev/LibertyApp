
import SwiftUI

struct SignupUsernameView: View {
    @ObservedObject var viewModel: SignupViewModel
    @State private var usernameCheckMessage: String = ""
    @State private var isCheckingUsername: Bool = false
    @State private var usernameIsValid: Bool? = nil
    
    private var canProceed: Bool {
        !viewModel.username.isEmpty &&
        viewModel.username.count >= 3 &&
        usernameIsValid == true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a username")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 3 of 7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.headline)
                
                HStack {
                    TextField("Pick your unique username", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.username) { oldValue, newValue in
                            usernameIsValid = nil
                            usernameCheckMessage = ""
                            Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                if newValue == viewModel.username {
                                    await checkUsernameAvailability()
                                }
                            }
                        }
                    
                    if isCheckingUsername {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if let valid = usernameIsValid {
                        Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(valid ? .green : .red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !usernameCheckMessage.isEmpty {
                    Text(usernameCheckMessage)
                        .font(.caption)
                        .foregroundColor(usernameIsValid == true ? .green : .red)
                }
                
                if !viewModel.username.isEmpty && viewModel.username.count < 3 {
                    Text("Username must be at least 3 characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.nextStep(.demographics)
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
    
    private func checkUsernameAvailability() async {
        guard !viewModel.username.isEmpty, viewModel.username.count >= 3 else {
            usernameCheckMessage = ""
            usernameIsValid = nil
            return
        }
        
        isCheckingUsername = true
        
        do {
            let model = SignupModel()
            let isAvailable = try await model.checkAvailability(username: viewModel.username)
            
            if isAvailable {
                usernameCheckMessage = "Username is available"
                usernameIsValid = true
            } else {
                usernameCheckMessage = "Username is already taken"
                usernameIsValid = false
            }
        } catch {
            usernameCheckMessage = "Could not verify username"
            usernameIsValid = nil
        }
        
        isCheckingUsername = false
    }
}
