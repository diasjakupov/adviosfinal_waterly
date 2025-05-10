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
    private let bobPeriod: TimeInterval = 10
    
    var body: some View {
        TimelineView(.animation) { context in
            let currentTime = context.date.timeIntervalSinceReferenceDate
            let clampedFraction = fraction.clamped(to: 0...1)
            
            Canvas { canvasContext, canvasSize in
                canvasContext.clip(to: Path(ellipseIn: CGRect(origin: .zero, size: canvasSize)))
                
                let baseWaterLevelY = canvasSize.height * (1 - clampedFraction)
                let bobbingOffset = sin(currentTime * .pi * 2 / bobPeriod) * (waves.map(\ .amplitude).max() ?? 0) * 0.4
                let waterLevelY = baseWaterLevelY + bobbingOffset
                
                for (waveIndex, wave) in waves.enumerated() {
                    let phase = wave.phase0 + CGFloat(currentTime / wave.speed) * .pi * 2
                    let amplitude = wave.amplitude * (0.5 + 0.5 * sin(phase * 2))
                    let opacity = 1 - CGFloat(waveIndex)/CGFloat(waves.count) * 0.6
                    
                    var wavePath = Path()
                    wavePath.move(to: .init(x:0, y:canvasSize.height))
                    wavePath.addLine(to: .init(x:0, y:waterLevelY))
                    for x in stride(from: 0, through: canvasSize.width, by: 1) {
                        let relativeX = x / (canvasSize.width / wave.waveLen)
                        let y = waterLevelY + sin(relativeX * .pi*2 + phase) * amplitude
                        wavePath.addLine(to: .init(x: x, y: y))
                    }
                    wavePath.addLine(to: .init(x: canvasSize.width, y: canvasSize.height))
                    wavePath.closeSubpath()
                    canvasContext.fill(wavePath, with: .color(Color.wBlue.opacity(opacity)))
                }
            }
        }
        .overlay(
            Circle().stroke(Color.wBlueLight, lineWidth: 8)
        )
    }
    private struct WaveParam { let amplitude:CGFloat;let waveLen:CGFloat;let speed:TimeInterval;let phase0:CGFloat }
}


extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
