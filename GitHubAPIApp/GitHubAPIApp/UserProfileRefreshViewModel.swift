//
//  UserProfileRefreshViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/9.
//

import Foundation
import GitHubAPI

class UserProfileRefreshViewModel {
    private let loader: UserProfileLoader
    
    init(loader: UserProfileLoader) {
        self.loader = loader
    }
    
    var onStartLoading: (() -> Void)?
    
    var onFinishLoading: (() -> Void)?
    
    var onRefreshed: (([UserProfile]) -> Void)?
    
    func load() {
        onStartLoading?()
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            if let items = try? result.get() {
                self.onRefreshed?(items)
            }
            
            self.onFinishLoading?()
        }
    }
}
