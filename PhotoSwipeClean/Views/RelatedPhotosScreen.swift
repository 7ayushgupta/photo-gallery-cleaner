//
//  RelatedPhotosScreen.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI
import UIKit

struct RelatedPhotosScreen: View {
    let currentPhoto: PhotoItem
    let relatedPhotos: [PhotoItem]
    @ObservedObject var viewModel: PhotoReviewViewModel
    @Environment(\.dismiss) var dismiss
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Related photos")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap to mark/unmark for deletion.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(relatedPhotos) { photo in
                            RelatedPhotoThumbnail(
                                photo: photo,
                                isMarkedForDeletion: viewModel.toDeleteIds.contains(photo.id),
                                onTap: {
                                    viewModel.toggleDeletion(for: photo.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: 15) {
                    Text("Marked for deletion: \(viewModel.toDeleteIds.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RelatedPhotoThumbnail: View {
    let photo: PhotoItem
    let isMarkedForDeletion: Bool
    let onTap: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    
                    ProgressView()
                }
                
                if isMarkedForDeletion {
                    Color.red.opacity(0.5)
                    
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 120)
            .cornerRadius(8)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let targetSize = CGSize(width: 200, height: 200)
        PhotoLibraryService.shared.loadImage(for: photo.asset, targetSize: targetSize) { loadedImage in
            self.image = loadedImage
        }
    }
}

