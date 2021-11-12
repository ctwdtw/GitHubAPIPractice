//
//  UserProfileCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit

public class UserProfileCell: UITableViewCell {
    private let standardSpace: CGFloat = 8.0
    
    private let avatarWidth: CGFloat = 80
    
    public lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: standardSpace),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardSpace),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardSpace),
            view.widthAnchor.constraint(equalTo: view.heightAnchor),
            view.widthAnchor.constraint(equalToConstant: avatarWidth)
        ])
        
        return view
    }()
    
    public lazy var vStackView: UIStackView = {
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
    
    public lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public lazy var siteAdminLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return label
    }()
    
    public lazy var imageLoadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
        return view
    }()
    
    public private(set) lazy var retryButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(retryButtonTouchUpInside), for: .touchUpInside)
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
        _ = avatarImageView
        _ = vStackView
        
        stylingContentView()
        stylingAvatarImageView()
        styingLoginLabel()
        stylingSiteAdminLabel()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.roundCorner(radius: avatarWidth/2.0)
        siteAdminLabel.roundCorner(radius: siteAdminLabel.bounds.height/2.0)
    }
    
    private func stylingContentView() {
        contentView.backgroundColor = .white
    }
    
    private func stylingAvatarImageView() {
        siteAdminLabel.isHidden = true
    }
    
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
    }
    
}

extension UIView {
    func roundCorner(radius cornerRadius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}


