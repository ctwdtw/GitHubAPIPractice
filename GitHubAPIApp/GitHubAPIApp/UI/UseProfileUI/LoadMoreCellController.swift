//
//  LoadMoreCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit

class LoadMoreViewModel {
    var onStartLoading: (() -> Void)?
    
    private let loadAction: () -> Void
    
    init(_ loadAction: @escaping () -> Void) {
        self.loadAction = loadAction
    }
    
    func load() {
        onStartLoading?()
        loadAction()
    }
}

class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    let cell = LoadMoreCell()
    
    private let viewModel: LoadMoreViewModel
    
    init(viewModel: LoadMoreViewModel) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return binded(cell)
    }
    
    private func binded(_ cell: LoadMoreCell) -> LoadMoreCell {
        viewModel.onStartLoading = { [weak cell] in
            cell?.isLoading = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell.isLoading == false else {
            return
        }
        
        viewModel.load()
    }
    
}
