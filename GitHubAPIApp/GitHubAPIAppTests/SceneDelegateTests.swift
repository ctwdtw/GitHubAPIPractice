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
        let top = (root as? UINavigationController)?.topViewController
        
        XCTAssertTrue(sut.window?.rootViewController is UINavigationController, "Expected `UINavigationController` as root, got \(String(describing: root)) instead")
        
        XCTAssertTrue(top is ListViewController, "Expect `ListViewController` as top view controller but got \(String(describing: top)) instead")
    }
    
    
}
