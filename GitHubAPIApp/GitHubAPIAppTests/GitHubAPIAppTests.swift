//
//  GitHubAPIAppTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPIApp
import GitHubAPI

public protocol UserProfileLoader {
    typealias Result = Swift.Result<[UserProfile], Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}

public class UserProfileViewController: UITableViewController {
    private var loader: UserProfileLoader!
    
    public convenience init(loader: UserProfileLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

/*
    [] Load feed automatically when view is presented
    [] Allow customer to manually reload feed (pull to refresh)
    [] Show a loading indicator while loading feed
       -> 包含 view is presented 和 user pull to refresh 兩種情況下的 loading,
          都要考慮 loading indicator
    [] Render all loaded feed items (location, image, description)
    [] Image loading experience
        [] Load when image view is visible (on screen)
        [] Cancel when image view is out of screen
        [] Show a loading indicator while loading image (shimmer)
        [] Option to retry on image download error
        [] Preload when image view is near visible
*/
 
class UserProfileViewControllerTests: XCTestCase {
    // [v] Load feed automatically when view is presented
    func test__doesNotLoadUserProfile__onInit() {
        let (_, loaderSpy) = makeSUT()
    
        XCTAssertEqual(loaderSpy.loadCount, 0)
    }
    
    // [v] Load feed automatically when view is presented
    func test__loadUserProfile__onViewIsPresented() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)
    }
    
    // [v] Allow customer to manually reload feed (pull to refresh)
    // 把原本很雜的測試, 變得單純只測呼叫 loader 的次數, 注意
    // XCTAssertEqual(loaderSpy.loadCount, 2) 和
    // XCTAssertEqual(loaderSpy.loadCount, 3)
    // 隱含了 sut.loadViewIfNeeded() 呼叫 loader 1 次的知識,
    // 這樣的隱含關係, 叫做 hidden temporal coupling
    func test__loadUserProfile__onUserTriggerLoadAction() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.triggerLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 2)
        
        sut.triggerLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 3)
    }
    
    // [v] Show a loading indicator while loading feed
    func test__showLoadingIndicator__onViewIsPresented() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    // [v] Show a loading indicator while loading feed
    func test__hideLoadingIndicator__onViewIsPresented_loaderComplete() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    // [v] Show a loading indicator while loading feed
    func test__showLoadingIndicator__onUserTriggerLoadAction() {
        let (sut, _) = makeSUT()
        
        sut.triggerLoadAction()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    // [v] Show a loading indicator while loading feed
    func test__hideLoadingIndicator__onUserTriggerLoadAction_loaderComplete() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.triggerLoadAction()
        loaderSpy.complete(with: .success([]), at: 1)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    /* 原本很雜的測試
    func test__loadAgain__onUserTriggerLoadAction_immature() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)

        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertEqual(sut.numberOfRenderedSections, 1)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, 0)
        
        sut.triggerLoadAction()
        
        XCTAssertEqual(loaderSpy.loadCount, 2)
    }
    */
    
    /* 有時間順序的 test case, 先留著不刪
    func test__renderLoadingIndicator__whileLoading() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)

        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertEqual(sut.numberOfRenderedSections, 1)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, 0)
        
        sut.triggerLoadAction()
        
        XCTAssertEqual(loaderSpy.loadCount, 2)
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loaderSpy.complete(with: .success([]), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }*/
    
    /* 和前兩個 UI/UX checkbox 無關, 先 comment out
    func test__displayEmptyUserProfile__onEmptyProfiles() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)

        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertEqual(sut.numberOfRenderedSections, 1)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, 0)
    }
     */
    
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
        
        func complete(with result: UserProfileLoader.Result, at index: Int) {
            completes[index](result)
        }
    }
}

private extension UserProfileViewController {
    func triggerLoadAction() {
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
