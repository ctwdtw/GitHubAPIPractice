//
//  LeftRightLayout.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/27.
//

import UIKit

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
