//
//  ContentView.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State private var isAuthorized = false
    @State private var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var body: some View {
        Group {
            if isAuthorized {
                MainReviewScreen()
            } else {
                PermissionScreen(isAuthorized: $isAuthorized)
            }
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        isAuthorized = authorizationStatus == .authorized || authorizationStatus == .limited
    }
}

#Preview {
    ContentView()
}
