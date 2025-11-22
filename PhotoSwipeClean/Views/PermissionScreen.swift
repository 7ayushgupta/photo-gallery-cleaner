//
//  PermissionScreen.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI
import Photos
import UIKit

struct PermissionScreen: View {
    @StateObject private var viewModel = PhotoReviewViewModel()
    @State private var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Binding var isAuthorized: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("PhotoSwipeClean")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Welcome!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This app helps you quickly clean up your photo library by swiping through photos one at a time.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Label("Swipe LEFT to mark for deletion", systemImage: "arrow.left")
                    Label("Swipe RIGHT to keep", systemImage: "arrow.right")
                    Label("Photos are moved to Recently Deleted", systemImage: "trash")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                VStack(spacing: 20) {
                    Text("We need access to your photos to continue.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Button(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        Text("Open Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                }
            } else {
                Button(action: {
                    PhotoLibraryService.shared.requestAuthorizationIfNeeded { status in
                        DispatchQueue.main.async {
                            authorizationStatus = status
                            if status == .authorized || status == .limited {
                                isAuthorized = true
                            }
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .onAppear {
            authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if authorizationStatus == .authorized || authorizationStatus == .limited {
                isAuthorized = true
            }
        }
    }
}

