//
//  UserProfileViewController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI

public protocol UserProfileLoader {
    typealias Result = Swift.Result<[UserProfile], Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    typealias Complete = (Result) -> Void
    
    func load(url: URL, complete: @escaping Complete) -> ImageDataTask
}

public class UserProfileViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var loader: UserProfileLoader!
    
    private var imageLoader: ImageDataLoader!
    
    private var userProfiles: [UserProfile] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(loader: UserProfileLoader, imageLoader: ImageDataLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.userProfiles = items
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = userProfiles[indexPath.row]
        
        let cell = UserProfileCell()
        cell.loginLabel.text = item.login
        cell.siteAdminLabel.isHidden = !item.siteAdmin
        cell.avatarImageView.image = nil
        
        let loadAvatarImage = { [weak self, weak cell] in
            guard let self = self else { return }
            cell?.imageLoadingIndicator.startAnimating()
            cell?.retryButton.isHidden = true
            
            self.imageDataTasks[indexPath] = self.imageLoader.load(url: item.avatarUrl) { [weak cell] result in
                cell?.imageLoadingIndicator.stopAnimating()
                if let imageData = try? result.get(), let image = UIImage(data: imageData) {
                    cell?.avatarImageView.image = image
                } else {
                    cell?.retryButton.isHidden = false
                }
            }
        }
        
        cell.onRetry = loadAvatarImage
        
        loadAvatarImage()
        
        return cell
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfiles.count
    }
    
    private var imageDataTasks: [IndexPath: ImageDataTask] = [:]
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageDataTasks[indexPath]?.cancel()
        imageDataTasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let url = userProfiles[indexPath.row].avatarUrl
            let task = imageLoader.load(url: url) { _ in }
            imageDataTasks[indexPath] = task
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            imageDataTasks[indexPath]?.cancel()
            imageDataTasks[indexPath] = nil
        }
    }
}
