//
//  UserProfileCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit
import GitHubAPI

class UserProfileCellController: NSObject, UITableViewDataSourcePrefetching, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.dummyNumberOfSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = binded(tableView.dequeueReusableCell(for: indexPath))
        
        viewModel.loadImageData()
        
        return cell!
    }
    
    private let viewModel: UserProfileViewModel<UIImage>
    
    private var cell: UserProfileCell?
    
    init(viewModel: UserProfileViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    private func binded(_ cell: UserProfileCell) -> UserProfileCell {
        cell.loginLabel.text = viewModel.loginAccountText
        cell.siteAdminLabel.isHidden = !viewModel.shouldShowSiteAdminLabel
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoadingStart = { [weak self] in
            guard let cell = self?.cell else { return }
            
            cell.avatarImageView.image = nil
            cell.isLoadingImage = true
            cell.retryButton.isHidden = true
        }
        
        viewModel.onImageLoadingSuccess = { [weak self] image in
            guard let cell = self?.cell else { return }
            
            cell.avatarImageView.image = image
            cell.isLoadingImage = false
            
        }
        
        viewModel.onImageLoadingFailure = { [weak self] _ in
            guard let cell = self?.cell else { return }
            
            cell.isLoadingImage = false
            cell.retryButton.isHidden = false
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
