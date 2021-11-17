//
//  UserProfileViewController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI

public class UserProfileViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    public typealias TableModel = [[CellController]]
    
    private var loadingControllers: [IndexPath: CellController] = [:]
    
    private var refresher: UserProfileRefreshController?

    private var tableModel: TableModel = [] {
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
        refresher?.load()
    }
    
    public func display(_ cellControllers: [[CellController]]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    private func configureTableView() {
        tableView.prefetchDataSource = self
        tableView.registerCell(type: UserProfileCell.self)
    }
    
    private func configureRefreshControl() {
        refreshControl = refresher?.view()
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
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingController(at: indexPath)
            let dsp = controller?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(at: indexPath)
        let dl = controller?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.section][indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func removeLoadingController(at indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
    
}
