//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppUITests
//
//  Created by Shilpa Bansal on 14/04/21.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTeseCase {
    func test_load_deliversPrimaryFeedsOnPrimarySuccess() {
        let primaryFeeds = uniqueFeed()
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .success(primaryFeeds), fallbackResult: .success(fallbackFeeds))
        
        expect(sut: sut, toCompleteWith: .success(primaryFeeds))
    }
    
    func test_load_deliversFallbackFeedsOnPrimaryFailure() {
        let fallbackFeeds = uniqueFeed()
        
        let sut = makeSUT(primaryesult: .failure(anyNSError()), fallbackResult: .success(fallbackFeeds))
        
        expect(sut: sut, toCompleteWith: .success(fallbackFeeds))
    }
    
    func test_load_deliversErrorOnPrimaryAndFallbackFailure() {
        let primaryError = NSError(domain: "Primary Error", code: 1)
        let fallbackError = NSError(domain: "Fallback Error", code: 1)
        
        let sut = makeSUT(primaryesult: .failure(primaryError), fallbackResult: .failure(fallbackError))
        
        expect(sut: sut, toCompleteWith: .failure(fallbackError))
    }
    
    private func makeSUT(primaryesult: FeedLoader.Result,
                         fallbackResult: FeedLoader.Result,
                         file: StaticString = #file,
                         line: UInt = #line) -> FeedLoader {
        
        let primaryLoader = FeedLoaderStub(result: primaryesult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        
        let sut = FeedLoaderWithFallbackComposite(primaryLoader: primaryLoader, fallBackLoader: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

