//
//  MainQueueDispatchDecorater.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 26/03/21.
//

import EssentialFeed
internal class MainQueueDispatchDecorater<T> {
    let decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: completion)
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorater: FeedLoader where T == FeedLoader {
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load {[weak self] (result) in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorater: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
