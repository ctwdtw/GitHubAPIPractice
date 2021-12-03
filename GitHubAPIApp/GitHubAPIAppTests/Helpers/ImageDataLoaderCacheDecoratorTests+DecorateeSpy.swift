//
//  ImageDataLoaderCacheDecoratorTests+DecorateeSpy.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/24.
//

import Foundation
import XCTest
import GitHubAPI

extension ImageDataLoaderCacheDecoratorTests {
    class DecorateeSpy: ImageDataLoader {
        private class DecorateeImageTask: ImageDataTask {
            private var cancelCallback: (() -> Void)?
            
            init(cancelCallback: @escaping () -> Void) {
                self.cancelCallback = cancelCallback
            }
            
            func cancel() {
                cancelCallback?()
                cancelCallback = nil
            }
        }

        private var messages: [(url: URL, completion: Complete)] = []
        
        var requestURLs: [URL] {
            messages.map { $0.url }
        }
        
        var completions: [Complete] {
            messages.map { $0.completion }
        }
        
        private(set) var cancelURLs: [URL] = []
        
        func load(url: URL, complete: @escaping Complete) -> ImageDataTask {
            messages.append((url, complete))
            return DecorateeImageTask(cancelCallback: { [weak self] in
                self?.cancelURLs.append(url)
            })
        }
        
        func complete(with data: Data, at idx: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
            guard let completion = completions[safe: idx] else {
                XCTFail("completion index out of range", file: file, line: line)
                return
            }
            
            completion(.success(data))
        }
        
        func complete(with error: Error, at idx: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
            guard let completion = completions[safe: idx] else {
                XCTFail("completion index out of range", file: file, line: line)
                return
            }
            
            completion(.failure(error))
        }
    }
}
