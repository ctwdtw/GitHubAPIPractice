//
//  UserProfileRefreshController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit
import GitHubAPI

public class UserProfileRefreshController: NSObject {
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }()
    
    
    private var loader: UserProfileLoader!
    
    convenience init(loader: UserProfileLoader) {
        self.init()
        self.loader = loader
    }
    
    func view() -> UIRefreshControl {
        refreshControl
    }
    
    var onRefreshed: (([UserProfile]) -> Void)?
    
    @objc func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.onRefreshed?(items)
            }
            
            self?.refreshControl.endRefreshing()
        }
    }
    
}
