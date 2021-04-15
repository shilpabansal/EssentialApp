//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Shilpa Bansal on 15/04/21.
//

import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    var primary: FeedImageDataLoader
    var fallback: FeedImageDataLoader
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapper = primary.loadImageData(from: url, completion: {[weak self] (result) in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        })
        
        return task
    }
}
