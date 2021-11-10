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
        let cell: UserProfileCell = binded(tableView.dequeueReusableCell(for: indexPath))
        
        viewModel.loadImageData()
        
        return cell
    }
    
    private func binded(_ cell: UserProfileCell) -> UserProfileCell {
        cell.loginLabel.text = viewModel.loginAccountText
        cell.siteAdminLabel.isHidden = !viewModel.shouldShowSiteAdminLabel
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoadingStart = { [weak cell] in
            cell?.avatarImageView.image = nil
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
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoadImageData()
    }
}
