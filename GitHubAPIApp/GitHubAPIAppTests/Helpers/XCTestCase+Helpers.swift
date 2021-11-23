//
//  Helpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/23.
//

import Foundation
import XCTest

public extension XCTestCase {
    func XCTExpected<T: Equatable>(_ expected: T, received: T, message: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expected, received, message, file: file,line: line)
    }
    
    func XCTReceived<T: Equatable>(_ received: T, expected: T, message: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(received, expected, file: file,line: line)
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
    
    func anyNSError() -> Error {
        NSError(domain: "any-ns-error", code: -1, userInfo: nil)
    }
}
