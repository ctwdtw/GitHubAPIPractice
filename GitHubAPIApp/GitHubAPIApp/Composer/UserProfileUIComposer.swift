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
    public static func make(
        userProfileLoaderFactory: @escaping () -> UserProfileLoader,
        avatarImageDataLoader: ImageDataLoader
    ) -> ListViewController {
        let refreshViewModel = RefreshViewModel()
        
        let profileViewModelAdapter = UserProfileLoaderViewModelAdapter(
            loaderFactory: userProfileLoaderFactory,
            viewModel: refreshViewModel,
            imageLoader: avatarImageDataLoader
        )
        
        refreshViewModel.loadAction = profileViewModelAdapter.load
        
        let refresher = RefreshController(viewModel: refreshViewModel)
        
        let userProfileController = ListViewController(refreshController: refresher)
        
        refreshViewModel.onRefreshed = { [weak userProfileController] tableModel in
            userProfileController?.display(tableModel)
        }
        
        userProfileController.prototypeCellInstances = [UserProfileCell()]
        
        return userProfileController
    }
}
