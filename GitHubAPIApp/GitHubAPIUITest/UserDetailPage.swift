//
//  UserDetailPage.swift
//  GitHubAPIUITest
//
//  Created by Paul Lee on 2021/12/2.
//

import Foundation
import XCTest

class UserDetailPage: Page {
    private(set) var app: XCUIApplication
    
    required init(app: XCUIApplication) {
        self.app = app
    }
    
    var avatarCell: XCUIElement {
        app.tables.cells.matching(identifier: "avatar-cell").firstMatch
    }
    
}
