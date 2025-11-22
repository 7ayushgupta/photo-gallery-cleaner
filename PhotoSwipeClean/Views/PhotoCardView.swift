//
//  PhotoCardView.swift
//  PhotoSwipeClean
//
//  Created by Ayush Gupta on 22/11/25.
//

import SwiftUI
import UIKit

struct PhotoCardView: View {
    let image: UIImage?
    let onKeep: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0
    
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(20)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                    
                    ProgressView()
                }
            }
            .offset(x: dragOffset.width, y: dragOffset.height)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                        rotation = Double(value.translation.width / 20)
                    }
                    .onEnded { value in
                        let horizontalOffset = value.translation.width
                        
                        if horizontalOffset > swipeThreshold {
                            // Swipe right - keep
                            withAnimation(.spring()) {
                                dragOffset = CGSize(width: geometry.size.width * 2, height: 0)
                            }
                            hapticFeedback(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onKeep()
                                resetPosition()
                            }
                        } else if horizontalOffset < -swipeThreshold {
                            // Swipe left - delete
                            withAnimation(.spring()) {
                                dragOffset = CGSize(width: -geometry.size.width * 2, height: 0)
                            }
                            hapticFeedback(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDelete()
                                resetPosition()
                            }
                        } else {
                            // Snap back
                            withAnimation(.spring()) {
                                resetPosition()
                            }
                        }
                    }
            )
        }
    }
    
    private func resetPosition() {
        dragOffset = .zero
        rotation = 0
    }
    
    private func hapticFeedback(_ style: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }
}

