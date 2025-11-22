//
//  SettingsView.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("How It Works") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PhotoSwipeClean helps you quickly review and clean up your photo library.")
                            .font(.body)
                        
                        Text("• Swipe left or tap the trash button to mark photos for deletion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• Swipe right or tap the heart to keep photos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• Tap 'Related' to see photos from the same day")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• When you're ready, tap 'Delete X Photos' to move them to Recently Deleted")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• Photos in Recently Deleted can be restored for 30 days")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                
                Section("Actions") {
                    Button(action: {
                        // Placeholder for rate app
                    }) {
                        HStack {
                            Text("Rate this app")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Button(action: {
                        // Placeholder for privacy
                    }) {
                        HStack {
                            Text("Privacy")
                            Spacer()
                            Image(systemName: "hand.raised.fill")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

