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
    
    func test__loadImage__whenUserProfileViewIsVisible() {
        let url0 = URL(string: "https://a-avatar-url.com")!
        let item0 = makeUserProfile(avatarUrl: url0)
        
        let url1 = URL(string: "https://another-avatar-url.com")!
        let item1 = makeUserProfile(avatarUrl: url1)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: .success([item0, item1]), at: 0)
        
        XCTAssertEqual(loaderSpy.avatarUrls, [])
        
        sut.simulateUserProfileViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [url0])
        
        sut.simulateUserProfileViewIsVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [url0, url1])
    }
    
    private func makeUserProfile(id: Int = { Int.random(in: 0...999)  }(), login: String = "a-user-login-account", avatarUrl: URL = URL(string: "https://any-avatar-url")!, siteAdmin: Bool = false) -> UserProfile {
        return UserProfile(id: id, login: login, avatarUrl: avatarUrl, siteAdmin: siteAdmin)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (UserProfileViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserProfileViewController(loader: loaderSpy, imageLoader: loaderSpy)
        trackForMemoryLeak(loaderSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loaderSpy)
    }
    
    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
    
    private class LoaderSpy: UserProfileLoader, ImageDataLoader {
        var loadProfileCompletes: [UserProfileLoader.Complete] = []
        
        var loadCount: Int {
            loadProfileCompletes.count
        }
        
        func load(complete: @escaping UserProfileLoader.Complete) {
            loadProfileCompletes.append(complete)
        }
        
        func complete(with result: UserProfileLoader.Result, at index: Int, file: StaticString = #file, line: UInt = #line) {
            if let complete = loadProfileCompletes[safe: index] {
                complete(result)
            
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
            
            }
        }
        
        private(set) var avatarUrls: [URL] = []
        func load(url: URL, complete: @escaping ImageDataLoader.Complete) -> ImageDataTask {
            avatarUrls.append(url)
            return SpyImageDataTask()
        }
    }
    
    private class SpyImageDataTask: ImageDataTask {
        func cancel() {
            
        }
    }

    private func assertThat(_ sut: UserProfileViewController,
                            rendering userProfiles: [UserProfile],
                            file: StaticString = #filePath,
                            line: UInt = #line
    ) {
        XCTAssertEqual(sut.numberOfRenderedSections, 1, "receive \(sut.numberOfRenderedSections) sections, but expect \(1)", file: file, line: line)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, userProfiles.count, "receive \(sut.numberOfRenderedUserProfile) user profiles, but expect \(userProfiles.count)", file: file, line: line)
        
        userProfiles.enumerated().forEach { (idx, userProfile) in
            assertThat(sut, hasViewConfiguredFor: userProfile, at: idx)
        }
    }
    
    private func assertThat(_ sut: UserProfileViewController, hasViewConfiguredFor userProfile: UserProfile, at idx: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.userProfileView(at: idx)
        guard let cell =  view as? UserProfileCell else {
            return XCTFail("receive \(String(describing: view)) instead, but expect it to be \(UserProfileCell.self) instance at index: \(idx), but got", file: file, line: line)
        }
        
        XCTAssertEqual(cell.loginAccountText, userProfile.login, "receive login account text \(String(describing: cell.loginAccountText)), but expect it to be \(userProfile.login) instead.", file: file, line: line)
        
        XCTAssertEqual(cell.showSiteAdminLabel, userProfile.siteAdmin, "receive show site admin label to be \(cell.showSiteAdminLabel), but expect it to be \(userProfile.siteAdmin) ", file: file, line: line)
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
    
    func userProfileView(at row: Int) -> UITableViewCell? {
        return tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: userProfileSection))
    }
    
    func simulateUserProfileViewIsVisible(at idx: Int) {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        let cell = userProfileView(at: idx)!
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
}

private extension UserProfileCell {
    var loginAccountText: String? {
        return loginLabel.text
    }
    
    var showSiteAdminLabel: Bool {
        return !siteAdminLabel.isHidden
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension XCTestCase {
    func XCTExpected<T: Equatable>(_ expected: T, received: T, message: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expected, received, message, file: file,line: line)
    }
    
    func XCTReceived<T: Equatable>(_ received: T, expected: T, message: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(received, expected, file: file,line: line)
    }
}
