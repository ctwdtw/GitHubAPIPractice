//
//  AvatarViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/25.
//

import Foundation
import GitHubAPI

class AvatarViewModel<Image> {
    private let model: UserDetail
    
    private let imageLoader: ImageDataLoader
    
    private let imageMapping: (Data) throws -> Image
    
    private var task: ImageDataTask?
    
    var onImageLoadingStart: (() -> Void)?
    
    var onImageLoadingSuccess: ((Image) -> Void)?
    
    var onImageLoadingFailure: ((Error) -> Void)?
    
    init(model: UserDetail, imageLoader: ImageDataLoader, imageMapping: @escaping (Data) throws -> Image) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageMapping = imageMapping
    }
    
    var name: String? {
        return model.name
    }
    
    var biography: String? {
        return model.biography
    }
    
    func loadImageData() {
        onImageLoadingStart?()
        task = imageLoader.load(url: model.avatarUrl) { [weak self] result in
            guard let self = self else { return }
            
            do {
                let imageData = try result.get()
                let image = try self.imageMapping(imageData)
                self.onImageLoadingSuccess?(image)
                
            } catch {
                self.onImageLoadingFailure?(error)
                
            }
        }
    }
    
    func cancelLoadImageData() {
        task?.cancel()
        task = nil
    }
}
