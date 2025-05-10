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
    
    @State private var infoTask   : TaskUI?   = nil
    @State private var calendarSheet: CalendarSheetState? = nil
    @Binding var editingTask: TaskModel?
    @Binding var showTaskForm: Bool
    let updateTaskUseCase: UpdateTaskUseCase
    let addTaskUseCase: AddTaskUseCase
    let getCategoriesUseCase: GetCategoriesUseCase
    let syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase
    let restoreSignInUseCase: RestoreGoogleSignInUseCase
    @State private var infoTaskError: String? = nil
    
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
                onSettings: @escaping () -> Void,
                onAnalytics: @escaping () -> Void,
                editingTask: Binding<TaskModel?>,
                showTaskForm: Binding<Bool>,
                updateTaskUseCase: UpdateTaskUseCase,
                addTaskUseCase: AddTaskUseCase,
                getCategoriesUseCase: GetCategoriesUseCase,
                syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase,
                restoreSignInUseCase: RestoreGoogleSignInUseCase) {
        self.onAddTask   = onAddTask
        self.onSettings  = onSettings
        self.onAnalytics = onAnalytics
        self._editingTask = editingTask
        self._showTaskForm = showTaskForm
        self.updateTaskUseCase = updateTaskUseCase
        self.addTaskUseCase = addTaskUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        self.syncTaskToGoogleCalendarUseCase = syncTaskToGoogleCalendarUseCase
        self.restoreSignInUseCase = restoreSignInUseCase
    }
    
    var body: some View {
        ZStack {
            Color.wBackground.ignoresSafeArea()
            
            switch vm.tab {
             case .today:     todayTab
             case .calendar:  calendarTab
             }
            if let error = vm.error {
                ErrorBanner(message: error)
            }
        }
        .preferredColorScheme(.dark)
        .sheetTaskInfo(
            task: $infoTask,
            error: $infoTaskError,
            onChangeStatus: { task, status in
                vm.setStatus(of: task.id, to: status)
            },
            onEdit: { taskUI in
                if let model = vm.findTaskModel(by: taskUI.id) {
                    infoTask = nil
                    editingTask = model
                    showTaskForm = true
                }
            },
            onDelete: { taskUI in
                if let model = vm.findTaskModel(by: taskUI.id) {
                    Task {
                        do {
                            try await vm.deleteTask(model)
                            infoTask = nil
                            editingTask = nil
                            showTaskForm = false
                        } catch {
                            infoTaskError = error.localizedDescription
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showTaskForm) {
            if let editingTask = editingTask {
                TaskFormScreen(onClose: {
                    showTaskForm = false
                }, editingTask: editingTask)
                    .environmentObject(
                        TaskFormViewModel(
                            addTaskUseCase: addTaskUseCase,
                            getCategoriesUseCase: getCategoriesUseCase,
                            syncTaskToGoogleCalendarUseCase: syncTaskToGoogleCalendarUseCase,
                            restoreGoogleSignInUseCase: restoreSignInUseCase,
                            updateTaskUseCase: updateTaskUseCase,
                            editingTask: editingTask
                        )
                    )
            }
        }
    }
    
    private var todayTab: some View {
        VStack(spacing: 32) {
            Toolbar(selected: vm.tab,
                    onSettingsClick: onSettings,
                    onAnalyticsClick: onAnalytics) { tab in
                vm.switchTab(tab)
            }
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
                            .onTapGesture {
                                calendarSheet = .date(day.date)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
            Spacer()
        }
        .sheet(item: $calendarSheet) { sheet in
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
                TaskInfoBottomSheet(
                    task: task,
                    onDismiss: { calendarSheet = nil },
                    onChangeStatus: { newStatus in
                        vm.setStatus(of: task.id, to: newStatus)
                    }
                )
                .presentationDetents([.medium])
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

