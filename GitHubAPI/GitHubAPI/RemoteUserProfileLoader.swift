//
//  RemoteUserProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
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

public typealias LoadUserProfileResult = Result<[UserProfile], RemoteUserProfileLoader.Error>
public typealias LoadUserProfileComplete = (LoadUserProfileResult) -> Void
public typealias LoadAction = ((@escaping LoadUserProfileComplete) -> Void)

public struct UserProfile: Equatable {
    public let id: Int
    public let login: String
    public let avatarUrl: URL
    public let siteAdmin: Bool
    
    public init(id: Int, login: String, avatarUrl: URL, siteAdmin: Bool) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.siteAdmin = siteAdmin
    }
}

public class RemoteUserProfileLoader {
    struct RemoteUserProfile: Codable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notModified
        case loaderHasDeallocated
        case unexpected
    }
    
    let url: URL
    
    let session: Session
    
    let mapper: UserProfileMapper
    
    public init(url: URL, session: Session = .default, mapper: UserProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    public func load(complete: @escaping LoadUserProfileComplete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [RemoteUserProfile].self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure( .loaderHasDeallocated))
                return
            }
            
            let result = self.mapper.map(response)
            
            complete(result)
        }
    }
}
