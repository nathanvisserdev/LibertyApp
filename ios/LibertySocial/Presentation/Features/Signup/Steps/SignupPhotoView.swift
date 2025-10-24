//
//  SignupPhotoView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import PhotosUI

struct SignupPhotoView: View {
    @ObservedObject var coordinator: SignupFlowCoordinator
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a profile photo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Step 5 of 7 (Optional)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Photo preview
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
                
                // Photo picker
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
                    // Store the photo data in the coordinator for upload after signup
                    coordinator.photoData = selectedImageData
                    coordinator.nextStep()
                }) {
                    Text(selectedImageData == nil ? "Skip" : "Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
}
