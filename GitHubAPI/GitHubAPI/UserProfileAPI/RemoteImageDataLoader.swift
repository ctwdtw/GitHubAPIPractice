//
//  RemoteImageDataLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/26.
//

import Foundation
import Alamofire

public protocol ImageDataTask {
    func cancel()
}

public class RemoteImageDataLoader {
    class RemoteImageDataTask: ImageDataTask {
        var request: DataRequest?
        private(set) var completion: Complete?
        
        init(complete: @escaping Complete) {
            self.completion = complete
        }
        
        func cancel() {
            request?.cancel()
            completion = nil
        }
        
        func complete(with result: Result) {
            completion?(result)
        }
        
    }
    
    public typealias Result = Swift.Result<Data, Error>
    
    public typealias Complete = (Result) -> Void
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let session: Session
    
    var requestCompleteObserver: (() -> Void)?
    
    public init(session: Session) {
        self.session = session
    }
    
    @discardableResult
    public func load(url: URL, complete: @escaping Complete) -> ImageDataTask {
        let task = RemoteImageDataTask(complete: complete)
        
        let request = session.request(url).responseData { [weak self, requestCompleteObserver] response in
            
            requestCompleteObserver?()
            
            guard self != nil else {
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                task.complete(with: .failure(.connectivity))
                return
            }
            
            guard statusCode == 200 else {
                task.complete(with: .failure(.invalidData))
                return
            }
            
            guard let data = response.data else {
                task.complete(with: .failure(.invalidData))
                return
            }
            
            task.complete(with: .success(data))
        }
        
        task.request = request
        
        return task
        
    }
}
