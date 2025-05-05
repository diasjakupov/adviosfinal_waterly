//
//  TaskFormViewController.swift
//  adviosfinal
//
//  Created by Dias Jakupov on 06.05.2025.
//


import UIKit
import SwiftUI

final class TaskFormViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let host = UIHostingController(rootView: TaskFormScreen())
        addChild(host)
        view.addSubview(host.view)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.didMove(toParent: self)
    }
}