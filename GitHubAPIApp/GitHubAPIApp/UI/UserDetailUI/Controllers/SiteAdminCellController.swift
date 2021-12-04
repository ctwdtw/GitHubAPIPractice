//
//  SiteAdminCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import UIKit

class SiteAdminCellController: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = binded(tableView.dequeueReusableCell(for: indexPath))
        return cell!
    }
    
    private let viewModel: SiteAdminViewModel
    
    private var cell: SiteAdminCell?
    
    init(viewModel: SiteAdminViewModel) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: SiteAdminCell) -> SiteAdminCell {
        cell.icon = UIImage(systemName: "person.fill")
        cell.loginText = viewModel.loginText
        cell.isSiteAdmin = viewModel.isSiteAdmin
        
        return cell
    }
}
