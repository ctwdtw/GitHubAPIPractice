//
//  UserProfile.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/15.
//

import Foundation
public struct UserProfile: Equatable {
    public let id: Int
    public let login: String
    public let avatarUrl: URL
    public let siteAdmin: Bool
    
    public init(id: Int, login: String, avatarUrl: URL, siteAdmin: Bool) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.siteAdmin = siteAdmin
    }
}
