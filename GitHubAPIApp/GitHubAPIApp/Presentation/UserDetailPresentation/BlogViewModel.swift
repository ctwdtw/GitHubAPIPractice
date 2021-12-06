//
//  BlogViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import Foundation
import GitHubAPI

class BlogViewModel {
    var siteURL: URL? {
        model.blog
    }
    
    var siteAddress: String? {
        model.blog?.absoluteString
    }
    
    private let model: UserDetail
    
    init(model: UserDetail) {
        self.model = model
    }
    
}
