//
//  LoadMoreCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
public class LoadMoreCell: UITableViewCell {
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        return view
    }()
    
    public var isLoading: Bool {
        get {
            loadingIndicator.isAnimating
        }
        
        set {
            if newValue == true {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }
    
    lazy private(set) var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ])
        
        label.textAlignment = .center
        label.numberOfLines = 0
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
        _ = loadingIndicator
    }
}

