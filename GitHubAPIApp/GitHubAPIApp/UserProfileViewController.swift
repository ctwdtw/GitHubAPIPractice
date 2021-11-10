//
//  UserProfileViewController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI

public protocol UserProfileLoader {
    typealias Resource = UserProfileURLPackage
    typealias Result = Swift.Result<Resource, Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    typealias Complete = (Result) -> Void
    
    func load(url: URL, complete: @escaping Complete) -> ImageDataTask
}

public class UserProfileViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refresher: UserProfileRefreshController!

    var cellControllers: [UserProfileCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(refreshController: UserProfileRefreshController) {
        self.init()
        self.refresher = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureTableView()
        refresher.load()
    }
    
    private func configureTableView() {
        tableView.prefetchDataSource = self
        tableView.registerCell(type: UserProfileCell.self)
    }
    
    private func configureRefreshControl() {
        refreshControl = refresher.view()
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
        cellControllers[indexPath.row].cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath.row].preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath.row].cancelLoad()
        }
    }
}
