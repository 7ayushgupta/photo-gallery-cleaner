//
//  MainReviewScreen.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI
import UIKit
import Photos

struct MainReviewScreen: View {
    @StateObject private var viewModel = PhotoReviewViewModel()
    @State private var showRelatedPhotos = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showSettings = false
    @State private var deleteSuccessMessage = ""
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading photos...")
            } else if let error = viewModel.loadError {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if viewModel.allPhotos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No photos found")
                        .font(.headline)
                }
            } else {
                VStack(spacing: 0) {
                    // Top progress bar
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            if let currentPhoto = viewModel.currentPhoto() {
                                Text("Photo \(viewModel.currentIndex + 1) of \(viewModel.allPhotos.count)")
                                    .font(.headline)
                                
                                if !viewModel.toDeleteIds.isEmpty {
                                    Text("To delete: \(viewModel.toDeleteIds.count)")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Settings")
                    }
                    .padding()
                    
                    // Photo card
                    if let currentPhoto = viewModel.currentPhoto() {
                        PhotoCardWithLoader(
                            asset: currentPhoto.asset,
                            onKeep: {
                                viewModel.markKeepCurrent()
                            },
                            onDelete: {
                                viewModel.markDeleteCurrent()
                            }
                        )
                        .id(currentPhoto.id) // reset loader state when photo changes
                        .frame(maxWidth: CGFloat.infinity)
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("You've reviewed all loaded photos")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer()
                    
                    // Bottom buttons
                    VStack(spacing: 20) {
                        // Action buttons
                        HStack(spacing: 30) {
                            // Delete button
                            Button(action: {
                                viewModel.markDeleteCurrent()
                            }) {
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Delete photo")
                            
                            // Related button
                            Button(action: {
                                if let currentPhoto = viewModel.currentPhoto() {
                                    showRelatedPhotos = true
                                }
                            }) {
                                Text("Related")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 60)
                                    .background(Color.blue)
                                    .cornerRadius(30)
                            }
                            .accessibilityLabel("Related photos")
                            
                            // Keep button
                            Button(action: {
                                viewModel.markKeepCurrent()
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Keep photo")
                        }
                        .padding(.bottom, 10)
                        
                        // Delete photos button
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete \(viewModel.toDeleteIds.count) Photos")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.toDeleteIds.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.toDeleteIds.isEmpty)
                        .accessibilityLabel("Delete selected photos")
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            if viewModel.allPhotos.isEmpty && !viewModel.isLoading {
                viewModel.loadPhotos()
            }
        }
        .sheet(isPresented: $showRelatedPhotos) {
            if let currentPhoto = viewModel.currentPhoto() {
                RelatedPhotosScreen(
                    currentPhoto: currentPhoto,
                    relatedPhotos: viewModel.relatedPhotos(for: currentPhoto),
                    viewModel: viewModel
                )
            }
        }
        .alert("Delete \(viewModel.toDeleteIds.count) photos?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performDeletion()
            }
        } message: {
            Text("They will be moved to Recently Deleted. You can restore them from the Photos app for 30 days.")
        }
        .alert("Success", isPresented: $showDeleteSuccess) {
            Button("OK") { }
        } message: {
            Text(deleteSuccessMessage)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func performDeletion() {
        let countToDelete = viewModel.toDeleteIds.count
        viewModel.performDeletion { success, errorMessage in
            if success {
                deleteSuccessMessage = "Deleted \(countToDelete) photos. They have been moved to Recently Deleted."
                showDeleteSuccess = true
            } else {
                deleteSuccessMessage = errorMessage ?? "Failed to delete photos"
                showDeleteSuccess = true
            }
        }
    }
}

struct PhotoCardWithLoader: View {
    let asset: PHAsset
    let onKeep: () -> Void
    let onDelete: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                PhotoCardView(
                    image: image,
                    onKeep: onKeep,
                    onDelete: onDelete
                )
            } else {
                PhotoCardView(
                    image: nil,
                    onKeep: onKeep,
                    onDelete: onDelete
                )
                .onAppear {
                    loadImage()
                }
            }
        }
    }
    
    private func loadImage() {
        let screenSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: screenSize.height)
        
        PhotoLibraryService.shared.loadImage(for: asset, targetSize: targetSize) { loadedImage in
            self.image = loadedImage
        }
    }
}
