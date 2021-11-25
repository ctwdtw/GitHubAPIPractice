//
//  UserDetailCell+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit
import GitHubAPIApp

extension UserDetailCell {
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

