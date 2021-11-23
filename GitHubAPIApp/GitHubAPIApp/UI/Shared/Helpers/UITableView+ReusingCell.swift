//
//  UITableView+ReusingCell.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(type: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
    func registerCell(_ instance: UITableViewCell) {
        register(type(of: instance), forCellReuseIdentifier: String(describing: type(of: instance)))
    }
    
}
