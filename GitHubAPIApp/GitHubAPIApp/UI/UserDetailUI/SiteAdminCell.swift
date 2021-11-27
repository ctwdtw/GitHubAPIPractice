//
//  SiteAdminCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/27.
//

import UIKit

public class SiteAdminCell: UITableViewCell {
    public var icon: UIImage? {
        set {
            iconImageView.image = newValue
        }
        
        get {
            iconImageView.image
        }
    }
    
    public var loginText: String {
        set {
            siteAdminView.loginText = newValue
        }
        
        get {
            siteAdminView.loginText
        }
    }
    
    public var isSiteAdmin: Bool {
        set {
            siteAdminView.isSiteAdmin = newValue
        }
        
        get {
            siteAdminView.isSiteAdmin
        }
    }
    
    public var siteAdminText: String = "STAFF" {
        didSet {
            siteAdminView.siteAdminText = siteAdminText
        }
    }
    
    private let iconImageView = UIImageView()
    
    private let siteAdminView = SiteAdminView()
    
    private lazy var layout: LeftRightLayout = {
        LeftRightLayout(leftView: iconImageView, rightView: siteAdminView)
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
        layout.layout(on: contentView)
    }

}

private class SiteAdminView: UIView {
    private let standardSpace: CGFloat = 8.0
    
    private let loginTextSize: CGFloat = 18.0
    
    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        view.spacing = standardSpace/2.0
        view.addSubview(siteAdminLabel)
        view.addSubview(loginTextLabel)
        view.addArrangedSubview(loginTextLabel)
        view.addArrangedSubview(siteAdminLabel)
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standardSpace),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standardSpace),
            view.topAnchor.constraint(equalTo: topAnchor, constant: standardSpace),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standardSpace),
            loginTextLabel.widthAnchor.constraint(equalTo: siteAdminLabel.widthAnchor),
            siteAdminLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return view
    }()
    
    var loginText: String = "" {
        didSet {
            loginTextLabel.text = loginText
        }
    }
    
    private lazy var loginTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return loginTextLabelStyling(label)
    }()
    
    private func loginTextLabelStyling(_ label: UILabel) -> UILabel {
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: loginTextSize)
        return label
    }
    
    var siteAdminText: String = "" {
        didSet {
            siteAdminLabel.text = siteAdminText
            
        }
    }
    
    var isSiteAdmin: Bool = false {
        didSet {
            siteAdminLabel.isHidden = !isSiteAdmin
        }
    }
    
    private lazy var siteAdminLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return siteAdminStyling(label)
    }()
    
    private func siteAdminStyling(_ label: UILabel) -> UILabel {
        label.numberOfLines = 0
        label.text = "STAFF"
        label.textAlignment = .center
        label.backgroundColor = .purple
        label.textColor = .white
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 22)
        label.isHidden = isSiteAdmin
        return label
    }
    
    override func layoutSubviews() {
        siteAdminLabel.roundCorner(radius: siteAdminLabel.bounds.height/2.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        _ = contentStackView
    }
}
