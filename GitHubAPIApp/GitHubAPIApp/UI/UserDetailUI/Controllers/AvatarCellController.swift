//
//  AvatarCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit
import GitHubAPI

class AvatarCellController: NSObject, UITableViewDataSourcePrefetching, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = binded(tableView.dequeueReusableCell(for: indexPath))
        cell?.accessibilityIdentifier = "avatar-cell"
        viewModel.loadImageData()
        
        return cell!
    }
    
    private let viewModel: AvatarViewModel<UIImage>
    
    private var cell: AvatarCell?
    
    init(viewModel: AvatarViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: AvatarCell) -> AvatarCell {
        cell.name = viewModel.name
        cell.biography = viewModel.biography
        
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoadingStart = { [weak self] in
            guard let cell = self?.cell else { return }
            
            cell.avatarImage = nil
            cell.isLoadingImage = true
            cell.shouldRetry = false
        }
        
        viewModel.onImageLoadingSuccess = { [weak self] image in
            guard let cell = self?.cell else { return }
            
            cell.avatarImage = image
            cell.isLoadingImage = false
            
        }
        
        viewModel.onImageLoadingFailure = { [weak self] _ in
            guard let cell = self?.cell else { return }
            
            cell.isLoadingImage = false
            cell.shouldRetry = true
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        preload()
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    private func preload() {
        viewModel.loadImageData()
    }
    
    private func cancelLoad() {
        releaseCellForReuse()
        viewModel.cancelLoadImageData()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
