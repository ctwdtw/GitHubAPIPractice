//
//  UserDetailCell+TestHelpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit
import GitHubAPIApp

extension AvatarCell {
    var isShowingImageLoadingIndicator: Bool {
        isLoadingImage
    }
    
    var renderedImage: Data? {
        avatarImage?.pngData()
    }
    
    var isShowingRetryView: Bool {
        !retryButton.isHidden
    }
    
    func simulateTapRetryView() {
        retryButton.sendActions(for: .touchUpInside)
    }
    
//    var loginAccountText: String? {
//        return loginLabel.text
//    }
//
//    var showSiteAdminLabel: Bool {
//        return !siteAdminLabel.isHidden
//    }
}

