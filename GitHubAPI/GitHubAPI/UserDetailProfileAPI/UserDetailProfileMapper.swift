//
//  UserDetailProfileMapper.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/18.
//

import Foundation
import Alamofire

public class UserDetailProfileMapper {
    public enum Error: Swift.Error {
        case resourceNotFound
        case unexpected
    }
    
    struct RemoteUserDetailProfile: Decodable {
            public let id: Int
            public let avatar_url: URL
            public let name: String?
            public let bio: String?
            public let login: String
            public let site_admin: Bool
            public let location: String?
            public let blog: URL?
    }
    
    var validStatusCodes: [Int] {
        return [200]
    }
    
    var resourceNotFound: Int {
        404
    }
    
    public init() {}
    
    func map(_ response: DataResponse<[RemoteUserDetailProfile], AFError>) throws -> [UserDetailProfile] {
        
        if let remoteDetailProfiles = response.value {
            let detailProfiles = remoteDetailProfiles.map {
                UserDetailProfile(
                    id: $0.id,
                    avatarUrl: $0.avatar_url,
                    name: $0.name,
                    biography: $0.bio,
                    login: $0.login,
                    siteAdmin: $0.site_admin,
                    location: $0.location,
                    blog: $0.blog
                    
                )}
            
            return detailProfiles
            
        } else if response.response?.statusCode == self.resourceNotFound {
            throw Error.resourceNotFound
            
        } else if let afError = response.error {
            throw afError
            
        } else {
            throw Error.unexpected
            
        }
    }
}
