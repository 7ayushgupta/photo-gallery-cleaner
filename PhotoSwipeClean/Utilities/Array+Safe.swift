//
//  Array+Safe.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

