//
//  FeedUIIntegrationTestsLoaderSpy.swift
//  EssentialFeedTests
//
//  Created by Shilpa Bansal on 24/04/21.
//

import EssentialFeed
class LoaderSpy: FeedLoader, FeedImageDataLoader {
    var feedRequests = [((FeedLoader.Result) -> Void)]()
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feeds: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feeds))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "Error", code: 0)
        feedRequests[index](.failure(error))
    }
    
    //MARK: - FeedImageDataLoader
    private(set) var cancelledImageURLs = [URL]()
    var imageRequests = [(url: URL, completion: ((FeedImageDataLoader.Result) -> Void))]()
    
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        
        return TaskSpy {[weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "Error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
    
    public struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
}
