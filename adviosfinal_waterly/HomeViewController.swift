//
//  HomeViewController.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 06.05.2025.
//


import UIKit
import SwiftUI

final class HomeViewController: UIViewController {
    private let vm = HomeViewModel(
        repo: DefaultHomeRepository()
    )
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
