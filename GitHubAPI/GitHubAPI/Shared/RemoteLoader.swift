//
//  RemoteLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/19.
//

import Foundation
import Alamofire

public class RemoteLoader {
    public typealias LoadUserProfileResult = Result<[UserProfile], Swift.Error>
    public typealias LoadUserProfileComplete = (LoadUserProfileResult) -> Void
    
    let url: URL
    
    let session: Session
    
    let mapper: UserProfileMapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case loaderHasDeallocated
    }
    
    public init(url: URL, session: Session = .default, mapper: UserProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    public func load(complete: @escaping LoadUserProfileComplete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [UserProfileMapper.RemoteUserProfile].self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure(RemoteUserProfileLoader.Error.loaderHasDeallocated))
                return
            }
            
            do {
                let profiles = try self.mapper.map(response)
                complete(.success(profiles))
                
            } catch let e as AFError {
                let mappedError = self.mapError(e)
                complete(.failure(mappedError))
                
            } catch {
                complete(.failure(error))
                
            }

        }
    }
    
    private func mapError(_ error: AFError) -> Error  {
        if error.isSessionTaskError {
            return Error.connectivity
            
        } else {
            return Error.invalidData
            
        }
    }
    
}
