//
//  DetailCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/28.
//

import UIKit

class LocationCellController: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = binded(tableView.dequeueReusableCell(for: indexPath))
        return cell!
    }
    
    private let viewModel: LocationViewModel
    
    private var cell: DetailFieldCell?
    
    init(viewModel: LocationViewModel) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: DetailFieldCell) -> DetailFieldCell {
        cell.icon = UIImage(systemName: "mappin.and.ellipse")
        cell.detailText = viewModel.location
        
        return cell
    }
}
