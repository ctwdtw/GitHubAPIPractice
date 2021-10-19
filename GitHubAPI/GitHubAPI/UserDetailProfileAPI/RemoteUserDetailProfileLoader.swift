//
//  RemoteUserDetailProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/18.
//

import Foundation
import Alamofire

public class RemoteUserDetailProfileLoader {
    public typealias LoadUserDetailProfileResult = Result<[UserDetailProfile], Swift.Error>
    public typealias LoadUserDetailProfileComplete = (LoadUserDetailProfileResult) -> Void
    
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
    
    let url: URL
    
    let session: Session
    
    let mapper: UserDetailProfileMapper
    
    public init(url: URL, session: Session = .default, mapper: UserDetailProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    public func load(complete: @escaping LoadUserDetailProfileComplete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [RemoteUserDetailProfile].self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure(UserDetailProfileMapper.Error.loaderHasDeallocated))
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
