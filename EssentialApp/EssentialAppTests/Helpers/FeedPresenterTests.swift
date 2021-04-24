//
//  FeedPresenterTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 28/03/21.
//

import XCTest
import EssentialFeed

class FeedLoadingViewTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (view, _) = makeSUT()
        
        XCTAssert(view.messages.isEmpty)
    }
    
    func test_init_displayNoErrorMessageAndLoadingView() {
        let (view, sut) = makeSUT()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: nil),
                                       .display(isLoading: true)])
    }
    
    func test_init_displayLoadingFeedsOnSuccessfulLoad() {
        let (view, sut) = makeSUT()
        let feeds = uniqueImageFeeds().model
        
        sut.didFinishLoadingFeeds(with: feeds)
        XCTAssertEqual(view.messages, [.display(feeds: feeds),
                                       .display(isLoading: false)])
    }
    
    func test_init_displayErrorOnLoadFailed() {
        let (view, sut) = makeSUT()
        
        sut.didFinishLoadingWithError(with: anyNSError())
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
                                       .display(isLoading: false)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (ViewSpy, FeedPresenter) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view,
                                loadingView: view,
                                errorView: view)
        trackMemoryLeak(view, file:file, line: line)
        trackMemoryLeak(sut, file:file, line: line)
        return (view, sut)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
    enum Message: Equatable {
        case display(errorMessage: String?)
        case display(isLoading: Bool)
        case display(feeds: [FeedImage])
    }
    
    private(set) var messages = [Message]()
    
    func display(_ viewModel: FeedErrorViewModel) {
        messages.append(.display(errorMessage: viewModel.message))
    }
    
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        messages.append(.display(isLoading: loadingViewModel.isLoading))
    }
    
    func display(_ viewModel: FeedViewModel) {
        messages.append(.display(feeds: viewModel.feeds))
    }
}
