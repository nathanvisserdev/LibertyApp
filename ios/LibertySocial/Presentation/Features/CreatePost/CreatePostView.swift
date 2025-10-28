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
                TextEditor(text: $vm.text)
                    .frame(minHeight: 160)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.secondary.opacity(0.3))
                    )

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
                            await vm.submit()
                            onPosted()
                        }
                    }
                    .disabled(vm.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || vm.remainingCharacters < 0
                              || vm.isSubmitting)
                }
            }
        }
    }
}
