//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Shilpa Bansal on 24/04/21.
//

import Foundation
import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load {[weak self] (result) in
            switch result {
            case .success(let feeds):
                self?.presenter?.didFinishLoadingFeeds(with: feeds)
            case .failure(let error):
                self?.presenter?.didFinishLoadingWithError(with: error)
            }
        }
    }
}
