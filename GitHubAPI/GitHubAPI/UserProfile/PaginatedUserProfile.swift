//
//  PaginatedUserProfile.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/28.
//

import Foundation
public struct PaginatedUserProfile {
    public typealias Result = Swift.Result<PaginatedUserProfile, Swift.Error>
    
    public typealias Complete = (Result) -> Void
    
    public typealias LoadMoreAction = (@escaping Complete) -> Void
    
    public let userProfiles: [UserProfile]
    
    public let loadMore: LoadMoreAction?
}
