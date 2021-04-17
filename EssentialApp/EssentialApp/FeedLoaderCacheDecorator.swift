//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Shilpa Bansal on 17/04/21.
//

import EssentialFeed

public class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load {[weak self] (result) in
            if let feeds = try? result.get() {
                self?.cache.saveFeedInCache(feeds: feeds, timestamp: Date.init(), completion: {_ in})
            }
           
           completion(result)
        }
    }
}
