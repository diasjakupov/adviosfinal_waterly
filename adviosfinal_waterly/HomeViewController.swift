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
    
    init() {
        let repository = DefaultHomeRepository()
        let getTaskStreamUseCase = GetTaskStreamUseCase(repository: repository)
        let updateTaskStatusUseCase = UpdateHomeTaskStatusUseCase(repository: repository)
        self.vm = HomeViewModel(
            getTaskStreamUseCase: getTaskStreamUseCase,
            updateTaskStatusUseCase: updateTaskStatusUseCase
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
                onSettings: { [weak self] in self?.showSettings() }
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
        vc.homeViewModel = vm
        navigationController?.pushViewController(vc, animated: true)
    }
}
