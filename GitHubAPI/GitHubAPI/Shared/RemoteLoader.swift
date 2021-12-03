//
//  RemoteLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/19.
//

import Foundation
import Alamofire

public class RemoteLoader<Resource> {
    public typealias Result = Swift.Result<Resource, Swift.Error>
    
    public typealias Complete = (Result) -> Void
    
    public typealias Mapping = (DataResponse<Data, AFError>) throws -> Resource
    
    private let url: URL
    
    private let session: Session
    
    private let mapping: Mapping
    
    public enum Error: Swift.Error {
        case loaderHasDeallocated
    }
    
    public init(url: URL, session: Session = .default, mapping: @escaping Mapping) {
        self.url = url
        self.session = session
        self.mapping = mapping
    }
    
    public func load(complete: @escaping Complete) {
        session.request(url).responseData {  [weak self] response in
            
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
