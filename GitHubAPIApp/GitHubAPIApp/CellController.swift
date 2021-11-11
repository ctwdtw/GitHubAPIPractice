//
//  CellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/11.
//

import UIKit
struct CellController {
    private let viewCreator: CellViewCreator
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    init(viewCreator: CellViewCreator) {
        self.viewCreator = viewCreator
        self.delegate = viewCreator as? UITableViewDelegate
        self.dataSourcePrefetching = viewCreator as? UITableViewDataSourcePrefetching
    }
    
    func view(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return viewCreator.view(for: tableView, at: indexPath)
    }
}
