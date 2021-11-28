//
//  AvatarCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import UIKit

public class AvatarCell: UITableViewCell {
    private let avatarWidth: CGFloat = 230
    
    private let stackViewSpacing: CGFloat = 4.0
    
    private let nameLabelFontSize: CGFloat = 30
    
    private let biographyLabelFontSize: CGFloat = 20.0
    
    private let stackViewHeight: CGFloat = 300.0
    
    private let upPadding: CGFloat = 50.0
    
    private let downPadding: CGFloat = 20.0
    
    private lazy var stackView: UIStackView = {
       let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: upPadding),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -downPadding),
            view.heightAnchor.constraint(equalToConstant: stackViewHeight)
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
    
    public var avatarImage: UIImage? = nil {
        didSet {
            avatarImageView.image = avatarImage
        }
    }
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: avatarWidth),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        view.roundCorner(radius: avatarWidth/2.0)
        
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
    
    private let retryButtonWidth: CGFloat = 80.0
    
    public var shouldRetry: Bool {
        get {
            !retryButton.isHidden
        }
        
        set {
            retryButton.isHidden = !newValue
        }
    }
    
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
    
    public var name: String? {
        set {
            nameLabel.text = newValue
        }
        
        get {
            nameLabel.text
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: nameLabelFontSize)
        return label
    }()
    
    public var biography: String? {
        set {
            biographyLabel.text = newValue
        }
        
        get {
            biographyLabel.text
        }
    }
    
    private lazy var biographyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: biographyLabelFontSize)
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        retryButton.roundCorner(radius: retryButtonWidth/2.0)
    }
    
    private func commonInit() {
        _ = stackView
        backgroundColor = UIColor.systemBackground
        stylingRetryButton()
    }
    
    private func stylingRetryButton() {
        retryButton.setTitle("Retry", for: .normal)
        retryButton.backgroundColor = .pink
        retryButton.isHidden = true
    }
    
}
