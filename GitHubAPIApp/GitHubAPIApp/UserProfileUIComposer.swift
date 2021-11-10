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
