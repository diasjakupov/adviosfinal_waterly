//
//  HomeScreen.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 05.05.2025.
//

import SwiftUI


struct HomeScreen: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    var onAddTask   : () -> Void
    var onSettings  : () -> Void
    var onAnalytics : () -> Void
    var onEditTask  : (TaskModel) -> Void
    
    @State private var infoTask   : TaskUI?   = nil
    @State private var calendarSheet: CalendarSheetState? = nil
    @State private var infoTaskError: String? = nil
    
    init(onAddTask: @escaping () -> Void,
        onSettings: @escaping () -> Void,
        onAnalytics: @escaping () -> Void,
        onEditTask: @escaping (TaskModel) -> Void) {
        self.onAddTask   = onAddTask
        self.onSettings  = onSettings
        self.onAnalytics = onAnalytics
        self.onEditTask  = onEditTask
    }
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            mainTabView
            errorBanner
        }
        .preferredColorScheme(.dark)
        .sheetTaskInfo(
            task: $infoTask,
            error: $infoTaskError,
            onChangeStatus: { task, status in vm.setStatus(of: task.id, to: status) },
            onEdit: { handleEdit(taskUI: $0, dismiss: { infoTask = nil }) },
            onDelete: { handleDelete(taskUI: $0, dismiss: { infoTask = nil }) }
        )
    }
    
    // MARK: - Main Tab View
    @ViewBuilder
    private var mainTabView: some View {
        switch vm.tab {
        case .today:
            todayTab
        case .calendar:
            calendarTab
        }
    }
    
    // MARK: - Today Tab
    private var todayTab: some View {
        VStack(spacing: 32) {
            Toolbar(selected: vm.tab,
                    onSettingsClick: onSettings,
                    onAnalyticsClick: onAnalytics) { tab in vm.switchTab(tab) }
                .padding(.horizontal)
                .padding(.top, 8)
            WaveGauge(fraction: vm.doneFraction)
                .frame(width: 260, height: 260)
                .onTapGesture { onAddTask() }
            TasksSection(tasks: vm.today.enumerated().map { TaskModelMapper.toUi($0.element, index: $0.offset) }) { t in
                infoTask = t
            }
            Spacer()
        }
    }
    
    // MARK: - Calendar Tab
    private var calendarTab: some View {
        VStack(spacing: 16) {
            Toolbar(selected: vm.tab,
                    onSettingsClick: onSettings,
                    onAnalyticsClick: onAnalytics) { vm.switchTab($0) }
                .padding(.horizontal).padding(.top, 8)
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.calendarDays) { day in
                        CalendarCard(day: day)
                            .onTapGesture { calendarSheet = .date(day.date) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
            Spacer()
        }
        .sheet(item: $calendarSheet) { sheet in
            calendarSheetView(sheet: sheet)
        }
    }
    
    // MARK: - Calendar Sheet View
    @ViewBuilder
    private func calendarSheetView(sheet: CalendarSheetState) -> some View {
        switch sheet {
        case .date(let date):
            let tasks = (vm.grouped[date] ?? []).enumerated().map { TaskModelMapper.toUi($0.element, index: $0.offset) }
            VStack(alignment: .leading, spacing: 16) {
                Text(date.formatted(date: .long, time: .omitted))
                    .font(.title2).bold().foregroundColor(.white)
                    .padding(.top, 16)
                    .padding(.horizontal)
                TasksSection(tasks: tasks) { t in
                    calendarSheet = .task(t)
                }
            }
            .background(Color.wSurface)
            .presentationDetents([.medium, .large])
        case .task(let task):
            makeTaskInfoBottomSheet(task: task, onDismiss: {
                infoTaskError = nil
                calendarSheet = nil
            })
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Error Banner
    @ViewBuilder
    private var errorBanner: some View {
        if let error = vm.error {
            ErrorBanner(message: error)
        }
    }
    
    // MARK: - TaskInfoBottomSheet Helper
    private func makeTaskInfoBottomSheet(task: TaskUI, onDismiss: @escaping () -> Void) -> some View {
        TaskInfoBottomSheet(
            task: task,
            onDismiss: onDismiss,
            onChangeStatus: { newStatus in vm.setStatus(of: task.id, to: newStatus) },
            onEdit: { handleEdit(taskUI: $0, dismiss: onDismiss) },
            onDelete: { handleDelete(taskUI: $0, dismiss: onDismiss) },
            error: infoTaskError
        )
    }
    
    // MARK: - Handlers
    private func handleEdit(taskUI: TaskUI, dismiss: @escaping () -> Void) {
        if let model = vm.findTaskModel(by: taskUI.id) {
            dismiss()
            onEditTask(model)
        }
    }
    private func handleDelete(taskUI: TaskUI, dismiss: @escaping () -> Void) {
        if let model = vm.findTaskModel(by: taskUI.id) {
            Task {
                do {
                    try await vm.deleteTask(model)
                    dismiss()
                } catch {
                    infoTaskError = error.localizedDescription
                }
            }
        }
    }
}


private extension View {
    @ViewBuilder
    func sheetTaskInfo(
        task: Binding<TaskUI?>,
        error: Binding<String?> = .constant(nil),
        onChangeStatus: @escaping (TaskUI, TaskStatus) -> Void,
        onEdit: @escaping (TaskUI) -> Void,
        onDelete: @escaping (TaskUI) -> Void
    ) -> some View {
        self.sheet(item: task) { t in
            TaskInfoBottomSheet(
                task: t,
                onDismiss: { task.wrappedValue = nil },
                onChangeStatus: { newStatus in onChangeStatus(t, newStatus) },
                onEdit: onEdit,
                onDelete: onDelete,
                error: error.wrappedValue
            )
            .presentationDetents([.medium])
        }
    }
}

