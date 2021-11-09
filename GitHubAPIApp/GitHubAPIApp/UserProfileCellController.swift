//
//  UserProfileCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit
import GitHubAPI

class UserProfileCellController: NSObject {
    private let viewModel: UserProfileViewModel<UIImage>
    
    init(viewModel: UserProfileViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: UserProfileCell = tableView.dequeueReusableCell(for: indexPath)
        cell.loginLabel.text = viewModel.loginAccountText
        cell.siteAdminLabel.isHidden = !viewModel.shouldShowSiteAdminLabel
        cell.avatarImageView.image = nil
        
        viewModel.onImageLoadingStart = { [weak cell] in
            cell?.imageLoadingIndicator.startAnimating()
            cell?.retryButton.isHidden = true
        }
        
        viewModel.onImageLoadingSuccess = { [weak cell] image in
            cell?.imageLoadingIndicator.stopAnimating()
            cell?.avatarImageView.image = image
        }
        
        viewModel.onImageLoadingFailure = { [weak cell] _ in
            cell?.imageLoadingIndicator.stopAnimating()
            cell?.retryButton.isHidden = false
        }
        
        cell.onRetry = viewModel.loadImageData
        
        viewModel.loadImageData()
        
        return cell
    }
    
    func load() {
        viewModel.loadImageData()
    }
    
    func cancel() {
        viewModel.cancelLoadImageData()
    }
}
