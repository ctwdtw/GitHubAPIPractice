//
//  UserProfileLoaderViewModelAdapter.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/11.
//

import UIKit
import GitHubAPI

class UserProfileLoaderViewModelAdapter {
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

