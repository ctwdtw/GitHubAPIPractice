//
//  CellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/11.
//

import UIKit
public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    init(dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}
