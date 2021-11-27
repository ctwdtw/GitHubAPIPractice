//
//  UserDetailCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit

public class UserDetailCell: UITableViewCell {
    private let standardSpace: CGFloat = 8.0
    
    private let avatarWidth: CGFloat = 80
    
    public private(set) lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        let widthHeightConstraint = view.widthAnchor.constraint(equalTo: view.heightAnchor)
        widthHeightConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: standardSpace),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardSpace),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardSpace),
            view.widthAnchor.constraint(equalToConstant: avatarWidth),
            widthHeightConstraint
        ])
        
        return view
    }()
    
    private lazy var vStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = standardSpace/2.0
        view.alignment = .leading
        
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: standardSpace),
            view.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardSpace)
        ])
        
        view.addArrangedSubview(loginLabel)
        view.addArrangedSubview(siteAdminLabel)
        return view
    }()
    
    public private(set) lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public private(set) lazy var siteAdminLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return label
    }()
    
    private lazy var imageLoadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
        return view
    }()
    
    public var isLoadingImage: Bool {
        set {
            if newValue {
                imageLoadingIndicator.startAnimating()
                
            } else {
                imageLoadingIndicator.stopAnimating()
                
            }
        }
        
        get {
            imageLoadingIndicator.isAnimating
        }
    }
    
    private let retryButtonWidth: CGFloat = 80.0
    
    public private(set) lazy var retryButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(retryButtonTouchUpInside), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            btn.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            btn.widthAnchor.constraint(equalToConstant: retryButtonWidth),
            btn.heightAnchor.constraint(equalTo: btn.widthAnchor)
        ])
        
        return btn
    }()
    
    @objc private func retryButtonTouchUpInside() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupLayout()
        stylingContentView()
        stylingAvatarImageView()
        stylingRetryButton()
        styingLoginLabel()
        stylingSiteAdminLabel()
    }
    
    private func setupLayout() {
        _ = avatarImageView
        _ = imageLoadingIndicator
        _ = retryButton
        _ = vStackView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.roundCorner(radius: avatarWidth/2.0)
        siteAdminLabel.roundCorner(radius: siteAdminLabel.bounds.height/2.0)
        retryButton.roundCorner(radius: retryButtonWidth/2.0)
    }
    
    private func stylingContentView() {
        contentView.backgroundColor = .systemBackground
    }
    
    private func stylingAvatarImageView() {}
    
    private func styingLoginLabel() {
        loginLabel.numberOfLines = 0
        loginLabel.textColor = .gray
        loginLabel.font = UIFont.systemFont(ofSize: 20)
    }
    
    private func stylingSiteAdminLabel() {
        siteAdminLabel.numberOfLines = 0
        siteAdminLabel.text = "STAFF"
        siteAdminLabel.textAlignment = .center
        siteAdminLabel.backgroundColor = .purple
        siteAdminLabel.textColor = .white
        siteAdminLabel.layer.masksToBounds = true
        siteAdminLabel.font = UIFont.systemFont(ofSize: 22)
        siteAdminLabel.isHidden = true
    }
    
    private func stylingRetryButton() {
        retryButton.setTitle("Retry", for: .normal)
        retryButton.backgroundColor = .pink
        retryButton.isHidden = true
    }

}

//MARK: - profile view
class ProfileView: UIView {
    private let avatarWidth: CGFloat = 160
    
    private let stackViewSpacing: CGFloat = 20.0
    
    private let nameLabelFontSize: CGFloat = 40.0
    
    private let biographyLabelFontSize: CGFloat = 20.0
    
    private lazy var stackView: UIStackView = {
       let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .center
        view.spacing = stackViewSpacing
        
        view.addArrangedSubview(avatarImageView)
        view.addArrangedSubview(nameLabel)
        view.addArrangedSubview(biographyLabel)
        return view
    }()
    
    public private(set) lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: avatarWidth),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }()
    
    public private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: nameLabelFontSize)
        return label
    }()
    
    public private(set) lazy var biographyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: biographyLabelFontSize)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        _ = stackView
    }
    
}

