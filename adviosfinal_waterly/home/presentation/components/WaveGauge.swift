//
//  WaveGauge.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

struct WaveGauge: View {
    var fraction: CGFloat
    
    @State private var waves = (0..<4).map { _ in
        WaveParam(amplitude: .random(in: 10...24),
                  waveLen  : .random(in: 0.8...1.6),
                  speed    : .random(in: 3...7),
                  phase0   : .random(in: 0...2*CGFloat.pi))
    }
    @State private var animatedFraction: CGFloat = 0
    private let bobPeriod: TimeInterval = 10
    
    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let f = animatedFraction.clamped(to: 0...1)
            
            Canvas { context, size in
                context.clip(to: Path(ellipseIn: CGRect(origin: .zero, size: size)))
                
                let baseY0 = size.height * (1 - f)
                let bob = sin(t * .pi * 2 / bobPeriod) * (waves.map(\.amplitude).max() ?? 0) * 0.4
                let baseY = baseY0 + bob
                
                for (idx,w) in waves.enumerated() {
                    let phase = w.phase0 + CGFloat(t / w.speed) * .pi * 2
                    let amp   = w.amplitude * (0.5 + 0.5 * sin(phase * 2))
                    let alpha = 1 - CGFloat(idx)/CGFloat(waves.count) * 0.6
                    
                    var path = Path()
                    path.move(to: .init(x:0,y:size.height))
                    path.addLine(to: .init(x:0,y:baseY))
                    for x in stride(from:0, through:size.width, by:1) {
                        let rel = x / (size.width / w.waveLen)
                        let y = baseY + sin(rel * .pi*2 + phase) * amp
                        path.addLine(to:.init(x:x,y:y))
                    }
                    path.addLine(to:.init(x:size.width,y:size.height))
                    path.closeSubpath()
                    context.fill(path, with:.color(Color.wBlue.opacity(alpha)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: animatedFraction)
        .onChange(of: fraction) { animatedFraction = $0 }
        .onAppear { animatedFraction = fraction }
        .overlay(
            Circle().stroke(Color.wBlueLight,lineWidth:8)
        )
    }
    private struct WaveParam { let amplitude:CGFloat;let waveLen:CGFloat;let speed:TimeInterval;let phase0:CGFloat }
}


extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
