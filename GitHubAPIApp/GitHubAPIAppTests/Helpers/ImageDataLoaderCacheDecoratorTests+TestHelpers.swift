//
//  ImageDataLoaderCacheDecoratorTests+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/24.
//

import Foundation
import GitHubAPIApp
extension ImageDataLoaderCacheDecorator {
    func cachedImageData(for url: URL) -> Data? {
        inMemoryCache[url]
    }
    
    func cachedImageDatas() -> [Data] {
        inMemoryCache.map { $0.value }
    }
}
