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
    
    func XCTAssertEqualError(_ receivedError: Error?, _ expectedError: Error, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
    }
    
    func XCTAssertEqualError(_ expectedError: Error, _ receivedError: Error?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expectedError as NSError?, receivedError as NSError?, file: file, line: line)
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
    
    func anyNSError() -> Error {
        NSError(domain: "any-ns-error", code: -1, userInfo: nil)
    }
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func randomImageData() -> Data {
        let anyColor = UIColor(
            displayP3Red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: CGFloat.random(in: 0...1)
        )
        return UIImage.image(with: anyColor).pngData()!
    }
    
    func whiteImageData() -> Data {
        return UIImage.image(with: .white).pngData()!
    }
}
