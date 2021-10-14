//
//  UserProfileMapper.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/15.
//

import Foundation
import Alamofire

public class UserProfileMapper {
    var validStatusCodes: [Int] {
        return [200]
    }
    
    var nonModifiedStatusCode: Int {
        304
    }
    
    private var currentResponse: DataResponse<[RemoteUserProfileLoader.RemoteUserProfile], AFError>?
    
    var currentHeaders: HTTPHeaders? {
        currentResponse?.response?.headers
    }
    
    public init() {}
    
    func map(_ response: DataResponse<[RemoteUserProfileLoader.RemoteUserProfile], AFError>) -> LoadUserProfileResult {
        currentResponse = response
        if let remoteProfiles = response.value {
            let profiles = remoteProfiles.map { UserProfile(id: $0.id, login: $0.login, avatarUrl: $0.avatar_url, siteAdmin: $0.site_admin) }
            return .success(profiles)
            
        } else if response.response?.statusCode == self.nonModifiedStatusCode {
            return .failure(.notModified)
            
        } else if let error = response.error {
            if error.isSessionTaskError {
                return .failure(.connectivity)
                
            } else {
                return .failure(.invalidData)
                
            }
            
        } else {
            return .failure(.unexpected)
            
        }
    }
}
