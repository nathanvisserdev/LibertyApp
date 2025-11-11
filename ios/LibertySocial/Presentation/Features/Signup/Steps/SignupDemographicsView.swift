
import SwiftUI
import Combine

struct SignupDemographicsView: View {
    @ObservedObject var viewModel: SignupViewModel
    
    private let genderOptions = [
        ("MALE", "Male"),
        ("FEMALE", "Female"),
        ("OTHER", "Other")
    ]
    
    private var age: Int {
        Calendar.current.dateComponents([.year], from: viewModel.dateOfBirth, to: Date()).year ?? 0
    }
    
    private var isAtLeast13: Bool {
        age >= 13
    }
    
    private var canProceed: Bool {
        isAtLeast13
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("A little about you")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 4 of 7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date of Birth")
                    .font(.headline)
                
                DatePicker(
                    "",
                    selection: $viewModel.dateOfBirth,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                if !isAtLeast13 {
                    Text("You must be at least 13 years old to use Liberty Social")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.headline)
                
                Picker("Select your gender", selection: $viewModel.gender) {
                    ForEach(genderOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Profile Privacy")
                    .font(.headline)
                
                Toggle(isOn: $viewModel.isPrivate) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.isPrivate ? "Private Account" : "Public Account")
                            .font(.subheadline)
                        Text(viewModel.isPrivate ? "Only connections can see your posts" : "Anyone can see your posts")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: {
                viewModel.nextStep(.photo)
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
