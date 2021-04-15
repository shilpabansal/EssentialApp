//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppUITests
//
//  Created by Shilpa Bansal on 14/04/21.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedsOnPrimarySuccess() {
        let primaryFeeds = uniqueFeed()
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .success(primaryFeeds), fallbackResult: .success(fallbackFeeds))
        
        expect(sut: sut, expectedResult: .success(primaryFeeds))
    }
    
    func test_load_deliversFallbackFeedsOnPrimaryFailure() {
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .failure(anyNSError()), fallbackResult: .success(fallbackFeeds))
        
        expect(sut: sut, expectedResult: .success(fallbackFeeds))
    }
    
    func test_load_deliversErrorOnPrimaryAndFallbackFailure() {
        let primaryError = NSError(domain: "Primary Error", code: 1)
        let fallbackError = NSError(domain: "Fallback Error", code: 1)
        
        let sut = makeSUT(primaryesult: .failure(primaryError), fallbackResult: .failure(fallbackError))
        
        expect(sut: sut, expectedResult: .failure(fallbackError))
    }
    
    private func expect(sut: FeedLoader, expectedResult: FeedLoader.Result) {
        let exp = expectation(description: "Wait for API")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeeds), .success(expectedFeeds)):
                XCTAssertEqual(receivedFeeds, expectedFeeds)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError.localizedDescription, expectedError.localizedDescription)
            default:
                XCTFail("Expected \(expectedResult) Received \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(primaryesult: FeedLoader.Result,
                         fallbackResult: FeedLoader.Result,
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoader {
        
        let primaryLoader = LoaderStub(result: primaryesult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallback(primaryLoader: primaryLoader, fallBackLoader: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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

