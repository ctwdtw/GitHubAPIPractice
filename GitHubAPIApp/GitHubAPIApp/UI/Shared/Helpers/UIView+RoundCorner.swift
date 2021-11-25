//
//  UIView+RoundCorner.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit

extension UIView {
    func roundCorner(radius cornerRadius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
