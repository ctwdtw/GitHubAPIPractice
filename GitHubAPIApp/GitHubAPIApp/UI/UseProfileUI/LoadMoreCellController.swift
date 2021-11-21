//
//  LoadMoreCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
import GitHubAPI

class LoadMoreViewModel {
    var onLoadMoreStart: (() -> Void)?
    
    var onLoadMoreFinished: ((Error?) -> Void)?
    
    var onLoadMore: ((UserProfileLoader.Resource) -> Void)?
    
    private let loadAction: UserProfileLoader.Resource.LoadMoreAction
    
    init(_ loadAction: @escaping UserProfileLoader.Resource.LoadMoreAction) {
        self.loadAction = loadAction
    }
    
    func load() {
        onLoadMoreStart?()
        loadAction { [weak self] result in
            switch result {
            case .success(let resource):
                self?.onLoadMore?(resource)
                self?.onLoadMoreFinished?(nil)
            case .failure(let error):
                self?.onLoadMoreFinished?(error)
                
            }
        }
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
        viewModel.onLoadMoreStart = { [weak cell] in
            cell?.isLoading = true
            cell?.message = nil
        }
        
        viewModel.onLoadMoreFinished = { [weak cell] error in
            cell?.isLoading = false
            cell?.message = error?.localizedDescription
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
