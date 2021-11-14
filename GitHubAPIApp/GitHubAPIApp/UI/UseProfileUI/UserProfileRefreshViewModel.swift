//
//  UserProfileRefreshViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/9.
//

import Foundation
import GitHubAPI

class UserProfileRefreshViewModel {
    var onStartLoading: (() -> Void)?
    
    var onFinishLoading: (() -> Void)?
    
    var onRefreshed: (([UserProfileCellController]) -> Void)?
    
    var loadAction: (() -> Void)?
}
