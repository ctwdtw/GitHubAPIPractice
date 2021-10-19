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
        case connectivity
        case invalidData
        case notModified
        case loaderHasDeallocated
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
    
    var nonModifiedStatusCode: Int {
        304
    }
    
    private(set) var currentHeaders: [AnyHashable: Any]?
    
    public init() {}
    
    func map(_ response: DataResponse<[RemoteUserDetailProfile], AFError>) throws -> [UserDetailProfile] {
        currentHeaders = response.response?.allHeaderFields
        
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
                    
                ) }
            return detailProfiles
            
        } else if response.response?.statusCode == self.nonModifiedStatusCode {
            throw UserDetailProfileMapper.Error.notModified
            
        } else if let error = response.error {
            if error.isSessionTaskError {
                throw UserDetailProfileMapper.Error.connectivity
                
            } else {
                throw UserDetailProfileMapper.Error.invalidData
                
            }
            
        } else {
            throw UserDetailProfileMapper.Error.unexpected
            
        }
    }
    
    //MARK: - paginated api detail
    private let linkKey = "Link"
    
    func nextURL() -> URL? {
        guard let nextLink = (currentHeaders?[linkKey] as? String)?.split(separator: ",").filter({ $0.contains("next") }).first else {
            return nil
        }
        
        guard let range = nextLink.range(of: "(?<=\\<).+?(?=\\>)", options: .regularExpression) else {
            return nil
        }
        
        guard let url = URL(string: String(nextLink[range])) else {
            return nil
        }
        
        return url
    }
}
