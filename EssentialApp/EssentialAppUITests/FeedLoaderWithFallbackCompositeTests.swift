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

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedsOnPrimarySuccess() {
        let primaryFeeds = uniqueFeed()
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .success(primaryFeeds), fallbackResult: .success(fallbackFeeds))
        
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
    
    func test_load_deliversFallbackFeedsOnPrimaryFailure() {
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .failure(anyNSError()), fallbackResult: .success(fallbackFeeds))
        
        let exp = expectation(description: "Wait for API")
        
        sut.load { result in
            switch result {
            case .success(let receivedFeeds):
                XCTAssertEqual(receivedFeeds, fallbackFeeds)
            case .failure:
                XCTFail("Expected feeds \(fallbackFeeds) Received \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Test Error", code: 1)
    }
    
    private func makeSUT(primaryesult: FeedLoader.Result,
                         fallbackResult: FeedLoader.Result,
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoader {
        
        let primaryLoader = LoaderStub(result: primaryesult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallback(primaryLoader: primaryLoader, fallBackLoader: fallbackLoader)
        trackMemoryLeak(primaryLoader, file: file, line: line)
        trackMemoryLeak(fallbackLoader, file: file, line: line)
        trackMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    private func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, potential memory leak", file: file, line: line)
        }
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

