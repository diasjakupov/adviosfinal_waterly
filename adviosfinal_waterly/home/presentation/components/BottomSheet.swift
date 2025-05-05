//
//  BottomSheet.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    // Public API
    @Binding var height: CGFloat
    let minHeight: CGFloat = 90
    let maxFraction: CGFloat = 0.60
    @ViewBuilder let content: () -> Content
    
    // Internal state
    @GestureState private var dragDelta: CGFloat = 0
    
    init(height: Binding<CGFloat>,
         @ViewBuilder content: @escaping () -> Content) {
        self._height = height
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geo in
            let maxHeight = geo.size.height * maxFraction
            let proposed  = (height - dragDelta).clamped(to: minHeight ... maxHeight)
            
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.wGreyLight.opacity(0.35))
                    .frame(width: 120, height: 4)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                content()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .frame(width: geo.size.width, height: proposed, alignment: .top)
            .background(Color.wSurface)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .frame(maxHeight: .infinity, alignment: .bottom)
            .gesture(
                DragGesture()
                    .updating($dragDelta) { value, state, _ in
                        state = value.translation.height     // negative = pull up
                    }
                    .onEnded { value in
                        let maxH = geo.size.height * maxFraction
                        let newH = (height - value.translation.height)
                            .clamped(to: minHeight ... maxH)

                        // midpoint between peek & full
                        let mid = (minHeight + maxH) / 2

                        //  ── FIX: choose FULL when above the midpoint ──
                        height = (newH > mid) ? maxH : minHeight
                    }
            )
            .animation(.interactiveSpring(response: 0.35,
                                          dampingFraction: 0.8),
                       value: proposed)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: Corner-radius helper

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
private extension View {
    func cornerRadius(_ r: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: r, corners: corners))
    }
}
