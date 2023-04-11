//
//  CommentListViewController.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 09.04.2023.
//

import Foundation
import UIKit
import SwiftUI

class CommentListViewController: UIViewController {
    
    var comments: [Comment] = []
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            let commentListView = CommentListView(comments: comments)
            let hostingController = UIHostingController(rootView: commentListView)
            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingController.view)
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            hostingController.didMove(toParent: self)
        }
}
