//
//  SiteAdminViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import Foundation
import GitHubAPI

class SiteAdminViewModel {
    var loginText: String {
        model.login
    }
    
    var isSiteAdmin: Bool {
        model.siteAdmin
    }
    
    private let model: UserDetail
    
    init(model: UserDetail) {
        self.model = model
    }
}
