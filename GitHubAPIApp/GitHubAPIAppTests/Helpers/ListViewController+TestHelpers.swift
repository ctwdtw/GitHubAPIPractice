//
//  ListViewController+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/15.
//

import UIKit
import GitHubAPIApp

extension ListViewController {
    func userInitiatedLoadAction() {
        refreshControl?.sendActions(for: .valueChanged)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    var numberOfRenderedSections: Int {
        return tableView.numberOfSections
    }
    
}

//MARK: - UserProfile
extension ListViewController {
    var numberOfRenderedUserProfile: Int {
        return tableView.numberOfRows(inSection: userProfileSection)
    }
    
    var userProfileSection: Int {
        return 0
    }
    
    var loadMoreSection: Int {
        return 1
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
    
    func simulateUIKitRemoveUserProfileView(at idx: Int) {
        tableView.delegate?.tableView?(tableView, didEndDisplaying: UserProfileCell(), forRowAt: IndexPath(row: idx, section: userProfileSection))
    }
    
    func simulateUserInitiatedLoadMoreAction() {
        guard tableView.numberOfSections > loadMoreSection  else {
            return
        }

        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        guard let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) else {
            return
        }
        
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func simulateTapOnRetryLoadMore() {
        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
            return loadMoreFeedCell()?.isLoading == true
    }
    
    var loadMoreFeedErrorMessage: String? {
        return loadMoreFeedCell()?.message
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        guard tableView.numberOfSections > loadMoreSection  else {
            return nil
        }
        
        let indexPath = IndexPath(row: 0, section: loadMoreSection)
        guard let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as? LoadMoreCell else {
            return nil
        }
        
        return cell
    }
    
    func simulateTapOnProfile(at idx: Int) {
        let indexPath = IndexPath(row: idx, section: userProfileSection)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

//MARK: - UserDetail
extension ListViewController {
    var userDetailSection: Int {
        return 0
    }
    
    var avatarSection: Int {
        return 0
    }
    
    var avatarRow: Int {
        return 0
    }
    
    func avatarView(at idx: Int = 0) -> AvatarCell? {
        userDetailView(at: idx) as? AvatarCell
    }
    
    func siteAdminView(at idx: Int = 1) -> SiteAdminCell? {
        userDetailView(at: idx) as? SiteAdminCell
    }
    
    func locationView(at idx: Int = 2) -> DetailFieldCell? {
        userDetailView(at: idx) as? DetailFieldCell
    }
    
    func blogView(at idx: Int = 3) -> DetailFieldCell? {
        userDetailView(at: idx) as? DetailFieldCell
    }
    
    private func userDetailView(at row: Int) -> UITableViewCell? {
        return tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: userDetailSection))
    }
    
    @discardableResult
    func simulateAvatarViewIsVisible() -> AvatarCell? {
        let indexPath = IndexPath(row: avatarRow, section: avatarSection)
        let cell = avatarView()
        tableView.delegate?.tableView?(tableView, willDisplay: cell!, forRowAt: indexPath)
        return cell
    }
    
    @discardableResult
    func simulateAvatarViewIsNotVisible() -> AvatarCell? {
        let indexPath = IndexPath(row: avatarRow, section: avatarSection)
        let cell = simulateAvatarViewIsVisible()
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
        return cell
    }
    
}
