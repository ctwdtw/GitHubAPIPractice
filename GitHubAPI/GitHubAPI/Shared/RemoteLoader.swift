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
    public typealias Result = Swift.Result<Resource, Swift.Error>
    
    public typealias Complete = (Result) -> Void
    
    let url: URL
    
    let session: Session
    
    let mapping: (DataResponse<RemoteResource, AFError>) throws -> Resource
    
    let validStatusCodes: [Int]
    
    public enum Error: Swift.Error {
        case loaderHasDeallocated
    }
    
    public init<Mapping: Mapper>(url: URL, session: Session = .default, mapper: Mapping)
    where Mapping.RemoteResource == RemoteResource, Mapping.Resource == Resource {
        self.url = url
        self.session = session
        self.validStatusCodes = mapper.validStatusCodes
        self.mapping = mapper.map(_:)
    }
    
    public func load(complete: @escaping Complete) {
        session.request(url).validate(statusCode: validStatusCodes).responseDecodable(of: RemoteResource.self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure(Error.loaderHasDeallocated))
                return
            }
            
            do {
                let resources = try self.mapping(response)
                complete(.success(resources))
                
            } catch {
                complete(.failure(error))
                
            }

        }
    }
}
