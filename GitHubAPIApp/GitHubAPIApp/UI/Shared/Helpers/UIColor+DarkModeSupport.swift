//
//  UIColor+DarkModeSupport.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/16.
//

import UIKit

public extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return  light }
        return UIColor(dynamicProvider: {  trait in
            switch trait.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        })
    }
} 
