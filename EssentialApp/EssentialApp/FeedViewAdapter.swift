//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by Shilpa Bansal on 24/04/21.
//

import UIKit
import EssentialFeed


final class FeedViewAdapter: FeedView {
    func display(_ viewModel: FeedViewModel) {
        feedController?.display(viewModel.feeds.map({
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: $0, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.imagePresenter = FeedImagePresenter(
                    imageTransformer: UIImage.init,
                view: WeakRefVirtualProxy(object: view))
            return view
         }))
    }
    
    let imageLoader: FeedImageDataLoader
    weak var feedController: FeedViewController?
    
    init(feedController: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.feedController = feedController
        self.imageLoader = imageLoader
    }
}
