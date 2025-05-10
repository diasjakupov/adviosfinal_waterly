//
//  SettingsViewController.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//


import UIKit
import SwiftUI

final class SettingsViewController: UIViewController {
    var allTasks: [TaskModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        let repository = SettingsRepositoryImpl()
        let connectUseCase = ConnectGoogleCalendarUseCase(repository: repository)
        let disconnectUseCase = DisconnectGoogleCalendarUseCase(repository: repository)
        let syncUseCase = SyncTasksToGoogleCalendarUseCase(repository: repository)
        let toggleNotifUseCase = ToggleNotificationsUseCase(repository: repository)
        let restoreSignInUseCase = RestoreGoogleSignInUseCase(repository: repository)
        let vm = SettingsViewModel(
            connectGoogleCalendarUseCase: connectUseCase,
            disconnectGoogleCalendarUseCase: disconnectUseCase,
            syncTasksToGoogleCalendarUseCase: syncUseCase,
            toggleNotificationsUseCase: toggleNotifUseCase,
            restoreGoogleSignInUseCase: restoreSignInUseCase,
            allTasks: allTasks
        )
        let root = NavigationStack {
            SettingsScreen(onClose: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }, vm: vm)
        }

        let host = UIHostingController(rootView: root)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }
}
