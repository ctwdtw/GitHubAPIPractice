//
//  PaginatedUserProfile.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/15.
//

import Foundation
public struct PaginatedUserProfile {
    public let profiles: [UserProfile]
    public let loadMore: PaginatedLoadMoreAction?
    
    public init(profiles: [UserProfile], loadMore: PaginatedLoadMoreAction? = nil) {
        self.profiles = profiles
        self.loadMore = loadMore
    }
    
}
