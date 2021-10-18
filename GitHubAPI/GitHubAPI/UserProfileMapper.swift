//
//  UserProfileMapper.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/15.
//

import Foundation
import Alamofire

public class UserProfileMapper {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notModified
        case loaderHasDeallocated
        case unexpected
    }
    
    var validStatusCodes: [Int] {
        return [200]
    }
    
    var nonModifiedStatusCode: Int {
        304
    }
    
    private(set) var currentHeaders: [AnyHashable: Any]?
    
    public init() {}
    
    func map(_ response: DataResponse<[RemoteUserProfileLoader.RemoteUserProfile], AFError>) throws -> [UserProfile] {
        currentHeaders = response.response?.allHeaderFields
        
        if let remoteProfiles = response.value {
            let profiles = remoteProfiles.map { UserProfile(id: $0.id, login: $0.login, avatarUrl: $0.avatar_url, siteAdmin: $0.site_admin) }
            return profiles
            
        } else if response.response?.statusCode == self.nonModifiedStatusCode {
            throw UserProfileMapper.Error.notModified
            
        } else if let error = response.error {
            if error.isSessionTaskError {
                throw UserProfileMapper.Error.connectivity
                
            } else {
                throw UserProfileMapper.Error.invalidData
                
            }
            
        } else {
            throw UserProfileMapper.Error.unexpected
            
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
