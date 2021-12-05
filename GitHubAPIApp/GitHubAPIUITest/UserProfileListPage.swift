//
//  UserProfileListPage.swift
//  GitHubAPIUITest
//
//  Created by Paul Lee on 2021/12/2.
//

import Foundation
import XCTest

class UserProfileListPage: Page {
    private(set) var app: XCUIApplication
    
    var firstProfileCell: XCUIElement {
        app.tables.cells.matching(identifier: "user-profile-cell-0").firstMatch
    }
    
    func profileCell(at idx: Int) -> XCUIElement {
        app.tables.cells.matching(identifier: "user-profile-cell-\(idx)").firstMatch
    }
    
    var listView: XCUIElement {
        app.tables.firstMatch
    }
    
    required init(app: XCUIApplication) {
        self.app = app
        app.launch()
    }
    
    func tapProfileCell(at idx: Int) -> UserDetailPage {
        profileCell(at: idx).tap()
        return UserDetailPage(app: app)
    }
    
    func scrollToProfileCell(at idx: Int, timeoutInterval: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
        listView.scroll(to: profileCell(at: idx), timeoutInterval: timeoutInterval, file: file, line: line)
    }
}
