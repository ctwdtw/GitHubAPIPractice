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
    
    var onRefreshed: ((UserProfileLoader.Resource) -> Void)?
    
    func load() {
        onStartLoading?()
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            if let resource = try? result.get() {
                self.onRefreshed?(resource)
            }
            
            self.onFinishLoading?()
        }
    }
}
