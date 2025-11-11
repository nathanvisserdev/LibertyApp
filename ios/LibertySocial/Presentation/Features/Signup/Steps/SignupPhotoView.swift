
import SwiftUI
import PhotosUI

struct SignupPhotoView: View {
    @ObservedObject var viewModel: SignupViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a profile photo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 5 of 7")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 20) {
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                } else {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text(selectedImageData == nil ? "Choose Photo" : "Change Photo")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.photoData = selectedImageData
                    viewModel.nextStep(.about)
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(selectedImageData != nil ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(selectedImageData == nil)
                
                if selectedImageData == nil {
                    Text("Please select a profile photo")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
}
