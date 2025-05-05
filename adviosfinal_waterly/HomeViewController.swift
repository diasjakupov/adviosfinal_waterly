//
//  HomeViewController.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 06.05.2025.
//


import UIKit
import SwiftUI

final class HomeViewController: UIViewController {

    private weak var host: UIHostingController<HomeScreen>?

    override func viewDidLoad() {
        super.viewDidLoad()
        embedHome()
    }
    
    private func embedHome() {
        let home = HomeScreen(
            onAddTask: { [weak self] in
                self?.showTaskForm()
            }
        )
        let hostVC = UIHostingController(rootView: home)
        addChild(hostVC)
        view.addSubview(hostVC.view)
        hostVC.view.frame = view.bounds
        hostVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostVC.didMove(toParent: self)
        self.host = hostVC
    }
    
    private func showTaskForm() {
        let formVC = TaskFormViewController()
        navigationController?.pushViewController(formVC, animated: true)
    }
}
