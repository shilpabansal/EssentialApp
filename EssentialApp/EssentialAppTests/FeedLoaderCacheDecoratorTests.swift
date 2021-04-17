//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 17/04/21.
//

import XCTest
import EssentialFeed
import Foundation

protocol FeedCache {
    typealias SaveResult = Swift.Result<Void, Error>
    func saveFeedInCache(feeds: [FeedImage], timestamp: Date, completion: @escaping (SaveResult) -> Void)
}

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
        decoratee.load {(result) in
           completion(result)
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTeseCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut: sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        expect(sut: sut, toCompleteWith: .failure(anyNSError()))
    }
    
    private class CacheSpy: FeedCache {
        func saveFeedInCache(feeds: [FeedImage], timestamp: Date, completion: @escaping (SaveResult) -> Void) {
            
        }
    }
    
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
