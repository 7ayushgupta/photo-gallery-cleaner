//
//  PhotoLibraryService.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import Foundation
import Photos
import SwiftUI
import UIKit

class PhotoLibraryService {
    static let shared = PhotoLibraryService()
    
    private init() {}
    
    func requestAuthorizationIfNeeded(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch currentStatus {
        case .authorized, .limited:
            completion(currentStatus)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status)
                }
            }
        case .denied, .restricted:
            completion(currentStatus)
        @unknown default:
            completion(currentStatus)
        }
    }
    
    func fetchAllImages() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    func loadImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

