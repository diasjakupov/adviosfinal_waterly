//
//  StatisticsScreen.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 10.05.2025.
//

import SwiftUI

struct StatisticsScreen: View {
    var onClose: () -> Void
    @ObservedObject var vm: StatisticsViewModel
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    Text("Statistic")
                        .font(.title2).bold().foregroundColor(.white)
                    Spacer(minLength: 32)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Card with donut chart
                if let stats = vm.statistics {
                    VStack(alignment: .center, spacing: 16) {
                        HStack {
                            Text("All time")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        ZStack {
                            DonutChart(done: stats.done, missed: stats.missed)
                                .frame(width: 180, height: 180)
                            Text("\(stats.total)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        HStack(spacing: 24) {
                            HStack(spacing: 6) {
                                Circle().fill(Color.purple).frame(width: 10, height: 10)
                                Text("Missed").foregroundColor(.white).font(.caption)
                            }
                            HStack(spacing: 6) {
                                Circle().fill(Color.green).frame(width: 10, height: 10)
                                Text("Done").foregroundColor(.white).font(.caption)
                            }
                        }
                        .padding(.top, 4)
                        Button(action: {/* TODO: breakdown */}) {
                            Text("View Detailed Breakdown")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.wSurface)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.wSurface)
                    .cornerRadius(24)
                    .padding(.horizontal)
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 80)
                }
                Spacer()
            }
        }
        .onAppear { vm.load() }
    }
}

struct DonutChart: View {
    let done: Int
    let missed: Int
    var total: Int { done + missed }
    var doneFraction: Double { total == 0 ? 0 : Double(done) / Double(total) }
    var missedFraction: Double { total == 0 ? 0 : Double(missed) / Double(total) }
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(doneFraction))
                .stroke(Color.green, lineWidth: 24)
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: CGFloat(doneFraction), to: 1)
                .stroke(Color.purple, lineWidth: 24)
                .rotationEffect(.degrees(-90))
        }
    }
}
