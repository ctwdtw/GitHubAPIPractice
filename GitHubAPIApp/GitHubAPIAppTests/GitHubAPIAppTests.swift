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
        loader.load { _ in
            self.refreshControl?.endRefreshing()
        }
    }
}

class UserProfileViewControllerTests: XCTestCase {
    func test__init__does_not_load_userProfile() {
        let (_, loaderSpy) = makeSUT()
    
        XCTAssertEqual(loaderSpy.loadCount, 0)
    }
    
    func test__loadUserProfile__onViewDidLoad() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)
    }
        
    func test__loadAgain__onUserTriggerLoadAction() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)

        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertEqual(sut.numberOfRenderedSections, 1)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, 0)
        
        sut.triggerLoadAction()
        
        XCTAssertEqual(loaderSpy.loadCount, 2)
    }
    
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
    }
    
    func test__displayEmptyUserProfile__onEmptyProfiles() {
        let (sut, loaderSpy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1)

        loaderSpy.complete(with: .success([]), at: 0)

        XCTAssertEqual(sut.numberOfRenderedSections, 1)
        XCTAssertEqual(sut.numberOfRenderedUserProfile, 0)
    }

    
    private func makeSUT() -> (UserProfileViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserProfileViewController(loader: loaderSpy)
        return (sut, loaderSpy)
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
