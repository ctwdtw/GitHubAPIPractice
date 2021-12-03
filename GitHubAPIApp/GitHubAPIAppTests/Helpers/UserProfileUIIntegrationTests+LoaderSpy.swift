//
//  UserProfileUIIntegrationTests+LoaderSpy.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/23.
//

import Foundation
import XCTest
import GitHubAPI
import GitHubAPIApp

extension UserProfileUIIntegrationTests {
    class LoaderSpy: UserProfileLoader, ImageDataLoader {
        var loadProfileCompletes: [UserProfileLoader.Complete] = []
        
        var loadCount: Int {
            loadProfileCompletes.count
        }
        
        func load(complete: @escaping UserProfileLoader.Complete) {
            loadProfileCompletes.append(complete)
        }
        
        func complete(with items: [UserProfile], hasMore: Bool = false, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
            if let complete = loadProfileCompletes[safe: index] {
                
                var loadMore: PaginatedUserProfile.LoadMoreAction!
                if hasMore {
                    loadMore = { [weak self] loadMoreComplete in
                        self?.loadMoreCompletes.append(loadMoreComplete)
                    }
                }
                
                let resource = UserProfileLoader.Resource.init(
                    userProfiles: items,
                    loadMore: loadMore)
                complete(.success(resource))
                
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
                
            }
        }
        
        func complete(with error: Error, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
            if let complete = loadProfileCompletes[safe: index] {
                complete(.failure(error))
                
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
                
            }
        }
        
        
        //MARK: - load more
        var loadMoreCount: Int {
            loadMoreCompletes.count
        }
        
        private var loadMoreCompletes: [PaginatedUserProfile.Complete] = []
        
        func completeLoadMore(with items: [UserProfile] = [], hasMore: Bool, at idx: Int, file: StaticString = #filePath, line: UInt = #line) {
            guard let loadMoreComplete = loadMoreCompletes[safe: idx] else {
                XCTFail("load more completions index out of range", file: file, line: line)
                return
            }
            
            var loadMore: PaginatedUserProfile.LoadMoreAction!
            if hasMore {
                loadMore = { [weak self] loadMoreComplete in
                    self?.loadMoreCompletes.append(loadMoreComplete)
                }
            }
            
            loadMoreComplete(.success(PaginatedUserProfile(userProfiles: items, loadMore: loadMore)))
        }
        
        func completeLoadMore(with error: Error, at idx: Int, file: StaticString = #filePath, line: UInt = #line) {
            guard let loadMoreComplete = loadMoreCompletes[safe: idx] else {
                XCTFail("load more completions index out of range", file: file, line: line)
                return
            }
            
            loadMoreComplete(.failure(error))
        }
        
        //MARK: - image loading
        private(set) var avatarUrls: [URL] = []
        
        private(set) var cancelledAvatarUrls: [URL] = []
        
        private(set) var imageLoadingCompletions = [ImageDataLoader.Complete]()
        
        func load(url: URL, complete: @escaping ImageDataLoader.Complete) -> ImageDataTask {
            avatarUrls.append(url)
            imageLoadingCompletions.append(complete)
            return SpyImageDataTask(cancelCallback: { [weak self] in
                self?.cancelledAvatarUrls.append(url)
            })
        }
        
        func completeImageLoading(with result: ImageDataLoader.Result, at idx: Int) {
            if let completion = imageLoadingCompletions[safe: idx] {
                completion(result)
            }
        }
    }
    
    class SpyImageDataTask: ImageDataTask {
        private var cancelCallback: (() -> Void)?
        init(cancelCallback: @escaping ()-> Void) {
            self.cancelCallback = cancelCallback
        }
        func cancel() {
            cancelCallback?()
            cancelCallback = nil
        }
    }
    
}
