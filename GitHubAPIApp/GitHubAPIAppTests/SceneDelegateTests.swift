//
//  SceneDelegateTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/14.
//

import XCTest
@testable import GitHubAPIApp
@testable import GitHubAPI


class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_configureRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        XCTAssertTrue(sut.window?.rootViewController is UINavigationController, "Expected `UINavigationController` as root, got \(String(describing: root)) instead")
        
        let top = (root as? UINavigationController)?.topViewController
        XCTAssertTrue(top is ListViewController, "Expect `ListViewController` as top view controller but got \(String(describing: top)) instead")
    }
    
    func test_showDetail_pushUserDeailListViewController() {
        let item = makeUserProfile()
        let (sut,  navcSpy) = makeSUT()
        
        sut.configureWindow()
        XCTAssertEqual(navcSpy.pushCount, 0, "expect navigation controller not push on scene delegate will connect to session")
        
        sut.showUserDetail(for: item)
        XCTAssertEqual(navcSpy.pushCount, 1, "expect push view controller once")
        
        XCTAssertTrue(navcSpy.topViewControllerIsUserDetail, "expect push user detail list view controller")
    }
    
    private class NavigationControllerSpy: UINavigationController {
        private(set) var pushedViewControllers: [UIViewController] = []
        
        var pushCount: Int {
            return pushedViewControllers.count
        }
        
        var topViewControllerIsUserDetail: Bool {
            let top = pushedViewControllers.last as? ListViewController
            return top?.prototypeCellInstances.map {
                String(describing: type(of: $0))
            }.contains(String(describing: type(of: AvatarCell()))) ?? false
        }
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            pushedViewControllers.append(viewController)
        }
    }
    
    private func makeSUT() -> (SceneDelegate, NavigationControllerSpy) {
        let navcSpy = NavigationControllerSpy()
        let sut = SceneDelegate(navc: navcSpy)
        return (sut, navcSpy)
    }
    
    private func makeUserProfile() -> UserProfile {
        UserProfile(id: 0, login: "a-login-text", avatarUrl: anyURL(), siteAdmin: false)
    }
}

extension SceneDelegate {
    convenience init(navc: UINavigationController) {
        self.init()
        self.navigationController = navc
    }
}
