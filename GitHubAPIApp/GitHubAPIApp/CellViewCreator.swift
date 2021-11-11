//
//  CellViewCreator.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/11.
//

import UIKit

protocol CellViewCreator {
    func view(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}
