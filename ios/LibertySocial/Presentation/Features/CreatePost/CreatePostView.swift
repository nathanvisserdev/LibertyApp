//
//  CreatePostView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject var vm: CreatePostViewModel
    @State private var showPhotoPicker = false
    @State private var showAudiencePicker = false
    @State private var selectedAudience = "Select Audience"
    var onCancel: () -> Void
    var onPosted: () -> Void

    init(vm: CreatePostViewModel,
         onCancel: @escaping () -> Void,
         onPosted: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: vm)
        self.onCancel = onCancel
        self.onPosted = onPosted
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Post to selector
                HStack(spacing: 6) {
                    Text("Post to")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        showAudiencePicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedAudience)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $vm.draft.text)
                        .frame(minHeight: 160)
                        .padding(8)
                        .padding(.top, vm.draft.localMedia.isEmpty ? 0 : 128)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary.opacity(0.3))
                        )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Display selected photo if available
                        if let photoURL = vm.draft.localMedia.first {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(8)
                        }
                        
                        if vm.draft.text.isEmpty {
                            Text(vm.draft.localMedia.isEmpty ? "What's on your mind?" : "Add a caption...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.top, vm.draft.localMedia.isEmpty ? 8 : 0)
                                .allowsHitTesting(false)
                        }
                    }
                }

                HStack {
                    Spacer()
                    Text("\(vm.remainingCharacters)")
                        .font(.footnote)
                        .foregroundStyle(vm.remainingCharacters < 0 ? .red : .secondary)
                }

                if let msg = vm.errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: {
                    Task {
                        let success = await vm.requestPresignedUpload()
                        if success {
                            showPhotoPicker = true
                        }
                    }
                }) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .photosPicker(isPresented: $showPhotoPicker, selection: $vm.selectedPhoto, matching: .images)
                .onChange(of: vm.selectedPhoto) { _, _ in
                    Task {
                        await vm.loadSelectedPhoto()
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            let success = await vm.submit()
                            if success {
                                onPosted()
                            }
                        }
                    }
                    .disabled((vm.draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && vm.draft.localMedia.isEmpty)
                              || vm.remainingCharacters < 0
                              || vm.isSubmitting)
                }
            }
            .confirmationDialog("Select Audience", isPresented: $showAudiencePicker, titleVisibility: .hidden) {
                Button("Acquaintances") { selectedAudience = "Acquaintances" }
                Button("Subnet") { selectedAudience = "Subnet" }
                Button("Connections") { selectedAudience = "Connections" }
                Button("Public") { selectedAudience = "Public" }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
