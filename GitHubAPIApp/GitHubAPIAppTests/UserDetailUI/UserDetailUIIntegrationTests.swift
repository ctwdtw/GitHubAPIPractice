//
//  UserDetailUI.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/25.
//

import XCTest
import GitHubAPI
import GitHubAPIApp

class UserDetailUIIntegrationTests: UserProfileUIIntegrationTests {
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
    
    /*
    override func test__loadImage__whenUserDetailViewIsVisible() {
        let item0 = makeUserDetail(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserDetail(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1], at: 0)
        
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url request until user profile view become visible")
        
        sut.simulateUserDetailViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect first avatar url request when first user profile view become visible")
        
        sut.simulateUserDetailViewIsVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second request avatar url when second user profile view also become visible")
    }
    
    override func test__cancelLoadImage__whenUserDetailViewIsNotVisibleAnymore() {
        let item0 = makeUserDetail(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserDetail(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1], at: 0)
        
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [], "Expect no cancelled avatar url request until user profile view is not visible")
        
        sut.simulateUserDetailViewIsNotVisible(at: 0)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl], "Expect first cancelled avatar url request when first user profile view become not visible anymore")
        
        sut.simulateUserDetailViewIsNotVisible(at: 1)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second cancelled avatar url request when second user profile view become not visible anymore")
    }
    
    override func test__displayImageLoadingIndicator_whileLoadingImage() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserDetail(), makeUserDetail()], at: 0)
        
        let view0 = sut.simulateUserDetailViewIsVisible(at: 0)
        let view1 = sut.simulateUserDetailViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expect loading indicator for first view while loading first avatar image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view while loading second avatar image")
        
        loaderSpy.completeImageLoading(with: .success(Data()), at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for first view once first avatar loading complete successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view does not change once first avatar loading complete successfully")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect loading indicator for the first view does not change once second avatar loading complete with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for second view once second avatar loading complete with error")
        
        view1?.simulateTapRetryView()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect no change of avatar loading indicator for first view")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view when avatar image loading is retried.")
    }
    
    override func test__renderLoadedImage__onImageDataLoadingComplete() {
        let image0 = UIImage.image(with: .red).pngData()!
        let image1 = UIImage.image(with: .blue).pngData()!
        
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserDetail(), makeUserDetail()], at: 0)
        
        let view0 = sut.simulateUserDetailViewIsVisible(at: 0)
        let view1 = sut.simulateUserDetailViewIsVisible(at: 1)
        XCTAssertNil(view0?.renderedImage, "Expect no rendered image on first view until first image loading is complete successfully")
        XCTAssertNil(view1?.renderedImage, "Expect no rendered image on second view until second image loading is complete successfully")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(view0?.renderedImage, image0, "Expect rendered image0 on first view when first image loading is complete successfully")
        XCTAssertNil(view1?.renderedImage, "Expect no image rendering state changed for second view when first image loading is complete successfully")
        
        loaderSpy.completeImageLoading(with: .success(image1), at: 1)
        XCTAssertEqual(view0?.renderedImage, image0, "Expect no image rendering state changed for first view when second image loading is complete successfully")
        XCTAssertEqual(view1?.renderedImage, image1, "Expect render image1 on second view when second image loading is complete successfully")
    }
    
    override func test__showRetryActionView__onImageDataLoadingCompleteWithError() {
        let image0 = UIImage.image(with: .red).pngData()!
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserDetail(), makeUserDetail()], at: 0)
        
        let view0 = sut.simulateUserDetailViewIsVisible(at: 0)
        let view1 = sut.simulateUserDetailViewIsVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view while loading image data")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no retry action view for second view while loading image data")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view when complete loading first image data successfully")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no change of retry action view visibility for second view when complete loading first image data successfully")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no change of retry action view visibility for first view when complete loading second image with error")
        XCTAssertEqual(view1?.isShowingRetryView, true, "Expect retry action view for second view when complete loading second image with error")
        
        view1?.simulateTapRetryView()
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no change of retry action view visibility for the first view when user initiate a retry action for the second view")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no retry action view for the second view when user initiate a retry action for the second view")
    }
    
    override func test__showRetryActionView__onLoadedInvalidImageData() {
        let image0 = UIImage.image(with: .red).pngData()!
        let invalidImage = Data()
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserDetail(), makeUserDetail()], at: 0)
        
        let view0 = sut.simulateUserDetailViewIsVisible(at: 0)
        let view1 = sut.simulateUserDetailViewIsVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view while loading image data")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no retry action view for second view while loading image data")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view when complete loading first image data successfully")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no change of retry action view visibility for second view when complete loading first image data successfully")
        
        loaderSpy.completeImageLoading(with: .success(invalidImage), at: 1)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no change of retry action view visibility for first view when complete loading second image with error")
        XCTAssertEqual(view1?.isShowingRetryView, true, "Expect retry action view for second view when complete loading second image but with invalid image data")
    }
    
    override func test__retryImageLoadingAction__onTapRetryActionView() {
        let item0 = makeUserDetail()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0], at: 0)
        
        let view0 = sut.simulateUserDetailViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request for the visible profile view")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect no change of avatar url request before user initiate a retry action")
        
        view0?.simulateTapRetryView()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item0.avatarUrl], "Expect two avatar url request for the visible profile view when user initiate a retry action")
    }*/
    
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
                
        let avatarView = sut.avatarView()
        XCTAssertEqual(avatarView?.biography, userDetail.biography, "biography", file: file, line: line)
        XCTAssertEqual(avatarView?.name, userDetail.name, "name", file: file, line: line)
        
        let siteAdminView = sut.siteAdminView()
        XCTAssertEqual(siteAdminView?.loginText, userDetail.login, "login account text", file: file, line: line)
        XCTAssertEqual(siteAdminView?.isSiteAdmin, userDetail.siteAdmin, "site admin", file: file, line: line)
        
        let locationView = sut.locationView()
        XCTAssertEqual(locationView?.detailText, userDetail.location, "location", file: file, line: line)
        
        let blogView = sut.blogView()
        XCTAssertEqual(blogView?.detailText, userDetail.blog?.absoluteString, "blog address", file: file, line: line)
    }
    
    func assertThat(_ sut: ListViewController, doesNotYetHaveViewConfiguredFor userDetail: UserDetail, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedSections, 1, "one empty section", file: file, line: line)
        XCTAssertTrue(sut.tableModel[0].isEmpty, "empty rows", file: file, line: line)
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
