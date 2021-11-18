//
//  LoadMoreCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    let cell = LoadMoreCell()
    
    private let loadMoreCallback: () -> Void
    
    init(_ loadMoreCallBack: @escaping () -> Void) {
        self.loadMoreCallback = loadMoreCallBack
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMoreCallback()
    }
    
}
