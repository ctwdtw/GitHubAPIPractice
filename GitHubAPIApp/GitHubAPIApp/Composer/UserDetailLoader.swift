//
//  UserDetailLoader.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import Foundation
import GitHubAPI

public protocol UserDetailLoader {
    typealias Resource = UserDetail
    typealias Result = Swift.Result<Resource, Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}
