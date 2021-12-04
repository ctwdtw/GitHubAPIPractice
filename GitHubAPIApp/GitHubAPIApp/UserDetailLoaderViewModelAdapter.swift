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
        let controllers = [
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
                    })),
            SiteAdminCellController(viewModel: SiteAdminViewModel(model: resource)),
            LocationCellController(viewModel: LocationViewModel(model: resource)),
            BlogCellController(viewModel: BlogViewModel(model: resource))
            
        ].map(CellController.init(dataSource:))
        
        return [controllers]
    }
}
