//
//  UserProfileViewControllerSnapshotTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/15.
//

import XCTest
@testable import GitHubAPIApp

class UserProfileViewControllerSnapshotTests: XCTestCase {

    func test_emptyUserProfileList() {
        let sut = makeSUT()

        sut.display(emptyUserProfiles())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "EmptyUserProfiles-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "EmptyUserProfiles-dark")
    }
    
    func test_nonEmptyUserProfileList() {
        let sut = makeSUT()
    
        sut.display(userProfilesWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "UserProfilesWithContent-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "UserProfilesWithContent-dark")
    }
    
    func test_userProfilesWithFailedAvatarLoading() {
        let sut = makeSUT()
    
        sut.display(userProfilesWithFailedAvatarLoading())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "UserProfileWithFailedAvatarLoading-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "UserProfileWithFailedAvatarLoading-dark")
    }
    
    func test_userProfilesWhileLoadingAvatar() {
        let sut = makeSUT()
    
        sut.display(userProfileWhileAvatarLoading())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "UserProfileWhileAvatarLoading-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "UserProfileWhileAvatarLoading-dark")
    }
    
    func test_userProfilesWithLoadMoreIndicator() {
        let sut = makeSUT()
    
        sut.display(userProfilesWithLoadMoreIndicator())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "UserProfileWithLoadMoreIndicator-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "UserProfileWithLoadMoreIndicator-dark")
    }
    
    func test_userProfilesWithLoadMoreErrors() {
        let sut = makeSUT()
    
        sut.display(userProfilesWithLoadMoreError())

        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "UserProfileWithLoadMoreError-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "UserProfileWithLoadMoreError-dark")
    }
    
    private func emptyUserProfiles() -> ListViewController.TableModel {
        return [[]]
    }
    
    private func userProfilesWithContent() -> ListViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: UIImage.image(with: .red)),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: UIImage.image(with: .green)),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: UIImage.image(with: .blue))
        ].map(CellController.init(dataSource:))
        
        return [cellControllers]
    }
    
    private func userProfilesWithFailedAvatarLoading() -> ListViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: nil, shouldRetry: true),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: nil, shouldRetry: true),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: nil, shouldRetry: true)
        ].map(CellController.init(dataSource:))
        
        return [cellControllers]
    }
    
    private func userProfileWhileAvatarLoading() -> ListViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: nil, isLoading: true),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: nil, isLoading: true),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: nil, isLoading: true)
        ].map(CellController.init(dataSource:))
        
        return [cellControllers]
    }
    
    private func userProfilesWithLoadMoreIndicator() -> ListViewController.TableModel {
        let profiles = userProfilesWithContent().first!
        let loadMoreController = [CellController(dataSource: LoadMoreStub(isLoading: true))]
        
        return [profiles, loadMoreController]
    }
    
    private func userProfilesWithLoadMoreError() -> ListViewController.TableModel {
        let profiles = userProfilesWithContent().first!
        let loadMoreController = [CellController(dataSource: LoadMoreStub(errorMessage: "a multi-line\n line1\n line2\n line3\n error message"))]
        
        return [profiles, loadMoreController]
    }
    
    private func makeSUT() -> ListViewController {
        let sut = ListViewController()
        return sut
    }
    
    private class UserProfileStub: NSObject, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UserProfileCell()
            cell.loginLabel.text = loginAccountText
            cell.siteAdminLabel.isHidden = !isSiteAdmin
            cell.avatarImageView.image = avatarImage
            cell.isLoadingImage = isLoading
            cell.retryButton.isHidden = !shouldRetry
            return cell
        }
        
        private let loginAccountText: String
        
        private let isSiteAdmin: Bool
        
        private let avatarImage: UIImage?
        
        private let isLoading: Bool
        
        private let shouldRetry: Bool
        
        init(loginAccountText: String, isSiteAdmin: Bool = false, avatarImage: UIImage?, isLoading: Bool = false, shouldRetry: Bool = false) {
            self.loginAccountText = loginAccountText
            self.isSiteAdmin = isSiteAdmin
            self.avatarImage = avatarImage
            self.isLoading = isLoading
            self.shouldRetry = shouldRetry
        }
    }
    
    private class LoadMoreStub: NSObject, UITableViewDataSource {
        let cell = LoadMoreCell()
        
        private let isLoading: Bool
        
        private let errorMessage: String?
        
        init(isLoading: Bool = false, errorMessage: String? = nil) {
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            cell.isLoading = isLoading
            cell.errorMessageLabel.isHidden = errorMessage == nil
            cell.errorMessageLabel.text = errorMessage
            
            return cell
        }
    
    }

}
