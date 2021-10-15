//
//  RemoteUserProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
import Alamofire

public typealias LoadUserProfileResult = Result<[UserProfile], UserProfileMapper.Error>
public typealias LoadUserProfileComplete = (LoadUserProfileResult) -> Void
public typealias LoadAction = ((@escaping LoadUserProfileComplete) -> Void)

public class RemoteUserProfileLoader {
    struct RemoteUserProfile: Codable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
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
                complete(.failure(.loaderHasDeallocated))
                return
            }
            
            let result = self.mapper.map(response)
            
            complete(result)
        }
    }
}

extension RemoteUserProfileLoader {
    public func paginated() -> PaginatedUserProfileAdapter {
        PaginatedUserProfileAdapter(adaptee: self, currentProfiles: [])
    }
}
