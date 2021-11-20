//
//  LoadMoreCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
import GitHubAPI

class LoadMoreViewModel {
    var onStartLoading: (() -> Void)?
    
    var onFinishLoading: (() -> Void)?
    
    var onLoaded: ((UserProfileLoader.Resource) -> Void)?
    
    private let loadAction: UserProfileLoader.Resource.LoadMoreAction
    
    init(_ loadAction: @escaping UserProfileLoader.Resource.LoadMoreAction) {
        self.loadAction = loadAction
    }
    
    func load() {
        onStartLoading?()
        loadAction { [weak self] result in
            switch result {
            case .success(let resource):
                self?.onLoaded?(resource)
            case .failure:
                break
            }
            
            self?.onFinishLoading?()
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
        viewModel.onStartLoading = { [weak cell] in
            cell?.isLoading = true
        }
        
        viewModel.onFinishLoading = { [weak cell] in
            cell?.isLoading = false
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
