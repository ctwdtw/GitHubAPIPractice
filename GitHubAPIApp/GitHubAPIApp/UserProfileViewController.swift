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


public class UserProfileViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refresher: UserProfileRefreshController!

    var tableModel: [[CellController]] = [] {
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
        return cellController(at: indexPath).view(for: tableView, at: indexPath)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel[section].count
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath).delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath).dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController {
        tableModel[indexPath.section][indexPath.row]
    }
}
