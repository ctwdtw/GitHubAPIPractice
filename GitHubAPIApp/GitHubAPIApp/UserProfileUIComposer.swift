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
        let refreshViewModel = UserProfileRefreshViewModel(loader: userProfileLoader)
        
        let refresher = UserProfileRefreshController(viewModel: refreshViewModel)
        
        let userProfileController = UserProfileViewController(refreshController: refresher)
        
        refreshViewModel.onRefreshed = adaptUserProfileToCellController(forwardingTo: userProfileController, imageLoader: avatarImageDataLoader)
        
        return userProfileController
    }
    
    struct ImageDecodingError: Error {}
    
    private static func adaptUserProfileToCellController(forwardingTo controller: UserProfileViewController, imageLoader: ImageDataLoader) -> ([UserProfile]) -> Void {
        return { [weak controller] userProfiles in
            controller?.cellControllers = userProfiles.map { profile in
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
}
