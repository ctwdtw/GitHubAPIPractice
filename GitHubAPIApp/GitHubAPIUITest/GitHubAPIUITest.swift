//
//  GitHubAPIUITest.swift
//  GitHubAPIUITest
//
//  Created by Paul Lee on 2021/11/30.
//

import XCTest
import GitHubAPIApp

class GitHubAPIUITest: XCTestCase {
    func test_launch_loadUserProfile() {
        let app = XCUIApplication()
        app.launch()
        let profileCell = app.tables.cells.matching(identifier: "user-profile-cell-0").firstMatch
        
        sleep(1)
        XCTAssertTrue(profileCell.exists)
    }
    
    func test_swipeUp_loadMoreThanInitial20Cells() {
        let app = XCUIApplication()
        app.launch()
        let table = app.tables.firstMatch
        let targetCell = table.cells.matching(identifier: "user-profile-cell-40").firstMatch
        
        table.scrollToElement(element: targetCell, timeoutInterval: 60)
    }
    
    func test_tapOnUserProfile_navigateToDetailProfile() {
        let app = XCUIApplication()
        app.launch()
        let profileCell = app.tables.cells.matching(identifier: "user-profile-cell-0").firstMatch
        
        profileCell.tap()
        let avatarCell = app.tables.cells.matching(identifier: "avatar-cell").firstMatch
        
        sleep(1)
        XCTAssertTrue(avatarCell.exists)
    }

}


extension XCUIElement {
    func scrollToElement(element: XCUIElement, timeoutInterval: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
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
