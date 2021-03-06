//
//  UserProfileLoaderViewModelAdapter.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/11.
//

import UIKit
import GitHubAPI

class UserProfileLoaderViewModelAdapter {
    
    private let loaderFactory: () -> UserProfileLoader
    
    private var loader: UserProfileLoader?
    
    private unowned let viewModel: RefreshViewModel
    
    private let imageLoader: ImageDataLoader
    
    private let onSelectProfile: (UserProfile) -> Void
    
    init(loaderFactory: @escaping () -> UserProfileLoader,
         viewModel: RefreshViewModel,
         imageLoader: ImageDataLoader,
         onSelectProfile: @escaping (UserProfile) -> Void
    ) {
        self.loaderFactory = loaderFactory
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        self.onSelectProfile = onSelectProfile
    }
    
    struct ImageDecodingError: Error {}

    func load() {
        loader = loaderFactory()
        viewModel.onStartLoading?()
        loader?.load { [weak self] result in
            guard let self = self else { return }
            
            if let resource = try? result.get() {
                let controllers = self.cellControllers(resource)
                self.viewModel.onRefreshed?(controllers)
            }
            
            self.viewModel.onFinishLoading?()
        }
    }
    
    private func cellControllers(_ resource: UserProfileLoader.Resource) -> ListViewController.TableModel {
        var tableModel: ListViewController.TableModel = []
        
        let profileControllers = resource.userProfiles.map { profile in
            UserProfileCellController(
                viewModel: UserProfileViewModel(model: profile, imageLoader: imageLoader, imageMapping: { data in
                if let image = UIImage(data: data) {
                    return image
                } else {
                    throw ImageDecodingError()
                }}),
                selection: { [onSelectProfile] in
                    onSelectProfile(profile)
                }
            )
        }.map(CellController.init(dataSource:))
        
        tableModel.append(profileControllers)
        
        if let loadMore = resource.loadMore {
            let loadMoreViewModel = LoadMoreViewModel(loadMore)
            loadMoreViewModel.onLoadMore = { [weak self] resource in
                guard let self = self else { return }
                let controllers = self.cellControllers(resource)
                self.viewModel.onRefreshed?(controllers)
            }
            
            tableModel.append([
                CellController(dataSource: LoadMoreCellController(viewModel: loadMoreViewModel))
            ])
        }
        
        return tableModel
    }
}

