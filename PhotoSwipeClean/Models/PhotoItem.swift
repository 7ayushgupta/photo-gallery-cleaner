//
//  PhotoItem.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import Foundation
import Photos

struct PhotoItem: Identifiable {
    let id: String
    let asset: PHAsset
    let creationDate: Date?
    var isMarkedForDeletion: Bool
    var isReviewed: Bool
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.creationDate = asset.creationDate
        self.isMarkedForDeletion = false
        self.isReviewed = false
    }
}

