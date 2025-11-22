//
//  PhotoReviewViewModel.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import Foundation
import Photos
import SwiftUI
import Combine

class PhotoReviewViewModel: ObservableObject {
    @Published var allPhotos: [PhotoItem] = []
    @Published var currentIndex: Int = 0
    @Published var toDeleteIds: Set<String> = []
    @Published var keptIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var loadError: String?
    
    private let photoService = PhotoLibraryService.shared
    
    func loadPhotos() {
        isLoading = true
        loadError = nil
        
        photoService.requestAuthorizationIfNeeded { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .authorized, .limited:
                let assets = self.photoService.fetchAllImages()
                self.allPhotos = assets.map { PhotoItem(asset: $0) }
                self.currentIndex = 0
                self.isLoading = false
            case .denied, .restricted:
                self.loadError = "Photo library access denied. Please enable access in Settings."
                self.isLoading = false
            case .notDetermined:
                self.loadError = "Photo library access not determined."
                self.isLoading = false
            @unknown default:
                self.loadError = "Unknown authorization status."
                self.isLoading = false
            }
        }
    }
    
    func currentPhoto() -> PhotoItem? {
        return allPhotos[safe: currentIndex]
    }
    
    func markKeepCurrent() {
        guard let photo = currentPhoto() else { return }
        
        keptIds.insert(photo.id)
        toDeleteIds.remove(photo.id)
        
        if let index = allPhotos.firstIndex(where: { $0.id == photo.id }) {
            var updatedPhoto = allPhotos[index]
            updatedPhoto.isMarkedForDeletion = false
            updatedPhoto.isReviewed = true
            allPhotos[index] = updatedPhoto
        }
        
        advanceToNext()
    }
    
    func markDeleteCurrent() {
        guard let photo = currentPhoto() else { return }
        
        toDeleteIds.insert(photo.id)
        keptIds.remove(photo.id)
        
        if let index = allPhotos.firstIndex(where: { $0.id == photo.id }) {
            var updatedPhoto = allPhotos[index]
            updatedPhoto.isMarkedForDeletion = true
            updatedPhoto.isReviewed = true
            allPhotos[index] = updatedPhoto
        }
        
        advanceToNext()
    }
    
    func advanceToNext() {
        if currentIndex < allPhotos.count - 1 {
            currentIndex += 1
        }
    }
    
    func relatedPhotos(for photo: PhotoItem) -> [PhotoItem] {
        guard let photoDate = photo.creationDate else { return [] }
        
        return allPhotos.filter { item in
            guard let itemDate = item.creationDate else { return false }
            return photoDate.isSameDay(as: itemDate)
        }
    }
    
    func toggleDeletion(for photoId: String) {
        if toDeleteIds.contains(photoId) {
            toDeleteIds.remove(photoId)
            if let index = allPhotos.firstIndex(where: { $0.id == photoId }) {
                var updatedPhoto = allPhotos[index]
                updatedPhoto.isMarkedForDeletion = false
                allPhotos[index] = updatedPhoto
            }
        } else {
            toDeleteIds.insert(photoId)
            if let index = allPhotos.firstIndex(where: { $0.id == photoId }) {
                var updatedPhoto = allPhotos[index]
                updatedPhoto.isMarkedForDeletion = true
                allPhotos[index] = updatedPhoto
            }
        }
    }
    
    func performDeletion(completion: @escaping (Bool, String?) -> Void) {
        guard !toDeleteIds.isEmpty else {
            completion(false, "No photos selected for deletion")
            return
        }
        
        let identifiers = Array(toDeleteIds)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        var assetsToDelete: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assetsToDelete.append(asset)
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // Remove deleted photos from allPhotos
                    self?.allPhotos.removeAll { self?.toDeleteIds.contains($0.id) ?? false }
                    self?.toDeleteIds.removeAll()
                    
                    // Reset currentIndex if needed
                    if let currentIndex = self?.currentIndex, currentIndex >= self?.allPhotos.count ?? 0 {
                        self?.currentIndex = max(0, (self?.allPhotos.count ?? 1) - 1)
                    }
                    
                    completion(true, nil)
                } else {
                    completion(false, error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
}

