//
//  HomeScreen.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI

private let sampleTasks: [Task] = [
    Task(title:"You Have A Meeting", start:"3:00 PM", end:"3:30 PM",
         duration:"30 Min",
         bg: Color(red:0.85,green:0.80,blue:0.78),
         titleColor: Color(red:0.24,green:0.15,blue:0.14),
         chipColor: Color(red:0.36,green:0.25,blue:0.22)),
    Task(title:"You Have A Meeting", start:"4:00 PM", end:"4:30 PM",
         duration:"30 Min",
         bg: Color(red:0.66,green:0.69,blue:0.70),
         titleColor: Color(red:0.23,green:0.28,blue:0.28),
         chipColor: Color(red:0.23,green:0.28,blue:0.28))
]

struct HomeScreen: View {
    var onAddTask:     () -> Void
    
    @State private var selected = 0
    @State private var sheetHeight: CGFloat = 90
    @State private var fraction: CGFloat = 0.7
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Toolbar
                HStack(spacing: 12) {
                    PillButton(text: "Today",   isOn: selected == 0) { selected = 0 }
                    PillButton(text: "Calendar",isOn: selected == 1) { selected = 1 }
                    Spacer()
                    Button { /* settings nav */ } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Wave gauge
                WaveGauge(fraction: fraction)
                    .frame(width:280,height:280)
                    .onTapGesture {
                        onAddTask()
                    }
                
                // Statistics card
                StatisticCard()
                    .padding(.horizontal)
                
                Spacer()
            }
            
            // Bottom sheet
            BottomSheet(height: $sheetHeight) {
                TodayTasksSection(tasks: sampleTasks)
            }
        }
        .preferredColorScheme(.dark)
    }
}



struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View { HomeScreen {
        
    } }
}
