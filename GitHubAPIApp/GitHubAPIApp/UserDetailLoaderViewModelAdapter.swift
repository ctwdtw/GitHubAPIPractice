//
//  UserDetailLoaderViewModelAdapter.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import UIKit
import GitHubAPI

class UserDetailLoaderViewModelAdapter {
    
    private let loaderFactory: () -> UserDetailLoader
    
    private var loader: UserDetailLoader?
    
    private unowned let viewModel: RefreshViewModel
    
    private let imageLoader: ImageDataLoader
    
    init(loaderFactory: @escaping () -> UserDetailLoader, viewModel: RefreshViewModel, imageLoader: ImageDataLoader) {
        self.loaderFactory = loaderFactory
        self.viewModel = viewModel
        self.imageLoader = imageLoader
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
    
    private func cellControllers(_ resource: UserDetailLoader.Resource) -> ListViewController.TableModel {
        let controllers: [CellController] = [
            avatar(from: resource),
            siteAdmin(from: resource),
            location(from: resource),
            blog(from: resource)]
            .compactMap {$0}
            .map (CellController.init(dataSource:))
        
        return [controllers]
    }
    
    private func avatar(from resource: UserDetailLoader.Resource) -> UITableViewDataSource {
        AvatarCellController(
            viewModel: AvatarViewModel(
                model: resource,
                imageLoader: imageLoader,
                imageMapping: { data in
                    if let image = UIImage(data: data) {
                        return image
                    } else {
                        throw ImageDecodingError()
                    }
                }))
    }
    
    private func siteAdmin(from resource: UserDetailLoader.Resource) -> UITableViewDataSource {
        SiteAdminCellController(viewModel: SiteAdminViewModel(model: resource))
    }
    
    private func location(from resource: UserDetailLoader.Resource) -> UITableViewDataSource? {
        if let _ = resource.location {
            return LocationCellController(viewModel: LocationViewModel(model: resource))
            
        } else {
            return nil
            
        }
    }
    
    private func blog(from resource: UserDetailLoader.Resource) -> UITableViewDataSource? {
        if let _ = resource.blog {
            return BlogCellController(viewModel: BlogViewModel(model: resource))
        
        } else {
            return nil
        
        }
        
    }
    
}
