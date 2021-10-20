//
//  RemoteUserProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
import Alamofire

public class RemoteUserProfileLoader {
    public typealias Result = Swift.Result<[UserProfile], Swift.Error>
    public typealias Complete = (Result) -> Void
    
    let url: URL
    
    let session: Session
    
    let mapper: UserProfileMapper
    
    public enum Error: Swift.Error {
        case loaderHasDeallocated
    }
    
    public init(url: URL, session: Session = .default, mapper: UserProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    public func load(complete: @escaping Complete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [UserProfileMapper.RemoteUserProfile].self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure(Error.loaderHasDeallocated))
                return
            }
            
            do {
                let profiles = try self.mapper.map(response)
                complete(.success(profiles))
                
            } catch {
                complete(.failure(error))
            }

        }
    }
}

extension RemoteUserProfileLoader {
    public func paginated() -> PaginatedUserProfileAdapter {
        PaginatedUserProfileAdapter(adaptee: self, currentProfiles: [])
    }
}
