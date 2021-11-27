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
            cell.text = "defunkt"
            cell.siteAdminText = "STAFF"
        })
        
        let image = sut.defaultSizeSnapshot(style: .dark)
        
        assert(snapshot: image, named: "site-admin-cell-dark")
    }
}

public class SiteAdminCell: UITableViewCell {
    private let standardSpace: CGFloat = 8.0
    
    private let iconDetailLabelSpace: CGFloat = 24.0
    
    private let iconSize: CGFloat = 30.0
    
    private let detailTextSize: CGFloat = 18.0
    
    public var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }
    
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
    
    private lazy var rightStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        view.spacing = standardSpace/2.0
        view.addSubview(siteAdminLabel)
        view.addSubview(fieldLabel)
        view.addArrangedSubview(fieldLabel)
        view.addArrangedSubview(siteAdminLabel)
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: iconDetailLabelSpace),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardSpace),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardSpace),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardSpace),
            view.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            fieldLabel.widthAnchor.constraint(equalTo: siteAdminLabel.widthAnchor)
        ])
        
        return view
    }()
    
    public var text: String = "" {
        didSet {
            fieldLabel.text = text
        }
    }
    
    private lazy var fieldLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: detailTextSize)
        return label
    }()
    
    public var siteAdminText: String = "" {
        didSet {
            siteAdminLabel.text = siteAdminText
            
        }
    }
    
    public var isSiteAdmin: Bool = false {
        didSet {
            siteAdminLabel.isHidden = !isSiteAdmin
        }
    }
    
    private lazy var siteAdminLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        return siteAdminStyling(label)
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
        _ = rightStackView
        selectionStyle = .none
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        siteAdminLabel.roundCorner(radius: siteAdminLabel.bounds.height/2.0)
    }
    
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
}


//////////////////////////
public class DetailFieldCell: UITableViewCell {
    private let standardSpace: CGFloat = 8.0
    
    private let iconDetailLabelSpace: CGFloat = 24.0
    
    private let iconSize: CGFloat = 30.0
    
    private let detailTextSize: CGFloat = 18.0
    
    private let fieldLabelHeight: CGFloat = 50.0
    
    public var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }
    
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
            fieldLabel.text = text
        }
    }
    
    private lazy var fieldLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: iconDetailLabelSpace),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardSpace),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardSpace),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardSpace),
            label.heightAnchor.constraint(equalToConstant: fieldLabelHeight),
            label.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
        
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: detailTextSize)
        return label
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
        _ = fieldLabel
        selectionStyle = .none
    }
    
}
