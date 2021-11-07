//
//  UserProfileCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit

public class UserProfileCell: UITableViewCell {
    public let loginLabel = UILabel()
    public let siteAdminLabel = UILabel()
    public let imageLoadingIndicator = UIActivityIndicatorView()
    public let avatarImageView = UIImageView()
    public private(set) lazy var retryButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(retryButtonTouchUpInside), for: .touchUpInside)
        return btn
    }()
    
    @objc private func retryButtonTouchUpInside() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
}
