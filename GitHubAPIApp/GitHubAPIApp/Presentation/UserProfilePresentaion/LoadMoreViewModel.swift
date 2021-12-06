//
//  LoadMoreViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/22.
//

import Foundation
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
