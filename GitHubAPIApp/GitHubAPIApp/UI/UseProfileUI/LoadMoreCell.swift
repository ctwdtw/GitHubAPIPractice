//
//  LoadMoreCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/18.
//

import UIKit
class LoadMoreCell: UITableViewCell {
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        view.startAnimating()
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
        _ = loadingIndicator
    }
}

