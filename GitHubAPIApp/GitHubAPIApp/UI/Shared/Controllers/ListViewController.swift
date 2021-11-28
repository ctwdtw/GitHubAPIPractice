//
//  ListViewController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI

public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    public var prototypeCellInstances: [UITableViewCell] = []
    
    public typealias TableModel = [[CellController]]
    
    private var loadingControllers: [IndexPath: CellController] = [:]
    
    private var refresher: RefreshController?

    public private(set) var tableModel: TableModel = [[]] {
        didSet {
            tableView.reloadData()
        }
    }
    
    convenience init(refreshController: RefreshController) {
        self.init()
        self.refresher = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureTableView()
        refresher?.load()
    }
    
    public func display(_ model: TableModel) {
        loadingControllers = [:]
        tableModel = model
    }
    
    private func configureTableView() {
        tableView.prefetchDataSource = self
        prototypeCellInstances.forEach { cell in
            tableView.registerCell(cell)
        }
    }
    
    private func configureRefreshControl() {
        refreshControl = refresher?.view()
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ds = cellController(at: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
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
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath).delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(at: indexPath)
        let dl = controller?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath).delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
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
