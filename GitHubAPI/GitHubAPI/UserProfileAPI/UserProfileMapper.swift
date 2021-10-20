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
        case notModified
        case unexpected
    }
    
    struct RemoteUserProfile: Codable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
    }
    
    var validStatusCodes: [Int] {
        return [200]
    }
    
    private var nonModifiedStatusCode: Int {
        304
    }
    
    private(set) var currentHeaders: [AnyHashable: Any]?
    
    public init() {}
        
    func map(_ response: DataResponse<[RemoteUserProfile], AFError>) throws -> [UserProfile] {
        currentHeaders = response.response?.allHeaderFields
        
        if let remoteProfiles = response.value {
            let profiles = remoteProfiles.map {
                UserProfile(
                    id: $0.id,
                    login: $0.login,
                    avatarUrl: $0.avatar_url,
                    siteAdmin: $0.site_admin
                )}
            
            return profiles
            
        } else if response.response?.statusCode == self.nonModifiedStatusCode {
            throw Error.notModified
            
        } else if let afError = response.error {
            throw afError
            
        } else {
            throw Error.unexpected
            
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
