//
//  ImageDataLoaderCacheDecoratorTests+Assertions.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/24.
//

import Foundation
import XCTest
import GitHubAPI
import GitHubAPIApp

extension ImageDataLoaderCacheDecoratorTests {
    func assert(_ sut: ImageDataLoaderCacheDecorator, loadWith url: URL = anyURL(), receive expectedResult: ImageDataLoader.Result, when action: () -> Void = {}, file: StaticString = #filePath, line: UInt = #line) {
        
        let loadAction = { complete in sut.load(url: url, complete: complete) }
        
        let exp = expectation(description: "wait for complete")
        var receivedResult: ImageDataLoader.Result?
        _ = loadAction { result in
            exp.fulfill()
            receivedResult = result
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
        case let (.success(receivedImageData), .success(expectedImageData)):
            XCTAssertEqual(receivedImageData, expectedImageData, "image data should match", file: file, line: line)
        
        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertReceivedError(receivedError, equalsTo: expectedError, "received error: \(receivedError), but expect \(expectedError)", file: file, line: line)
        
        default:
            XCTFail("receive \(String(describing: receivedResult)), but expect \(expectedResult)")
        }
    }
}
