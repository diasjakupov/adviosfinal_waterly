//
//  SettingsViewController.swift
//  adviosfinal_waterly
//
//  Created by Dias Jakupov on 07.05.2025.
//


import UIKit
import SwiftUI

final class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let root = NavigationStack {                   
            SettingsScreen { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
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
