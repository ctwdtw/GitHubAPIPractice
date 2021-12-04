//
//  DetailFieldCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/27.
//

import UIKit

public class DetailFieldCell: UITableViewCell {
    public var icon: UIImage? {
        set {
            iconImageView.image = newValue
        }
        
        get {
            iconImageView.image
        }
    }
    
    public var detailText: String? {
        set {
            rightView.text = newValue
        }
        
        get {
            rightView.text
        }
    }
    
    public var textColor: UIColor {
        set {
            rightView.textColor = newValue
        }
        
        get {
            rightView.textColor
        }
    }
    
    private let iconImageView = UIImageView()
    
    private let rightView = RightLabelView()
    
    private lazy var layout: LeftRightLayout = {
        LeftRightLayout(leftView: iconImageView, rightView: rightView)
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

private class RightLabelView: UIView {
    private let standardSpace: CGFloat = 8.0
    
    var text: String? {
        set {
            label.text = newValue
        }
        
        get {
            label.text
        }
    }
    
    var textColor: UIColor {
        set {
            label.textColor = newValue
        }
        
        get {
            label.textColor
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
