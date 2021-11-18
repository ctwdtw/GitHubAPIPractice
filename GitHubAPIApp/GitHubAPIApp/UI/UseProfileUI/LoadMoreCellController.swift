//
//  LoadMoreCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
class LoadMoreCellController: NSObject, UITableViewDataSource {
    let cell = LoadMoreCell()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell
    }
}
