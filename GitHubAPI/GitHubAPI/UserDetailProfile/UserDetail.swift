//
//  UserDetail.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/18.
//

import Foundation
public struct UserDetail: Equatable {
    public let id: Int
    public let avatarUrl: URL
    public let name: String?
    public let biography: String?
    public let login: String
    public let siteAdmin: Bool
    public let location: String?
    public let blog: URL?
    
    public init(id: Int, avatarUrl: URL, name: String?, biography: String?, login: String, siteAdmin: Bool, location: String?, blog: URL?) {
        self.id = id
        self.avatarUrl = avatarUrl
        self.name = name
        self.biography = biography
        self.login = login
        self.siteAdmin = siteAdmin
        self.location = location
        self.blog = blog
    }

}
