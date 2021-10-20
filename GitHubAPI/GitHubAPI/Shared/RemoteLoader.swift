//
//  RemoteLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/19.
//

import Foundation
import Alamofire

public protocol Mapper {
    associatedtype RemoteResource: Decodable
    associatedtype Resource
    var validStatusCodes: [Int] { get }
    func map(_ response: DataResponse<RemoteResource, AFError>) throws -> Resource
}

public class RemoteLoader<RemoteResource: Decodable, Resource> {
    public typealias ResourceResult = Swift.Result<Resource, Swift.Error>
    public typealias ResourceComplete = (ResourceResult) -> Void
    
    let url: URL
    
    let session: Session
    
    let mapping: (DataResponse<RemoteResource, AFError>) throws -> Resource
    
    let validStatusCodes: [Int]
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case loaderHasDeallocated
    }
    
    public init<Mapping: Mapper>(url: URL, session: Session = .default, mapper: Mapping)
    where Mapping.RemoteResource == RemoteResource, Mapping.Resource == Resource {
        self.url = url
        self.session = session
        self.validStatusCodes = mapper.validStatusCodes
        self.mapping = mapper.map(_:)
    }
    
    public func load(complete: @escaping ResourceComplete) {
        session.request(url).validate(statusCode: validStatusCodes).responseDecodable(of: RemoteResource.self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure(Error.loaderHasDeallocated))
                return
            }
            
            do {
                let profiles = try self.mapping(response)
                complete(.success(profiles))
                
            } catch {
                complete(.failure(error))
                
            }

        }
    }
}
