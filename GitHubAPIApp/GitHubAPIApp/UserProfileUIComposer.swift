//
//  UserProfileUIComposer.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/8.
//

import Foundation
import GitHubAPI
import UIKit

public class UserProfileUIComposer {
    private init() {}
    
    public static func make(userProfileLoader: UserProfileLoader, avatarImageDataLoader: ImageDataLoader) -> UserProfileViewController {
        let refreshViewModel = UserProfileRefreshViewModel()
        
        let profileViewModelAdapter = UserProfileLoaderViewModelAdapter(loader: userProfileLoader, viewModel: refreshViewModel, imageLoader: avatarImageDataLoader)
        
        let refresher = UserProfileRefreshController(viewModel: refreshViewModel, loadAction: profileViewModelAdapter.load)
        
        let userProfileController = UserProfileViewController(refreshController: refresher)
        
        refreshViewModel.onRefreshed = { [weak userProfileController] cellControllers in
            userProfileController?.cellControllers = cellControllers
        }
        
        return userProfileController
    }
}

private class UserProfileLoaderViewModelAdapter {
    private let loader: UserProfileLoader
    
    private let viewModel: UserProfileRefreshViewModel
    
    private let imageLoader: ImageDataLoader
    
    init(loader: UserProfileLoader, viewModel: UserProfileRefreshViewModel, imageLoader: ImageDataLoader) {
        self.loader = loader
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
    
    struct ImageDecodingError: Error {}

    func load() {
        viewModel.onStartLoading?()
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            if let resource = try? result.get() {
                let controllers = self.cellControllers(resource)
                self.viewModel.onRefreshed?(controllers)
            }
            
            self.viewModel.onFinishLoading?()
        }
    }
    
    private func cellControllers(_ resource: UserProfileURLPackage) -> [UserProfileCellController] {
        resource.userProfiles.map { profile in
            UserProfileCellController(viewModel: UserProfileViewModel(model: profile, imageLoader: imageLoader, imageMapping: { data in
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw ImageDecodingError()
                }
            }))
        }
    }
}
