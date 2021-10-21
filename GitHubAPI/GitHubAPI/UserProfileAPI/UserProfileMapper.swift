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
        case connectivity
        case invalidData
    }
    
    private struct RemoteUserProfile: Decodable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
    }
    
    private var validStatusCodes: [Int] {
        return [200]
    }
    
    private var nonModifiedStatusCode: Int {
        304
    }
    
    public init() {}
    
    public func map(_ response: DataResponse<Data, AFError>) throws -> [UserProfile] {
        
        do {
            try validateStatusCode(for: response)
            let data = try response.result.get()
            let remoteProfiles = try decode(of: [RemoteUserProfile].self, data: data)
            return remoteProfiles.map {
                UserProfile(
                    id: $0.id,
                    login: $0.login,
                    avatarUrl: $0.avatar_url,
                    siteAdmin: $0.site_admin
                )}
            
        } catch {
            throw error
        }
        
    }
    
    private func validateStatusCode(for response: DataResponse<Data, AFError>) throws {
        guard let statusCode = response.response?.statusCode else {
            throw Error.connectivity
        }
        
        guard statusCode != nonModifiedStatusCode else {
            throw Error.notModified
        }
        
        guard validStatusCodes.contains(statusCode) else {
            throw Error.invalidData
        }
        
        return
    }
    
    private func decode<Item: Decodable>(of type: Item.Type, data: Data) throws -> Item {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw Error.invalidData
        }
    }
}
