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

    private var cellControllers: [UserProfileCellController] = [] {
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
        tableView.registerCell(type: UserProfileCell.self)
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] result in
            if let items = try? result.get(),
                let controllers = self?.adapt(items: items) {
                self?.cellControllers = controllers
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func adapt(items: [UserProfile]) -> [UserProfileCellController] {
        return items.map { UserProfileCellController(item: $0, imageLoader: imageLoader) }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellControllers[indexPath.row].view(for: tableView, at: indexPath)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellControllers.count
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellControllers[indexPath.row].cancel()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath.row].load()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath.row].cancel()
        }
    }
}
