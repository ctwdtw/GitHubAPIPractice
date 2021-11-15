//
//  UserProfileViewController+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/15.
//

import UIKit
import GitHubAPIApp

extension UserProfileViewController {
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
    
    func renderedUserAvatarData(at idx: Int) -> Data? {
        simulateUserProfileViewIsVisible(at: idx)?.avatarImageView.image?.pngData()
    }
    
}
