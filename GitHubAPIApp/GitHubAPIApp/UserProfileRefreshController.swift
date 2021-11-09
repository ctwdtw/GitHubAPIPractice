//
//  UserProfileRefreshController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit
import GitHubAPI

public class UserProfileRefreshController: NSObject {
    private lazy var refreshControl: UIRefreshControl = binded(UIRefreshControl())
    
    private let viewModel: UserProfileRefreshViewModel
    
    init(viewModel: UserProfileRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UIRefreshControl {
        refreshControl
    }
    
    private func binded(_ refreshControl: UIRefreshControl) -> UIRefreshControl {
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        
        viewModel.onStartLoading = { [weak refreshControl] in
            refreshControl?.beginRefreshing()
        }
    
        viewModel.onFinishLoading = { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
        
        return refreshControl
    }
    
    @objc func load() {
        viewModel.load()
    }
    
}
