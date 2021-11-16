//
//  UserProfileCell+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/15.
//

import UIKit
import GitHubAPIApp

extension UserProfileCell {
    var loginAccountText: String? {
        return loginLabel.text
    }
    
    var showSiteAdminLabel: Bool {
        return !siteAdminLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        isLoadingImage
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
