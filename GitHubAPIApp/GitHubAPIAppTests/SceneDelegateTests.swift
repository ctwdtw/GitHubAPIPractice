//
//  SceneDelegateTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/14.
//

import XCTest
@testable import GitHubAPIApp


class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_configureRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        XCTAssertTrue(sut.window?.rootViewController is ListViewController, "Expected `ListViewController` as root, got \(String(describing: root)) instead")
    }
}
