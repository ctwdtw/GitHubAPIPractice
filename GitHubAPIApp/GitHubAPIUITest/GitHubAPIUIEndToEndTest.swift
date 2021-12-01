//
//  GitHubAPIUIEndToEndTest.swift
//  GitHubAPIUIEndToEndTest
//
//  Created by Paul Lee on 2021/11/30.
//

import XCTest
import GitHubAPIApp

class GitHubAPIUIEndToEndTest: XCTestCase {
    func test_launch_loadUserProfile() {
        let app = XCUIApplication()
        UserProfileListPage(app: app)
            .profileCell(at: 0)
            .wait(seconds: 1)
            .assertExist()
    }
    
    func test_swipeUp_loadMoreThanInitial20Cells() {
        let app = XCUIApplication()
        UserProfileListPage(app: app)
            .scrollToProfileCell(at: 0, timeoutInterval: 60)
    }
    
    func test_tapOnUserProfile_navigateToDetailProfile() {
        let app = XCUIApplication()
        UserProfileListPage(app: app)
            .tapProfileCell(at: 0)
            .wait(seconds: 1)
            .avatarCell
            .assertExist()
    }
    
}
