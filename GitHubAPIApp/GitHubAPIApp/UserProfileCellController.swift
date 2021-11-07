//
//  UserProfileCellController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/7.
//

import UIKit
import GitHubAPI

class UserProfileCellController: NSObject {
    private let item: UserProfile
    private let imageLoader: ImageDataLoader
    private var task: ImageDataTask?
    
    init(item: UserProfile, imageLoader: ImageDataLoader) {
        self.item = item
        self.imageLoader = imageLoader
    }
    
    func view(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: UserProfileCell = tableView.dequeueReusableCell(for: indexPath)
        cell.loginLabel.text = item.login
        cell.siteAdminLabel.isHidden = !item.siteAdmin
        cell.avatarImageView.image = nil
        
        let url = item.avatarUrl
        let loadAvatarImage = { [weak self, weak cell] in
            guard let self = self else { return }
            cell?.imageLoadingIndicator.startAnimating()
            cell?.retryButton.isHidden = true
            
            self.task = self.imageLoader.load(url: url) { [weak cell] result in
                cell?.imageLoadingIndicator.stopAnimating()
                if let imageData = try? result.get(), let image = UIImage(data: imageData) {
                    cell?.avatarImageView.image = image
                } else {
                    cell?.retryButton.isHidden = false
                }
            }
        }
        
        cell.onRetry = loadAvatarImage
        
        loadAvatarImage()

        return cell
    }
        
    func load() {
        task = imageLoader.load(url: item.avatarUrl) { _ in }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
}
