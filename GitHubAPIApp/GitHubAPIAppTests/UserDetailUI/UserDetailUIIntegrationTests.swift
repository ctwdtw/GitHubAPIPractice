//
//  UserDetailUI.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/25.
//

import XCTest
import GitHubAPI
import GitHubAPIApp

class UserDetailUIIntegrationTests: XCTestCase {
    func test__loadUserDetailActions__requestUserDetailsFromLoader() {
        let (sut, loaderSpy) = makeSUT()
        XCTAssertEqual(loaderSpy.loadCount, 0, "expect no loading request before view is loaded")
  
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCount, 1, "expect one loading request once view is loaded")
        
        sut.userInitiatedLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 2, "expect another loading request when user initiate a reload")
        
        sut.userInitiatedLoadAction()
        XCTAssertEqual(loaderSpy.loadCount, 3, "expect yet another loading request once user initiate another reload")
    }
    
    func test__loadingIndicator__isDisplayedProperlyWhileLoadingUserDetail() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator once view is loaded")
        
        loaderSpy.complete(with: makeUserDetail(), at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once loading is complete with success")
        
        sut.userInitiatedLoadAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator again when user initiate a reload")

        loaderSpy.complete(with: anyNSError(), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once user initiated loading is complete with failure")
    }
    
    func test__renderingUserDetail__onLoaderComplete() {
        let item = makeUserDetail(id: 0, avatarUrl: URL(string: "https://any-url.com")!, login: "user-login-account", siteAdmin: false)
        let backendUpdatedItem = makeUserDetail(id: 0, avatarUrl: URL(string: "https://any-url.com")!, login: "user-login-account", siteAdmin: true)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        assertThat(sut, doesNotYetHaveViewConfiguredFor: item)
        
        loaderSpy.complete(with: item, at: 0)
        assertThat(sut, hasViewConfiguredFor: item)
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: backendUpdatedItem, at: 1)
        assertThat(sut, hasViewConfiguredFor: backendUpdatedItem)
    }
    
    func test__renderUserDetail__onProfileWithoutLocation() {
        let item = detailHasNoLocation()
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        loaderSpy.complete(with: item, at: 0)
        assertThat(sut, hasViewConfigurationExceptLocationFor: item)
    }
    
    private func detailHasNoLocation() -> UserDetail {
        return UserDetail(
            id: 0,
            avatarUrl: anyURL(),
            name: nil,
            biography: "a-biography",
            login: "a-login-text",
            siteAdmin: false,
            location: nil,
            blog: anyURL()
        )
    }
    
    func test__doesNotAlterRenderedUserDetail__onLoaderCompleteWithFailure() {
        let item0 = makeUserDetail()
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: item0, at: 0)
        assertThat(sut, hasViewConfiguredFor: item0)
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: anyNSError(), at: 1)
        assertThat(sut, hasViewConfiguredFor: item0)
    }
    
    func test__requestImage__whenAvatarViewIsVisible() {
        let item0 = makeUserDetail(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: item0, at: 0)
        
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url request until avatar view become visible")
        
        sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request when first user profile view become visible")
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: item0, at: 1)
        sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item0.avatarUrl], "Expect request avatar url when reload and avatar view is visible again")
    }
    
    func test__cancelLoadImage__whenUserDetailViewIsNotVisibleAnymore() {
        let item0 = makeUserDetail(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: item0, at: 0)
        
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [], "Expect no cancelled avatar url request until avatar view is not visible")
        
        sut.simulateAvatarViewIsNotVisible()
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl], "Expect first cancelled avatar url request when first user profile view become not visible anymore")
    }
    
    func test_deinit_cancelsRunningRequest() {
        let item0 = makeUserDetail()
        let loaderSpy = LoaderSpy()
        var sut: ListViewController?
    
        autoreleasepool {
            sut = UserDetailUIComposer.make(userDetailLoaderFactory: { loaderSpy }, avatarImageDataLoader: loaderSpy)
            sut?.loadViewIfNeeded()
            loaderSpy.complete(with: makeUserDetail(), at: 0)
            sut?.simulateAvatarViewIsVisible()
            XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request when first user profile view become visible")
        }
        
        sut = nil
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl])
    }
    
    func test__displayImageLoadingIndicator_whileLoadingImage() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: makeUserDetail(), at: 0)
        
        let avatarView0 = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(avatarView0?.isShowingImageLoadingIndicator, true, "Expect loading indicator for avatar view while loading avatar image")
        
        loaderSpy.completeImageLoading(with: .success(randomImageData()), at: 0)
        XCTAssertEqual(avatarView0?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for avatar view once avatar loading complete successfully")
        
        sut.userInitiatedLoadAction()
        let avatarView1 = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(avatarView1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for avatar view after reloading user detail and avatar view become visible again")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertEqual(avatarView1?.isShowingImageLoadingIndicator, false, "Expect no loading indicator when avatar loading complete with error")
    }
    
    func test__renderLoadedImage__onImageDataLoadingComplete() {
        let image0 = UIImage.image(with: .red).pngData()!
        
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: makeUserDetail(), at: 0)
        
        let avatarView = sut.simulateAvatarViewIsVisible()
        
        XCTAssertNil(avatarView?.renderedImage, "Expect no rendered image on avatar view until image loading is complete successfully")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(avatarView?.renderedImage, image0, "Expect rendered image0 on avatar view when first image loading is complete successfully")
    }
    
    func test__showRetryActionView__onImageDataLoadingCompleteWithError() {
        let image0 = UIImage.image(with: .red).pngData()!
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: makeUserDetail(), at: 0)
        
        let avatarView0 = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(avatarView0?.isShowingRetryView, false, "Expect no retry action view for avatar view while loading image data")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(avatarView0?.isShowingRetryView, false, "Expect no retry action view for avatar view when complete loading first image data successfully")
        
        
        sut.userInitiatedLoadAction()
        let avatarView1 = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(avatarView1?.isShowingRetryView, false, "Expect no retry action view visibility for avatar view when reload user detail and before image loading complete")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertEqual(avatarView1?.isShowingRetryView, true, "Expect retry action view visible for avatar view when image loading complete with error")
    }
    
    func test__showRetryActionView__onLoadedInvalidImageData() {
        let invalidImage = Data()
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: makeUserDetail(), at: 0)
        
        let avatarView = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(avatarView?.isShowingRetryView, false, "Expect no retry action view for first view while loading image data")
        
        loaderSpy.completeImageLoading(with: .success(invalidImage), at: 1)
        XCTAssertEqual(avatarView?.isShowingRetryView, false, "Expect no change of retry action view visibility for first view when complete loading second image with error")
    }
     
    func test__retryImageLoadingAction__onTapRetryActionView() {
        let item0 = makeUserDetail()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: item0, at: 0)
        
        let avatarView = sut.simulateAvatarViewIsVisible()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request for the avatar view")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect no change of avatar url request before user initiate a retry action")
        
        avatarView?.simulateTapRetryView()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item0.avatarUrl], "Expect two avatar url request for the avatar view when user initiate a retry action")
    }
    
    private func makeUserDetail(
        id: Int = { Int.random(in: 0...999)  }(),
        avatarUrl: URL = URL(string: "https://any-avatar-url")!,
        name: String? = nil,
        biography: String? = nil,
        login: String = "a-user-login-account",
        siteAdmin: Bool = false,
        location: String? = nil,
        blog: URL? = nil
    ) -> UserDetail {
        return UserDetail(
            id: id,
            avatarUrl: avatarUrl,
            name: name,
            biography: biography,
            login: login,
            siteAdmin: siteAdmin,
            location: location,
            blog: blog
        )
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserDetailUIComposer.make(userDetailLoaderFactory: { loaderSpy }, avatarImageDataLoader: loaderSpy)
        trackForMemoryLeak(loaderSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loaderSpy)
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        assertThat(sut, renderAvatarViewAt: 0, for: userDetail, file: file, line: line)
        assertThat(sut, renderSiteAdminViewAt: 1, for: userDetail, file: file, line: line)
        assertThat(sut, renderLocationViewAt: 2, for: userDetail, file: file, line: line)
        assertThat(sut, renderBlogViewAt: 3, for: userDetail, file: file, line: line)
    }

    func assertThat(_ sut: ListViewController, hasViewConfigurationExceptLocationFor userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        assertThat(sut, renderAvatarViewAt: 0, for: userDetail, file: file, line: line)
        assertThat(sut, renderSiteAdminViewAt: 1, for: userDetail, file: file, line: line)
        assertThat(sut, renderBlogViewAt: 2, for: userDetail, file: file, line: line)
    }
    
    func assertThat(_ sut: ListViewController, doesNotYetHaveViewConfiguredFor userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedSections, 1, "one empty section", file: file, line: line)
        XCTAssertTrue(sut.tableModel[0].isEmpty, "empty rows", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, renderAvatarViewAt idx: Int = 0, `for` userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        let avatarView = sut.avatarView(at: idx)
        XCTAssertEqual(avatarView?.biography, userDetail.biography, "biography", file: file, line: line)
        XCTAssertEqual(avatarView?.name, userDetail.name, "name", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, renderSiteAdminViewAt idx: Int = 1, `for` userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        let siteAdminView = sut.siteAdminView(at: idx)
        XCTAssertEqual(siteAdminView?.loginText, userDetail.login, "login account text", file: file, line: line)
        XCTAssertEqual(siteAdminView?.isSiteAdmin, userDetail.siteAdmin, "site admin", file: file, line: line)
        XCTAssertNotNil(siteAdminView?.icon, "site admin icon", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, renderLocationViewAt idx: Int = 2, `for` userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        let locationView = sut.locationView(at: idx)
        XCTAssertEqual(locationView?.detailText, userDetail.location, "location", file: file, line: line)
        XCTAssertNotNil(locationView?.icon, "location view icon", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, renderBlogViewAt idx: Int = 3, `for` userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        let blogView = sut.blogView(at: idx)
        XCTAssertEqual(blogView?.detailText, userDetail.blog?.absoluteString, "blog address", file: file, line: line)
        XCTAssertNotNil(blogView?.icon, "blog view icon", file: file, line: line)
        XCTAssertNotEqual(blogView?.textColor, UILabel().textColor, "should set text color for blog view", file: file, line: line)
    }
    
    class LoaderSpy: UserDetailLoader, ImageDataLoader {
        var loadDetailCompletes: [UserDetailLoader.Complete] = []
        
        var loadCount: Int {
            loadDetailCompletes.count
        }
        
        func load(complete: @escaping UserDetailLoader.Complete) {
            loadDetailCompletes.append(complete)
        }
        
        func complete(with item: UserDetail, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
            if let complete = loadDetailCompletes[safe: index] {
                complete(.success(item))
                
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
                
            }
        }
        
        func complete(with error: Error, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
            if let complete = loadDetailCompletes[safe: index] {
                complete(.failure(error))
                
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
                
            }
        }
        
        //MARK: - image loading
        private(set) var avatarUrls: [URL] = []
        
        private(set) var cancelledAvatarUrls: [URL] = []
        
        private(set) var imageLoadingCompletions = [ImageDataLoader.Complete]()
        
        func load(url: URL, complete: @escaping ImageDataLoader.Complete) -> ImageDataTask {
            avatarUrls.append(url)
            imageLoadingCompletions.append(complete)
            return SpyImageDataTask(cancelCallback: { [weak self] in
                self?.cancelledAvatarUrls.append(url)
            })
        }
        
        func completeImageLoading(with result: ImageDataLoader.Result, at idx: Int) {
            if let completion = imageLoadingCompletions[safe: idx] {
                completion(result)
            }
        }
    }
    
    class SpyImageDataTask: ImageDataTask {
        private var cancelCallback: (() -> Void)?
        init(cancelCallback: @escaping ()-> Void) {
            self.cancelCallback = cancelCallback
        }
        func cancel() {
            cancelCallback?()
            cancelCallback = nil
        }
    }
    
}
