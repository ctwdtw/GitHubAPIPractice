//
//  UserProfileMapper.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/15.
//

import Foundation
import Alamofire

public class UserProfileMapper: Mapper {
    public enum Error: Swift.Error {
        case notModified
        case unexpected
        case connectivity
        case invalidData
    }
    
    public struct RemoteUserProfile: Decodable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
    }
    
    public var validStatusCodes: [Int] {
        return [200]
    }
    
    private var nonModifiedStatusCode: Int {
        304
    }
    
    public init() {}
        
    public func map(_ response: DataResponse<[RemoteUserProfile], AFError>) throws -> [UserProfile] {
        
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
            throw mapAFError(afError)
            
        } else {
            throw Error.unexpected
            
        }
    }
    
    private func mapAFError(_ error: AFError) -> Error  {
        if error.isSessionTaskError {
            return Error.connectivity
            
        } else {
            return Error.invalidData
            
        }
    }
}
