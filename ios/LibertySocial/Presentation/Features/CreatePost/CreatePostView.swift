
import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CreatePostViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Text("Post to")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        viewModel.tapAudiencePicker()
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedAudience)
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
                    TextEditor(text: $viewModel.text)
                        .frame(minHeight: 160)
                        .padding(8)
                        .padding(.top, viewModel.localMediaURL != nil ? 128 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.secondary.opacity(0.3))
                        )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if let photoURL = viewModel.localMediaURL {
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
                        
                        if viewModel.text.isEmpty {
                            Text(viewModel.localMediaURL == nil ? "What's on your mind?" : "Add a caption...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.top, viewModel.localMediaURL == nil ? 8 : 0)
                                .allowsHitTesting(false)
                        }
                    }
                }

                HStack {
                    Spacer()
                    Text("\(viewModel.remainingCharacters)")
                        .font(.footnote)
                        .foregroundStyle(viewModel.remainingCharacters < 0 ? .red : .secondary)
                }

                if let msg = viewModel.errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: {
                    Task {
                        await viewModel.requestPresignedUpload()
                    }
                }) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .photosPicker(
                    isPresented: $viewModel.showPhotoPicker,
                    selection: $viewModel.selectedPhoto,
                    matching: .images
                )
                .onChange(of: viewModel.selectedPhoto) { _, _ in
                    Task {
                        await viewModel.loadSelectedPhoto()
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            await viewModel.submit()
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .confirmationDialog(
                "Select Audience",
                isPresented: $viewModel.showAudiencePicker,
                titleVisibility: .hidden
            ) {
                ForEach(viewModel.availableAudiences, id: \.self) { audience in
                    Button(audience) {
                        viewModel.selectAudience(audience)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
            .task {
                await viewModel.loadCurrentUserData()
            }
        }
    }
}

#Preview {
    CreatePostView(viewModel: CreatePostViewModel())
}
