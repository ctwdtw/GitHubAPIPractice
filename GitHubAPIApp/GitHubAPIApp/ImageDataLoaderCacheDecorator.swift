//
//  ImageDataLoaderCacheDecorator.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/22.
//

import Foundation
import GitHubAPI

public class ImageDataLoaderCacheDecorator: ImageDataLoader {
    private let decoratee: ImageDataLoader
    
    public private(set) var inMemoryCache: [URL: Data] = [:]
    
    public init(decoratee: ImageDataLoader, cache: [URL: Data] = [:]) {
        self.decoratee = decoratee
        self.inMemoryCache = cache
    }
    
    class DecorateeImageDataTaskWrapper: ImageDataTask {
        private var complete: ImageDataLoader.Complete?
        
        var task: ImageDataTask?
        
        init(complete: @escaping ImageDataLoader.Complete) {
            self.complete = complete
        }
        
        func complete(with result: ImageDataLoader.Result) {
            complete?(result)
            complete = nil
        }
        
        func cancel() {
            task?.cancel()
            task = nil
            complete = nil
        }
    }
    
    public func load(url: URL, complete: @escaping Complete) -> ImageDataTask {
        if let data = inMemoryCache[url] {
            let task = DecorateeImageDataTaskWrapper(complete: complete)
            task.complete(with: .success(data))
            return task
        }
        
        let wrappedTask = DecorateeImageDataTaskWrapper(complete: complete)
        
        wrappedTask.task = decoratee.load(url: url) { [weak self] result in
            guard let self = self else { return }
            
            do {
                let  data = try result.get()
                self.inMemoryCache[url] = data
                wrappedTask.complete(with: .success(data))
                
            } catch {
                wrappedTask.complete(with: .failure(error))
                
            }
        }
    
        return wrappedTask
    }
}
