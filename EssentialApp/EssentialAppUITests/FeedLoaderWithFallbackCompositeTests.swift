//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppUITests
//
//  Created by Shilpa Bansal on 14/04/21.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallback: FeedLoader {
    var primaryLoader: FeedLoader
    var fallBackLoader: FeedLoader
    init(primaryLoader: FeedLoader, fallBackLoader: FeedLoader) {
        self.primaryLoader = primaryLoader
        self.fallBackLoader = fallBackLoader
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        primaryLoader.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeeds = uniqueFeed()
        let fallbackFeeds = uniqueFeed()
        
        let primaryLoader = LoaderStub(result: .success(primaryFeeds))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeeds))
        
        let sut = FeedLoaderWithFallback(primaryLoader: primaryLoader, fallBackLoader: fallbackLoader)
        
        let exp = expectation(description: "Wait for API")
        
        sut.load { result in
            switch result {
            case .success(let receivedFeeds):
                XCTAssertEqual(receivedFeeds, primaryFeeds)
            case .failure:
                XCTFail("Expected feeds \(primaryFeeds) Received \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderStub: FeedLoader {
        private var result: FeedLoader.Result
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            completion(result)
        }
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)]
    }
}

