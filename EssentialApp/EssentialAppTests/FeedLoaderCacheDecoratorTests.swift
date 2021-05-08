//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 17/04/21.
//

import XCTest
import EssentialFeed
import EssentialApp
import EssentialFeedCache

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTeseCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeeds()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut: sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        expect(sut: sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeeds()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load {_ in }
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

        sut.load {_ in }
        XCTAssert(cache.messages.isEmpty, "Expected to cache loaded feed on success")
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        enum Message: Equatable {
            case save([FeedImage])
        }

        func saveFeedInCache(feeds: [FeedImage], timestamp: Date, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feeds))
            completion(.success(()))
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
