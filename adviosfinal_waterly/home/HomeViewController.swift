//
//  HomeViewController.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 06.05.2025.
//


import UIKit
import SwiftUI

final class HomeViewController: UIViewController {
    private let vm: HomeViewModel
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let addTaskUseCase: AddTaskUseCase
    private let getCategoriesUseCase: GetCategoriesUseCase
    private let syncTaskToGoogleCalendarUseCase: SyncTaskToGoogleCalendarUseCase
    private let restoreSignInUseCase: RestoreGoogleSignInUseCase
    private let taskRepository: DefaultTaskRepository
    private let settingsRepository: SettingsRepositoryImpl
    
    private var editingTaskBox = StateBox<TaskModel?>(wrappedValue: nil)
    private var showTaskFormBox = StateBox<Bool>(wrappedValue: false)
    
    init() {
        let repository = DefaultHomeRepository()
        let getTaskStreamUseCase = GetTaskStreamUseCase(repository: repository)
        let updateTaskStatusUseCase = UpdateHomeTaskStatusUseCase(repository: repository)
        self.taskRepository = DefaultTaskRepository()
        self.settingsRepository = SettingsRepositoryImpl()
        self.deleteTaskUseCase = DeleteTaskUseCase(repository: taskRepository, googleRepository: settingsRepository)
        self.updateTaskUseCase = UpdateTaskUseCase(repository: taskRepository, googleRepository: settingsRepository)
        self.addTaskUseCase = AddTaskUseCase(repository: taskRepository)
        self.getCategoriesUseCase = GetCategoriesUseCase(repository: taskRepository)
        self.syncTaskToGoogleCalendarUseCase = SyncTaskToGoogleCalendarUseCase(repository: settingsRepository)
        self.restoreSignInUseCase = RestoreGoogleSignInUseCase(repository: settingsRepository)
        self.vm = HomeViewModel(
            getTaskStreamUseCase: getTaskStreamUseCase,
            updateTaskStatusUseCase: updateTaskStatusUseCase,
            deleteTaskUseCase: deleteTaskUseCase
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(
            rootView: HomeScreen(
                onAddTask: { [weak self] in self?.gotoForm() },
                onSettings: { [weak self] in self?.showSettings() },
                onAnalytics: { [weak self] in self?.showStatistics() },
                editingTask: editingTaskBox.binding,
                showTaskForm: showTaskFormBox.binding,
                updateTaskUseCase: updateTaskUseCase,
                addTaskUseCase: addTaskUseCase,
                getCategoriesUseCase: getCategoriesUseCase,
                syncTaskToGoogleCalendarUseCase: syncTaskToGoogleCalendarUseCase,
                restoreSignInUseCase: restoreSignInUseCase
            )
            .environmentObject(vm)
        )
        addChild(host)
        view.addSubview(host.view)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        host.didMove(toParent: self)
    }
    
    private func gotoForm() {
        navigationController?.pushViewController(TaskFormViewController(), animated: true)
    }
    
    private func showSettings() {
        let vc = SettingsViewController()
        vc.allTasks = vm.allTasks
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showStatistics() {
        let vc = StatisticsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class StateBox<Value>: ObservableObject {
    @Published var wrappedValue: Value
    var binding: Binding<Value> { Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 }) }
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}
