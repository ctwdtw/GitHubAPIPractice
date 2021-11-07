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
    
    private var imageLoader: ImageDataLoader!
    
    convenience public init(loader: UserProfileLoader, imageLoader: ImageDataLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    func view() -> UIRefreshControl {
        refreshControl
    }
    
    var onRefreshed: (([UserProfileCellController]) -> Void)?
    
    @objc func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            if let items = try? result.get(),
                let controllers = self?.adapt(items: items) {
                self?.onRefreshed?(controllers)
            }
            
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func adapt(items: [UserProfile]) -> [UserProfileCellController] {
        return items.map { UserProfileCellController(item: $0, imageLoader: imageLoader) }
    }
    
}
