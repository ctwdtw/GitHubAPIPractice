//
//  LocationViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import GitHubAPI

class LocationViewModel {
    var location: String? {
        return model.location
    }
    
    private let model: UserDetail
    
    init(model: UserDetail) {
        self.model = model
    }
    
}


