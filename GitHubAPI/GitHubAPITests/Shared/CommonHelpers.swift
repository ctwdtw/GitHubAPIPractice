//
//  CommonHelpers.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
import GitHubAPI
//MARK: - common helpers
func makeUserProfilesJSON(profiles: [[String: Any]]) -> Data {
    let data = try! JSONSerialization.data(withJSONObject: profiles, options: .prettyPrinted)
    return data
}

func makeUserProfile(
    id: Int = Int.random(in: 1...1000),
    login: String = "a-login-name",
    avatarUrl: String = "https://any-url.com",
    siteAdmin: Bool = false
) -> (model: UserProfile, json: [String: Any]) {
    let json: [String: Any] = [ "id": id, "login": login, "avatar_url": avatarUrl, "site_admin": siteAdmin]
    let model = UserProfile(id: id, login: login, avatarUrl: URL(string: avatarUrl)! , siteAdmin: siteAdmin)
    return (model, json)
}

func makeUserDetailJSON(detail: [String: Any?]) -> Data {
    let data = try! JSONSerialization.data(withJSONObject: detail, options: .prettyPrinted)
    return data
}

func makeUserDetail(
    id: Int = Int.random(in: 1...1000),
    avatarUrl: String = "https://any-url.com",
    name: String? = nil,
    biography: String? = nil,
    login: String = "a-login-name",
    siteAdmin: Bool = false,
    location: String? = nil,
    blog: String? = nil
) -> (model: UserDetail, json: [String: Any?]) {
    let json: [String: Any?] =
    [ "id": id,
      "avatar_url": avatarUrl,
      "name": name,
      "bio": biography,
      "login": login,
      "site_admin": siteAdmin,
      "location": location,
      "blog": blog
    ]
    
    var url: URL?
    if let blog = blog {
        url = URL(string: blog)
    }
    
    let model = UserDetail(
        id: id,
        avatarUrl: URL(string: avatarUrl)!,
        name: name,
        biography: biography,
        login: login,
        siteAdmin: siteAdmin,
        location: location,
        blog: url
    )
    
    return (model, json)
}

func anyNSError() -> NSError {
    NSError(domain: "any-ns-error", code: -1, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "https://any-url.ocm")!
}

func anyData() -> Data {
    return "any-non-empty-data".data(using: .utf8)!
}

func anyHTTPURLResponse(statusCode: Int, httpVersion: String? = nil, headerFields: [String : String]? = nil) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: httpVersion, headerFields: headerFields)!
}
