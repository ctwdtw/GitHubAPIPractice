//
//  GitHubAPIAppTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import GitHubAPIApp

class UserProfileUIIntegrationTests: XCTestCase {
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
    
    func test__loadMoreAction__requestMoreFormLoader() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], hasMore: true, at: 0)
        
        XCTAssertEqual(loaderSpy.loadMoreCount, 0, "Expect no load more request until load more action")
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 1, "Expect one load more request")
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 1, "Expect no request while is loading more")
        
        loaderSpy.completeLoadMore(hasMore: true, at: 0)
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 2, "Expect request after load more complete with more pages")
        
        loaderSpy.completeLoadMore(with: anyNSError(), at: 1)
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 3, "Expect request after load more complete with error")
        
        loaderSpy.completeLoadMore(hasMore: false, at: 2)
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 3, "Expect no request after loading all pages")
    }

    func test__loadingIndicator__isDisplayedProperlyWhileLoadingUserProfile() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator once view is loaded")
        
        loaderSpy.complete(with: [], at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once loading is complete with success")
        
        sut.userInitiatedLoadAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator again when user initiate a reload")

        loaderSpy.complete(with: anyNSError(), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once user initiated loading is complete with failure")
    }
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view is loaded")
        
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], hasMore: true, at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")
        
        loaderSpy.completeLoadMore(hasMore: true, at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes successfully")
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")
        
        loaderSpy.completeLoadMore(with: anyNSError(), at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test__renderingUserProfiles__onLoaderComplete() {
        let item0 = UserProfile(id: 0, login: "user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        let item1 = UserProfile(id: 1, login: "another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: true)
        let item2 = UserProfile(id: 2, login: "yet-another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        assertThat(sut, rendering: [])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: [item0], at: 1)
        assertThat(sut, rendering: [item0])

        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: [item1, item2], at: 2)
        assertThat(sut, rendering: [item1, item2])
    }
    
    func test__renderEmptyUserProfiles__afterRenderNonEmptyUserProfiles() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0], hasMore: true, at: 0)
        assertThat(sut, rendering: [item0])
        
        sut.simulateUserInitiatedLoadMoreAction()
        loaderSpy.completeLoadMore(with: [item0, item1], hasMore: false, at: 0)
        assertThat(sut, rendering: [item0, item1])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: [], at: 1)
        
        sut.simulateUIKitRemoveUserProfileView(at: 0)
        sut.simulateUIKitRemoveUserProfileView(at: 1)
        assertThat(sut, rendering: [])
    }
    
    func test_loadMoreCompletion_rendersErrorMessageOnError() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], hasMore: true, at: 0)
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
        
        loaderSpy.completeLoadMore(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, anyNSError().localizedDescription)
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
    }
    
    func test_tapOnLoadMoreErrorView_loadsMore() {
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], hasMore: true, at: 0)
        
        sut.simulateUserInitiatedLoadMoreAction()
        XCTAssertEqual(loaderSpy.loadMoreCount, 1, "expect one load more request")
        
        sut.simulateTapOnRetryLoadMore()
        XCTAssertEqual(loaderSpy.loadMoreCount, 1, "expect no new load more request when retry load more before previous request complete")
        
        loaderSpy.completeLoadMore(with: anyNSError(), at: 0)
        sut.simulateTapOnRetryLoadMore()
        XCTAssertEqual(loaderSpy.loadMoreCount, 2, "expect two load more request when retry load more after previous request complete")
    }
    
    func test__doesNotAlterRenderedUserProfile__onLoaderCompleteWithFailure() {
        let item0 = makeUserProfile()
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0], hasMore: true, at: 0)
        assertThat(sut, rendering: [item0])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: anyNSError(), at: 1)
        assertThat(sut, rendering: [item0])
        
        sut.simulateUserInitiatedLoadMoreAction()
        loaderSpy.completeLoadMore(with: anyNSError(), at: 0)
        assertThat(sut, rendering: [item0])
    }
    
    func test__loadImage__whenUserProfileViewIsVisible() {
        let item0 = makeUserProfile(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserProfile(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1], at: 0)
        
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url request until user profile view become visible")
        
        sut.simulateUserProfileViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect first avatar url request when first user profile view become visible")
        
        sut.simulateUserProfileViewIsVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second request avatar url when second user profile view also become visible")
    }
    
    func test__cancelLoadImage__whenUserProfileViewIsNotVisibleAnymore() {
        let item0 = makeUserProfile(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserProfile(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1], at: 0)
        
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [], "Expect no cancelled avatar url request until user profile view is not visible")
        
        sut.simulateUserProfileViewIsNotVisible(at: 0)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl], "Expect first cancelled avatar url request when first user profile view become not visible anymore")
        
        sut.simulateUserProfileViewIsNotVisible(at: 1)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second cancelled avatar url request when second user profile view become not visible anymore")
    }
    
    func test__displayImageLoadingIndicator_whileLoadingImage() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        let view1 = sut.simulateUserProfileViewIsVisible(at: 1)
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
    
    func test__renderLoadedImage__onImageDataLoadingComplete() {
        let image0 = UIImage.image(with: .red).pngData()!
        let image1 = UIImage.image(with: .blue).pngData()!
        
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        let view1 = sut.simulateUserProfileViewIsVisible(at: 1)
        XCTAssertNil(view0?.renderedImage, "Expect no rendered image on first view until first image loading is complete successfully")
        XCTAssertNil(view1?.renderedImage, "Expect no rendered image on second view until second image loading is complete successfully")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(view0?.renderedImage, image0, "Expect rendered image0 on first view when first image loading is complete successfully")
        XCTAssertNil(view1?.renderedImage, "Expect no image rendering state changed for second view when first image loading is complete successfully")
        
        loaderSpy.completeImageLoading(with: .success(image1), at: 1)
        XCTAssertEqual(view0?.renderedImage, image0, "Expect no image rendering state changed for first view when second image loading is complete successfully")
        XCTAssertEqual(view1?.renderedImage, image1, "Expect render image1 on second view when second image loading is complete successfully")
    }
    
    func test__showRetryActionView__onImageDataLoadingCompleteWithError() {
        let image0 = UIImage.image(with: .red).pngData()!
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        let view1 = sut.simulateUserProfileViewIsVisible(at: 1)
        
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
    
    func test__showRetryActionView__onLoadedInvalidImageData() {
        let image0 = UIImage.image(with: .red).pngData()!
        let invalidImage = Data()
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [makeUserProfile(), makeUserProfile()], at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        let view1 = sut.simulateUserProfileViewIsVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view while loading image data")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no retry action view for second view while loading image data")
        
        loaderSpy.completeImageLoading(with: .success(image0), at: 0)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no retry action view for first view when complete loading first image data successfully")
        XCTAssertEqual(view1?.isShowingRetryView, false, "Expect no change of retry action view visibility for second view when complete loading first image data successfully")
        
        loaderSpy.completeImageLoading(with: .success(invalidImage), at: 1)
        XCTAssertEqual(view0?.isShowingRetryView, false, "Expect no change of retry action view visibility for first view when complete loading second image with error")
        XCTAssertEqual(view1?.isShowingRetryView, true, "Expect retry action view for second view when complete loading second image but with invalid image data")
    }
    
    func test__retryImageLoadingAction__onTapRetryActionView() {
        let item0 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0], at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request for the visible profile view")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect no change of avatar url request before user initiate a retry action")
        
        view0?.simulateTapRetryView()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item0.avatarUrl], "Expect two avatar url request for the visible profile view when user initiate a retry action")
    }
    
    func test__preloadAvatarImage__whenProfileViewIsNearVisible() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        loaderSpy.complete(with: [item0, item1], at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url until first user profile view become near visible")
        
        sut.simulateUserProfileViewIsNearVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect first avatar url once first user profile view become near visible")
        
        sut.simulateUserProfileViewIsNearVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second avatar url once second user profile view become near visible")
    }
    
    func test__cancelPreloadAvatarImage__whenProfileViewIsNotNearVisible() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1], at: 0)
        
        sut.simulateUserProfileViewIsNearVisible(at: 0)
        sut.simulateUserProfileViewIsNearVisible(at: 1)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [], "Expect no cancel avatar url until first user profile view become not near visible")
        
        sut.simulateUserProfileViewIsNotNearVisible(at: 0)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl], "Expect cancel first avatar url when first user profile view become not visible anymore")
        
        sut.simulateUserProfileViewIsNotNearVisible(at: 1)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect cancel second avatar url when second user profile view become not visible anymore")
    }
    
    func test__userProfiles__doesNotRenderedLoadedImageWhenNotVisibleAnymore() {
        let item0 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0], at: 0)
        
        let queuedReusableCell = sut.simulateUserProfileViewIsNotVisible(at: 0)
        loaderSpy.completeImageLoading(with: .success(UIImage.image(with: .red).pngData()!), at: 0)
        
        XCTAssertNil(queuedReusableCell?.avatarImageView.image)
    }
    
    func test_notifySelectionHandler_onProfileSelected() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let item2 = makeUserProfile()
        
        var selectedProfile: [UserProfile] = []
        let (sut, loaderSpy) = makeSUT(selection: { selectedProfile.append($0)  })
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: [item0, item1, item2], at: 0)
        
        sut.simulateTapOnProfile(at: 1)
        
        XCTAssertEqual(selectedProfile, [item1])
    }
    
    private func makeUserProfile(id: Int = { Int.random(in: 0...999)  }(), login: String = "a-user-login-account", avatarUrl: URL = URL(string: "https://any-avatar-url")!, siteAdmin: Bool = false) -> UserProfile {
        return UserProfile(id: id, login: login, avatarUrl: avatarUrl, siteAdmin: siteAdmin)
    }
    
    private func makeSUT(selection: @escaping (UserProfile) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> (ListViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserProfileUIComposer.make(
            onSelectProfile: selection,
            userProfileLoaderFactory: { loaderSpy },
            avatarImageDataLoader: loaderSpy
        )
        trackForMemoryLeak(loaderSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, loaderSpy)
    }

}
