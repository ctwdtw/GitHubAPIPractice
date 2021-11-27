//
//  UserDetailSnapshotTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/26.
//

import XCTest
import GitHubAPIApp

class UserDetailSnapshotTests: XCTestCase {
    func test_detailFieldCell() {
        let sut = TableViewCellSnapshotContainer<DetailFieldCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "mappin.and.ellipse")
            cell.text = "San Fransisco"
        })
        
        let image = sut.defaultSizeSnapshot(style: .dark)
        
        assert(snapshot: image, named: "detail-field-view-dark")
    }
    
    func test_siteAdminCell() {
        let sut = TableViewCellSnapshotContainer<SiteAdminCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "person.fill")
            cell.loginText = "defunkt"
            cell.isSiteAdmin = true
            cell.siteAdminText = "STAFF"
        })
        
        let image = sut.defaultSizeSnapshot(style: .dark)
        
        assert(snapshot: image, named: "site-admin-cell-dark")
    }
}

struct LeftRightLayout {
    private let standardSpace: CGFloat = 8.0
    
    private let leftViewSize: CGFloat = 30.0
    
    private let leftView: UIView
    
    private let rightView: UIView
    
    init(leftView: UIView, rightView: UIView) {
        self.leftView = leftView
        self.rightView = rightView
    }
    
    func layout(on superView: UIView) {
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        superView.addSubview(leftView)
        superView.addSubview(rightView)
        
        NSLayoutConstraint.activate([
            leftView.heightAnchor.constraint(equalTo: leftView.widthAnchor),
            leftView.heightAnchor.constraint(equalToConstant: leftViewSize),
            leftView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: standardSpace),
        ])
        
        NSLayoutConstraint.activate([
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: standardSpace),
            rightView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -standardSpace),
            rightView.topAnchor.constraint(equalTo: superView.topAnchor, constant: standardSpace),
            rightView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -standardSpace),
            rightView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
        ])
        
    }
    
}

public class SiteAdminCell: UITableViewCell {
    public var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }
    
    public var loginText: String = "" {
        didSet {
            siteAdminView.loginText = loginText
        }
    }
    
    public var isSiteAdmin: Bool = false {
        didSet {
            siteAdminView.isSiteAdmin = isSiteAdmin
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

public class DetailFieldCell: UITableViewCell {
    public var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }
    
    private let standardSpace: CGFloat = 8.0
    
    private let iconSize: CGFloat = 30.0
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: view.widthAnchor),
            view.heightAnchor.constraint(equalToConstant: iconSize),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardSpace),
        ])
        
        view.image = icon
        return view
    }()
    
    public var text: String = "" {
        didSet {
            rightView.text = text
        }
    }
    
    private lazy var rightView: RightLabelView = {
        let view = RightLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: standardSpace),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardSpace),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardSpace),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardSpace),
            view.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
        
        return view
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
        _ = iconImageView
        _ = rightView
        selectionStyle = .none
    }
    
}



class SiteAdminView: UIView {
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

class RightLabelView: UIView {
    private let standardSpace: CGFloat = 8.0
    
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 68)
        ])
        
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18.0)

        
        return label
    }()
    
}
