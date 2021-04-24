//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Shilpa Bansal on 24/04/21.
//

import EssentialFeed
final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    var task: FeedImageDataLoaderTask? = nil
    private let model: FeedImage
    let imageLoader: FeedImageDataLoader
    var imagePresenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestImage() {
        imagePresenter?.didStartLoadingImageData(for: model)
        
        task = imageLoader.loadImageData(from: model.url) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.imagePresenter?.didFinishLoadingImageData(with: data, for: self.model)
            case .failure(let error):
                self.imagePresenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
}
