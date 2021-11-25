//
//  UserDetailUIComposer.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import Foundation
import GitHubAPI
import UIKit

public class UserDetailUIComposer {
    private init() {}
    public static func make(
        userDetailLoaderFactory: @escaping () -> UserDetailLoader,
        avatarImageDataLoader: ImageDataLoader
    ) -> ListViewController {
        let refreshViewModel = RefreshViewModel()
        
        let detailViewModelAdapter = UserDetailLoaderViewModelAdapter(
            loaderFactory: userDetailLoaderFactory,
            viewModel: refreshViewModel,
            imageLoader: avatarImageDataLoader
        )
        
        refreshViewModel.loadAction = detailViewModelAdapter.load
        
        let refresher = RefreshController(viewModel: refreshViewModel)
        
        let userProfileController = ListViewController(refreshController: refresher)
        
        refreshViewModel.onRefreshed = { [weak userProfileController] tableModel in
            userProfileController?.display(tableModel)
        }
        
        userProfileController.prototypeCellInstances = [UserProfileCell()]
        
        return userProfileController
    }
}
