//
//  ImageDataLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/11/12.
//

import Foundation
public protocol ImageDataTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    typealias Complete = (Result) -> Void
    
    @discardableResult
    func load(url: URL, complete: @escaping Complete) -> ImageDataTask
}
