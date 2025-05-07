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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = TaskFormViewModel()
        let host = UIHostingController(
            rootView: NavigationStack {
                TaskFormScreen(onClose: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
                .environmentObject(vm)
            }
        )
        addChild(host)
        view.addSubview(host.view)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.didMove(toParent: self)
        
        // close after save
        vm.$saved
            .filter { $0 }
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
