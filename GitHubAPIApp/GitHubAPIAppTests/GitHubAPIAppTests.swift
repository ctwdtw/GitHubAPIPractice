//
//  GitHubAPIAppTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import GitHubAPIApp
 
class UserProfileViewControllerTests: XCTestCase {
    // [v] Load feed automatically when view is presented
    // [v] Allow customer to manually reload feed (pull to refresh)
    func test__loadUserProfileActions__requestUserProfilesFromLoader() {
        let (sut, loaderSpy) = makeSUT()
        XCTAssertEqual(loaderSpy.loadCount, 0, "expect no loading request before view is loaded")
  
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1, "expect one loading request once view is loaded")
        
        sut.userInitiatedLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 2, "expect another loading request when user initiate a reload")
        
        sut.userInitiatedLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 3, "expect yet another loading request once user initiate another reload")
    }
    
    // [v] Show a loading indicator while loading feed
    func test__loadingIndicator__isVisibleWhileLoadingUserProfile() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator once view is loaded")
        
        loaderSpy.complete(with: .success([]), at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once loading is complete")
        
        sut.userInitiatedLoadAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator again when user initiate a reload")

        loaderSpy.complete(with: .success([]), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once user initiated loading is complete")
    }
    
    func test__renderingUserProfiles__onLoaderComplete() {
        let item0 = UserProfile(id: 0, login: "user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        let item1 = UserProfile(id: 1, login: "another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: true)
        let item2 = UserProfile(id: 2, login: "yet-another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: .success([]), at: 0)
        assertThat(sut, rendering: [])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: .success([item0]), at: 1)
        assertThat(sut, rendering: [item0])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: .success([item1, item2]), at: 2)
        assertThat(sut, rendering: [item1, item2])
    }

    private func assertThat(_ sut: UserProfileViewController,
                            rendering userProfiles: [UserProfile],
                            file: StaticString = #filePath,
                            line: UInt = #line
    ) {
        XCTAssertEqual(sut.numberOfRenderedSections, 1, file: file, line: line)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, userProfiles.count, file: file, line: line)
        
        userProfiles.enumerated().forEach { (idx, item) in
            let indexPath = IndexPath(row: idx, section: sut.userProfileSection)
            let userProfileView = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: indexPath) as? UserProfileCell
            XCTAssertEqual(userProfileView?.loginLabel.text, item.login, file: file, line: line)
            XCTAssertEqual(userProfileView?.siteAdminLabel.isHidden, !item.siteAdmin, file: file,line: line)
        }
        
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (UserProfileViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserProfileViewController(loader: loaderSpy)
        trackForMemoryLead(loaderSpy, file: file, line: line)
        trackForMemoryLead(sut, file: file, line: line)
        return (sut, loaderSpy)
    }
    
    private func trackForMemoryLead(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
    
    private class LoaderSpy: UserProfileLoader {
        var loadCount = 0
        var completes: [UserProfileLoader.Complete] = []
        func load(complete: @escaping Complete) {
            loadCount += 1
            completes.append(complete)
        }
        
        func complete(with result: UserProfileLoader.Result, at index: Int, file: StaticString = #file, line: UInt = #line) {
            if let complete = completes[safe: index] {
                complete(result)
            
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
            
            }
        }
    }
}

private extension UserProfileViewController {
    func userInitiatedLoadAction() {
        refreshControl?.sendActions(for: .valueChanged)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var numberOfRenderedUserProfile: Int {
        return tableView.numberOfRows(inSection: userProfileSection)
    }
    
    var numberOfRenderedSections: Int {
        return tableView.numberOfSections
    }
    
    var userProfileSection: Int {
        return 0
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

