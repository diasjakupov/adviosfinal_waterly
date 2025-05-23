//
//  TaskFormViewController.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 06.05.2025.
//

import UIKit
import SwiftUI
import Combine

final class TaskFormViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private var editingTask: TaskModel? = nil
    
    func setEditingTask(_ task: TaskModel) {
        self.editingTask = task
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repository = DefaultTaskRepository()
        let addTaskUseCase = AddTaskUseCase(repository: repository)
        let getCategoriesUseCase = GetCategoriesUseCase(repository: repository)
        let settingsRepository = SettingsRepositoryImpl()
        let syncTaskToGoogleCalendarUseCase = SyncTaskToGoogleCalendarUseCase(repository: settingsRepository)
        let restoreSignInUseCase = RestoreGoogleSignInUseCase(repository: settingsRepository)
        let updateTaskUseCase = UpdateTaskUseCase(repository: repository, googleRepository: settingsRepository)
        let vm = TaskFormViewModel(
            addTaskUseCase: addTaskUseCase,
            getCategoriesUseCase: getCategoriesUseCase,
            syncTaskToGoogleCalendarUseCase: syncTaskToGoogleCalendarUseCase,
            restoreGoogleSignInUseCase: restoreSignInUseCase,
            updateTaskUseCase: updateTaskUseCase,
            editingTask: editingTask
        )
        let host = UIHostingController(
            rootView: NavigationStack {
                TaskFormScreen(onClose: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }, editingTask: editingTask)
                .environmentObject(vm)
            }
        )
        addChild(host)
        view.addSubview(host.view)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.didMove(toParent: self)
    
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
