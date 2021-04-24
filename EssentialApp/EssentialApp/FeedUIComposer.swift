//
//  FeedUIComposer.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 15/03/21.
//

import Foundation
import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() { }
    public static func composeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorater(decoratee: feedLoader))
        
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter)
        let presenter = FeedPresenter(view: FeedViewAdapter(feedController: feedController, imageLoader: MainQueueDispatchDecorater(decoratee: imageLoader)),
                                      loadingView: WeakRefVirtualProxy(object: feedController),
                                      errorView: WeakRefVirtualProxy(object: feedController))
        presentationAdapter.presenter = presenter
        return feedController
    }
    
    //[FeedImage] -> Adapt -> [FeedImageCellController]
    static func adaptFeedImageToFeedImageCellController(feeds: [FeedImage], imageLoader: FeedImageDataLoader) -> [FeedImageCellController] {
       return feeds.map({
        let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: $0, imageLoader: imageLoader)
        let view = FeedImageCellController(delegate: adapter)
        
        adapter.imagePresenter = FeedImagePresenter(imageTransformer: UIImage.init,
                                                    view: WeakRefVirtualProxy(object: view))
        return view
        })
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedLoaderPresentationAdapter) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedController = storyBoard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        
        return feedController
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    typealias Image = UIImage
    
    func display(_ viewModel: FeedImageViewModel<Image>) {
        object?.display(viewModel)
    }
}
