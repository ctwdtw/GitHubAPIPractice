//
//  RemoteUserDetailProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/18.
//

import Foundation
import Alamofire

public class RemoteUserDetailProfileLoader {
    public typealias Result = Swift.Result<[UserDetailProfile], Swift.Error>
    public typealias Complete = (Result) -> Void
    
    let url: URL
    
    let session: Session
    
    let mapper: UserDetailProfileMapper
    
    public enum Error: Swift.Error {
        case loaderHasDeallocated
    }
    
    public init(url: URL, session: Session = .default, mapper: UserDetailProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    public func load(complete: @escaping Complete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [UserDetailProfileMapper.RemoteUserDetailProfile].self) {  [weak self] response in
            
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
