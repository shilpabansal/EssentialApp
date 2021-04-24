//
//  FeedImagePresenterTests.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 28/03/21.
//

import XCTest
import EssentialFeed
import UIKit

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (view, _) = makeSUT()
        
        XCTAssert(view.imageModel == nil)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (view, sut) = makeSUT()
        let image = uniqueFeed()

        sut.didStartLoadingImageData(for: image)

        XCTAssertEqual(view.imageModel?.location, image.location)
        XCTAssertEqual(view.imageModel?.description, image.description)
        XCTAssertEqual(view.imageModel?.showRetry, false)
        XCTAssertEqual(view.imageModel?.isLoading, true)
        XCTAssertNil(view.imageModel?.image)
    }
    
    private func makeSUT(_ imageTransformer: @escaping ((Data) -> AnyImage?) = { _  in  nil },
                         file: StaticString = #file, line: UInt = #line) -> (ImageViewSpy, FeedImagePresenter<ImageViewSpy, AnyImage>) {
        typealias Image = AnyImage
        
        let view = ImageViewSpy()
        let sut = FeedImagePresenter(imageTransformer: imageTransformer,
                                     view: view)
        trackMemoryLeak(view, file:file, line: line)
        trackMemoryLeak(sut, file:file, line: line)
        return (view, sut)
    }
   
    private struct AnyImage: Equatable {}

    private class ImageViewSpy: FeedImageView {
        typealias Image = AnyImage
        
        private(set) var imageModel: FeedImageViewModel<AnyImage>? = nil
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            imageModel = viewModel
        }
    }
}
