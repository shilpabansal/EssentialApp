//
//  FeedLoaderWithFallback.swift
//  EssentialApp
//
//  Created by Shilpa Bansal on 14/04/21.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private var primaryLoader: FeedLoader
    private var fallBackLoader: FeedLoader
    
    public init(primaryLoader: FeedLoader, fallBackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallBackLoader = fallBackLoader
    }
    
    public func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        primaryLoader.load {[weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallBackLoader.load(completion: completion)
            }
        }
    }
}
