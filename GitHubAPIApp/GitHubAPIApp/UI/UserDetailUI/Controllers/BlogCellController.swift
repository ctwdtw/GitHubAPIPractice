//
//  BlogCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import UIKit

class BlogCellController: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = binded(tableView.dequeueReusableCell(for: indexPath))
        return cell!
    }
    
    private let viewModel: BlogViewModel
    
    private var cell: DetailFieldCell?
    
    init(viewModel: BlogViewModel) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: DetailFieldCell) -> DetailFieldCell {
        cell.icon = UIImage(systemName: "link")
        cell.detailText = viewModel.siteAddress
        cell.textColor = .link
        
        return cell
    }
}
