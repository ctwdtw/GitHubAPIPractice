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
        case resourceNotFound
    }
    
    private struct RemoteUserDetailProfile: Decodable {
        let id: Int
        let avatar_url: URL
        let name: String?
        let bio: String?
        let login: String
        let site_admin: Bool
        let location: String?
        let blog: URL?
    }
    
    private var validStatusCodes: [Int] {
        return [200]
    }
    
    private var resourceNotFound: Int {
        404
    }
    
    public init() {}
    
    public func map(_ response: DataResponse<Data, AFError>) throws -> [UserDetailProfile] {
        
        do {
            try validateStatusCode(for: response)
            let data = try response.result.get()
            let remoteProfiles = try decode(of: [RemoteUserDetailProfile].self, data: data)
            return remoteProfiles.map {
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
            
        } catch {
            throw error
            
        }
        
    }
    
    private func validateStatusCode(for response: DataResponse<Data, AFError>) throws {
        guard let statusCode = response.response?.statusCode else {
            throw Error.connectivity
        }
        
        guard statusCode != resourceNotFound else {
            throw Error.resourceNotFound
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
