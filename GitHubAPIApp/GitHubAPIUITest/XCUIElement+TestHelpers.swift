//
//  XCUIElement+TestHelpers.swift
//  GitHubAPIUITest
//
//  Created by Paul Lee on 2021/12/2.
//

import Foundation
import XCTest

extension XCUIElement {
    func wait(seconds: UInt32) -> XCUIElement {
        sleep(seconds)
        return self
    }
    
    func assertExist(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(self.exists, file: file, line: line)
    }
}

extension XCUIElement {
    func scroll(to element: XCUIElement, timeoutInterval: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
        var elapsedTime: TimeInterval = 0
        let timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { timer in
            elapsedTime += 1
            if elapsedTime > timeoutInterval {
                XCTFail("timeout: \(timeoutInterval)", file: file, line: line)
            }
        }
        
        timer.fire()
        
        while element.visible() == false && elapsedTime < timeoutInterval {
            swipeUp()
        }
    }
 
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else {
            return false
        }
        
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}
