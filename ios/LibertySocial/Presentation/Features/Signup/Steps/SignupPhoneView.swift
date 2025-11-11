
import SwiftUI
import Combine

struct SignupPhoneView: View {
    @ObservedObject var viewModel: SignupViewModel
    @State private var formattedPhone: String = ""
    
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
                
                TextField("(555)123-4567", text: $formattedPhone)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: formattedPhone) { oldValue, newValue in
                        let digitsOnly = newValue.filter { $0.isNumber }
                        let limitedDigits = String(digitsOnly.prefix(10))
                        viewModel.phoneNumber = limitedDigits
                        formattedPhone = formatPhoneNumber(limitedDigits)
                    }
                
                Text("We'll never share your phone number without your permission")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await viewModel.completeSignup()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(viewModel.phoneNumber.isEmpty ? "Opt-out and finish" : "Finish")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.isLoading)
                
                if !viewModel.phoneNumber.isEmpty {
                    Button(action: {
                        viewModel.phoneNumber = ""
                        formattedPhone = ""
                        Task {
                            await viewModel.completeSignup()
                            if viewModel.errorMessage == nil {
                                viewModel.nextStep(.complete)
                            }
                        }
                    }) {
                        Text("Opt-out")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .disabled(viewModel.isLoading)
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
    
    private func formatPhoneNumber(_ digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        
        var formatted = ""
        let count = digits.count
        
        if count <= 3 {
            formatted = "(\(digits)"
        } else if count <= 6 {
            let areaCode = digits.prefix(3)
            let middle = digits.dropFirst(3)
            formatted = "(\(areaCode))\(middle)"
        } else {
            let areaCode = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(3)
            let last = digits.dropFirst(6)
            formatted = "(\(areaCode))\(middle)-\(last)"
        }
        
        return formatted
    }
}
