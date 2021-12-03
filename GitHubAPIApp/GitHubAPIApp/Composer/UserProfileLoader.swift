//
//  UserProfileLoader.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/14.
//

import Foundation
import GitHubAPI

public protocol UserProfileLoader {
    typealias Resource = PaginatedUserProfile
    typealias Result = Swift.Result<Resource, Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}
