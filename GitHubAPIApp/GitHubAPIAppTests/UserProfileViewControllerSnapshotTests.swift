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
    
    private func emptyUserProfiles() -> UserProfileViewController.TableModel {
        return [[]]
    }
    
    private func userProfilesWithContent() -> UserProfileViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: UIImage.image(with: .red)),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: UIImage.image(with: .green)),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: UIImage.image(with: .blue))
        ].map(CellController.init(viewCreator:))
        
        return [cellControllers]
    }
    
    private func userProfilesWithFailedAvatarLoading() -> UserProfileViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: nil, shouldRetry: true),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: nil, shouldRetry: true),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: nil, shouldRetry: true)
        ].map(CellController.init(viewCreator:))
        
        return [cellControllers]
    }
    
    private func userProfileWhileAvatarLoading() -> UserProfileViewController.TableModel {
        let cellControllers =
        [UserProfileStub(loginAccountText: "login-text", isSiteAdmin: false, avatarImage: nil, isLoading: true),
         UserProfileStub(loginAccountText: "another-login-text", isSiteAdmin: true, avatarImage: nil, isLoading: true),
         UserProfileStub(loginAccountText: "yet-another-login-text", avatarImage: nil, isLoading: true)
        ].map(CellController.init(viewCreator:))
        
        return [cellControllers]
    }
    
    private func makeSUT() -> UserProfileViewController {
        let sut = UserProfileViewController()
        return sut
    }
    
    private class UserProfileStub: CellViewCreator {
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
        
        func view(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = UserProfileCell()
            cell.loginLabel.text = loginAccountText
            cell.siteAdminLabel.isHidden = !isSiteAdmin
            cell.avatarImageView.image = avatarImage
            cell.isLoadingImage = isLoading
            cell.retryButton.isHidden = !shouldRetry
            return cell
        }
    }

}
