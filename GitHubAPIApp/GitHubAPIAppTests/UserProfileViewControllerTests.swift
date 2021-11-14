//
//  GitHubAPIAppTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import GitHubAPIApp

/*
    [v] Load feed automatically when view is presented
    [v] Allow customer to manually reload feed (pull to refresh)
    [v] Show a loading indicator while loading feed
       -> 包含 view is presented 和 user pull to refresh 兩種情況下的 loading,
          都要考慮 loading indicator
    [v] Render all loaded feed items (location, image, description)
    [v] Image loading experience
        [v] Load when image view is visible (on screen)
        [v] Cancel when image view is out of screen
        [v] Show a loading indicator while loading image (shimmer)
        [v] Option to retry on image download error
        [v] Preload when image view is near visible
*/

/*
 [] Layout
 [] Infinite Scroll Experience
     [] Trigger Load More action on scroll to bottom
         [] Only if there are more items to load
         [] Only if not already loading
     [] Show loading indicator while loading
     [] Show error message on failure
       [] Tap on error to retry
 */

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
    func test__loadingIndicator__isDisplayedProperlyWhileLoadingUserProfile() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator once view is loaded")
        
        loaderSpy.complete(with: UserProfileURLPackage.empty(), at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once loading is complete with success")
        
        sut.userInitiatedLoadAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect show loading indicator again when user initiate a reload")

        loaderSpy.complete(with: anyNSError(), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect hide loading indicator once user initiated loading is complete with failure")
    }
    
    // [v] Image loading experience
    func test__renderingUserProfiles__onLoaderComplete() {
        let item0 = UserProfile(id: 0, login: "user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        let item1 = UserProfile(id: 1, login: "another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: true)
        let item2 = UserProfile(id: 2, login: "yet-another-user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage.empty(), at: 0)
        assertThat(sut, rendering: [])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: UserProfileURLPackage([item0]), at: 1)
        assertThat(sut, rendering: [item0])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: UserProfileURLPackage([item1, item2]), at: 2)
        assertThat(sut, rendering: [item1, item2])
    }
    
    // [v] Image loading experience
    func test__doesNotAlterRenderedUserProfile__onLoaderCompleteWithFailure() {
        let item0 = UserProfile(id: 0, login: "user-login-account", avatarUrl: URL(string: "https://any-url.com")!, siteAdmin: false)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([item0]), at: 0)
        assertThat(sut, rendering: [item0])
        
        sut.userInitiatedLoadAction()
        loaderSpy.complete(with: anyNSError(), at: 1)
        assertThat(sut, rendering: [item0])
    }
    
    // [v] Load when image view is visible (on screen)
    func test__loadImage__whenUserProfileViewIsVisible() {
        let item0 = makeUserProfile(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserProfile(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([item0, item1]), at: 0)
        
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url request until user profile view become visible")
        
        sut.simulateUserProfileViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect first avatar url request when first user profile view become visible")
        
        sut.simulateUserProfileViewIsVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second request avatar url when second user profile view also become visible")
    }
    
    // [v] Cancel when image view is out of screen
    func test__cancelLoadImage__whenUserProfileViewIsNotVisibleAnymore() {
        let item0 = makeUserProfile(avatarUrl: URL(string: "https://a-avatar-url.com")!)
        let item1 = makeUserProfile(avatarUrl: URL(string: "https://another-avatar-url.com")!)
        
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([item0, item1]), at: 0)
        
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [], "Expect no cancelled avatar url request until user profile view is not visible")
        
        sut.simulateUserProfileViewIsNotVisible(at: 0)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl], "Expect first cancelled avatar url request when first user profile view become not visible anymore")
        
        sut.simulateUserProfileViewIsNotVisible(at: 1)
        XCTAssertEqual(loaderSpy.cancelledAvatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second cancelled avatar url request when second user profile view become not visible anymore")
    }
    
    // [v] Show a loading indicator while loading image (shimmer)
    func test__displayImageLoadingIndicator_whileLoadingImage() {
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([makeUserProfile(), makeUserProfile()]), at: 0)
        
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
    
    // [v] Image loading experience
    func test__renderLoadedImage__onImageDataLoadingComplete() {
        let image0 = UIImage.image(with: .red).pngData()!
        let image1 = UIImage.image(with: .blue).pngData()!
        
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([makeUserProfile(), makeUserProfile()]), at: 0)
        
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
    
    // [v] Option to retry on image download error
    func test__showRetryActionView__onImageDataLoadingCompleteWithError() {
        let image0 = UIImage.image(with: .red).pngData()!
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([makeUserProfile(), makeUserProfile()]), at: 0)
        
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
    
    // [v] Option to retry on image download error
    func test__showRetryActionView__onLoadedInvalidImageData() {
        let image0 = UIImage.image(with: .red).pngData()!
        let invalidImage = Data()
        let (sut, loaderSpy) = makeSUT()
        
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([makeUserProfile(), makeUserProfile()]), at: 0)
        
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
    
    // [v] Option to retry on image download error
    func test__retryImageLoadingAction__onTapRetryActionView() {
        let item0 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([item0]), at: 0)
        
        let view0 = sut.simulateUserProfileViewIsVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect one avatar url request for the visible profile view")
        
        loaderSpy.completeImageLoading(with: .failure(anyNSError()), at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect no change of avatar url request before user initiate a retry action")
        
        view0?.simulateTapRetryView()
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item0.avatarUrl], "Expect two avatar url request for the visible profile view when user initiate a retry action")
    }
    
    // [v] Preload when image view is near visible
    func test__preloadAvatarImage__whenProfileViewIsNearVisible() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        loaderSpy.complete(with: UserProfileURLPackage([item0, item1]), at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [], "Expect no avatar url until first user profile view become near visible")
        
        sut.simulateUserProfileViewIsNearVisible(at: 0)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl], "Expect first avatar url once first user profile view become near visible")
        
        sut.simulateUserProfileViewIsNearVisible(at: 1)
        XCTAssertEqual(loaderSpy.avatarUrls, [item0.avatarUrl, item1.avatarUrl], "Expect second avatar url once second user profile view become near visible")
    }
    
    // [v] Preload when image view is near visible
    func test__cancelPreloadAvatarImage__whenProfileViewIsNotNearVisible() {
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let (sut, loaderSpy) = makeSUT()
        sut.loadViewIfNeeded()
        loaderSpy.complete(with: UserProfileURLPackage([item0, item1]), at: 0)
        
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
        loaderSpy.complete(with: UserProfileURLPackage([item0]), at: 0)
        
        let queuedReusableCell = sut.simulateUserProfileViewIsNotVisible(at: 0)
        loaderSpy.completeImageLoading(with: .success(UIImage.make(withColor: .red).pngData()!), at: 0)
        
        XCTAssertNil(queuedReusableCell?.avatarImageView.image)
    }
    
    private func makeUserProfile(id: Int = { Int.random(in: 0...999)  }(), login: String = "a-user-login-account", avatarUrl: URL = URL(string: "https://any-avatar-url")!, siteAdmin: Bool = false) -> UserProfile {
        return UserProfile(id: id, login: login, avatarUrl: avatarUrl, siteAdmin: siteAdmin)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (UserProfileViewController, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = UserProfileUIComposer.make(userProfileLoader: loaderSpy, avatarImageDataLoader: loaderSpy)
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
        
        func complete(with resource: UserProfileLoader.Resource, at index: Int, file: StaticString = #file, line: UInt = #line) {
            if let complete = loadProfileCompletes[safe: index] {
                complete(.success(resource))
            
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
            
            }
        }
        
        func complete(with error: Error, at index: Int, file: StaticString = #file, line: UInt = #line) {
            if let complete = loadProfileCompletes[safe: index] {
                complete(.failure(error))
            
            } else {
                XCTFail("load completions index out of range", file: file, line: line)
            
            }
        }
        
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
    
    private class SpyImageDataTask: ImageDataTask {
        private var cancelCallback: (() -> Void)?
        init(cancelCallback: @escaping ()-> Void) {
            self.cancelCallback = cancelCallback
        }
        func cancel() {
            cancelCallback?()
            cancelCallback = nil
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
            assertThat(sut, hasViewConfiguredFor: userProfile, at: idx, file: file, line: line)
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
    
    private func anyNSError() -> Error {
        NSError(domain: "any-ns-error", code: -1, userInfo: nil)
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
    
    @discardableResult
    func simulateUserProfileViewIsVisible(at idx: Int) -> UserProfileCell? {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        let cell = userProfileView(at: idx) as? UserProfileCell
        tableView.delegate?.tableView?(tableView, willDisplay: cell!, forRowAt: indexPath)
        return cell
    }
    
    @discardableResult
    func simulateUserProfileViewIsNotVisible(at idx: Int) -> UserProfileCell? {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        let cell = simulateUserProfileViewIsVisible(at: idx)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
    func simulateUserProfileViewIsNearVisible(at idx: Int) {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateUserProfileViewIsNotNearVisible(at idx: Int) {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
}

private extension UserProfileCell {
    var loginAccountText: String? {
        return loginLabel.text
    }
    
    var showSiteAdminLabel: Bool {
        return !siteAdminLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        !imageLoadingIndicator.isHidden
    }
    
    var renderedImage: Data? {
        avatarImageView.image?.pngData()
    }
    
    var isShowingRetryView: Bool {
        !retryButton.isHidden
    }
    
    func simulateTapRetryView() {
        retryButton.sendActions(for: .touchUpInside)
    }
}

private extension UserProfileURLPackage {
    static func empty() -> UserProfileURLPackage {
        UserProfileURLPackage([], nextURL: nil)
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

private extension UIImage {
    static func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
