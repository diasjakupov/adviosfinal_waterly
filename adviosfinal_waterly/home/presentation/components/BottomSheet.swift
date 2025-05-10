//
//  BottomSheet.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct CustomBottomSheet<Content: View>: View {
    private let minHeight: CGFloat = 120
    private let maxFraction: CGFloat = 0.85
    
    @Binding var height: CGFloat
    @GestureState private var dragOffset: CGFloat = 0
    
    @ViewBuilder var content: Content
    init(height: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        _height = height
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            let maxHeight = geo.size.height * maxFraction
            let current   = (height - dragOffset)
                               .clamped(to: minHeight...maxHeight)
            
            VStack(spacing: 0) {
                Capsule().fill(Color.white.opacity(0.4))
                    .frame(width: 100, height: 4).padding(.top, 8)
                content.padding(.top, 12)
            }
            .background(Color.wSurface)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .frame(height: current, alignment: .top)
            .offset(y: geo.size.height - current)
            .animation(.spring(), value: height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { val, st, _ in st = val.translation.height }
                    .onEnded { val in
                        let proposed = height - val.translation.height
                        let threshold = (minHeight + maxHeight) / 2
                        height = proposed > threshold ? maxHeight : minHeight
                    }
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

// MARK: Corner-radius helper

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
extension View {
    func cornerRadius(_ r: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: r, corners: corners))
    }
}
