//
//  UserProfileURLPackage.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/11/12.
//

import Foundation
public struct UserProfileURLPackage {
    public let userProfiles: [UserProfile]
    public let nextURL: URL?
    
    public init(_ userProfiles: [UserProfile], nextURL: URL? = nil) {
        self.userProfiles = userProfiles
        self.nextURL = nextURL
    }
}
