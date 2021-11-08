//
//  UserProfileUIComposer.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/8.
//

import Foundation
import GitHubAPI

public class UserProfileUIComposer {
    private init() {}
    
    public static func make(userProfileLoader: UserProfileLoader, avatarImageDataLoader: ImageDataLoader) -> UserProfileViewController {
        let refresher = UserProfileRefreshController(loader: userProfileLoader)
        
        let userProfileController = UserProfileViewController(refreshController: refresher)
        
        refresher.onRefreshed = adaptUserProfileToCellController(forwardingTo: userProfileController, imageLoader: avatarImageDataLoader)
        
        return userProfileController
    }
    
    private static func adaptUserProfileToCellController(forwardingTo controller: UserProfileViewController, imageLoader: ImageDataLoader) -> ([UserProfile]) -> Void {
        return { [weak controller] userProfiles in
            controller?.cellControllers = userProfiles.map { profile in
                UserProfileCellController(item: profile, imageLoader: imageLoader)
            }
        }
    }
}
