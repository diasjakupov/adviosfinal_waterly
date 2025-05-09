//
//  HomeScreen.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI


struct HomeScreen: View {
    // View-model injected from UIKit host
    @EnvironmentObject private var vm: HomeViewModel
    
    // Call-backs supplied by HomeViewController
    var onAddTask   : () -> Void
    var onSettings  : () -> Void
    
    // Local UI state
    @State private var sheetHeight: CGFloat = 120
    @State private var infoTask   : TaskUI?   = nil          // bottom-sheet
    
    private let days: [DayStub] = {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<10).map { offset in
            DayStub(
                date: cal.date(byAdding: .day, value: offset, to: today)!,
                groups: [("Daily", .random(in:1...4)),
                         ("Work",  .random(in:1...4))]
            )
        }
    }()
    
    init(onAddTask: @escaping () -> Void,
                onSettings: @escaping () -> Void) {
        self.onAddTask  = onAddTask
        self.onSettings = onSettings
    }
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            switch vm.tab {
             case .today:     todayTab
             case .calendar:  calendarTab          // ← NEW
             }
        }
        .preferredColorScheme(.dark)
        .sheetTaskInfo(task: $infoTask){ task, status in
            vm.setStatus(of: task.id, to: status)
        }
    }
    
    private var todayTab: some View {
        VStack(spacing: 32) {
            
            Toolbar(selected: vm.tab,
                    onSettingsClick: onSettings) { tab in
                vm.switchTab(tab)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            
            // WaveGauge – tap to open task form
            WaveGauge(fraction: vm.doneFraction)
                .frame(width: 260, height: 260)
                .onTapGesture { onAddTask() }
            
            Spacer()
        }.overlay(bottomSheet)
    }
    
    private var calendarTab: some View {
        VStack(spacing: 16) {
            Toolbar(selected: vm.tab,
                    onSettingsClick: onSettings) { vm.switchTab($0) }
                .padding(.horizontal).padding(.top, 8)
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.calendarDays) { day in CalendarCard(day: day) }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
            Spacer()
        }
    }
    
    @ViewBuilder private var bottomSheet: some View {
        let uiToday = vm.today.enumerated()
            .map { TaskModelMapper.toUi($0.element, index: $0.offset) }
        
        CustomBottomSheet(height: $sheetHeight) {
            TodayTasksSection(tasks: uiToday) { t in
                infoTask = t
            }
        }
    }

}


private extension View {
    @ViewBuilder
    func sheetTaskInfo(task: Binding<TaskUI?>, onChangeStatus: @escaping (TaskUI, TaskStatus) -> Void) -> some View {
        self.sheet(item: task) { t in
            TaskInfoBottomSheet(
                task: t,
                onDismiss: { task.wrappedValue = nil },
                onChangeStatus: { newStatus in
                    onChangeStatus(t, newStatus)
                }
            )
            .presentationDetents([.medium])
        }
    }
}


struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View { HomeScreen {
        
    } onSettings: {
        
    }
}
}
