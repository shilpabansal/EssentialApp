//
//  FeedSnapshotTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 25/04/21.
//
import XCTest
import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeeds() {
        let sut = makeSUT()
        sut.display(emptyFeeds())
        
        record(snapshot: sut.snapshot(), fileName: "EMPTY_Feed")
    }
    
    func test_emptyFeedWithContent() {
        let sut =  makeSUT ()

        sut.display(feedWithContent())

        record(snapshot: sut.snapshot(), fileName: "FEED_WITH_CONTENT_light")
    }
    
    func test_feedWithError() {
        let sut =  makeSUT ()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        record(snapshot: sut.snapshot(), fileName: "FEED_WITH_ErrorMessage")
    }
    
    //MARK: - Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedViewController = storyBoard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedViewController.loadViewIfNeeded()
        return feedViewController
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func emptyFeeds() -> [FeedImageCellController] {
        return []
    }
    
    private func record(snapshot: UIImage, fileName: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG Data from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(fileName).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
           try snapshotData.write(to: snapshotURL)
        }
        catch {
            XCTFail("Failed to record snapshot for test", file: file, line: line)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map {
            let cellController = FeedImageCellController(delegate: $0)
            $0.cellController = cellController
            return cellController
        }
        display(cells)
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { (action) in
            view.layer.render(in: action.cgContext)
        }
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var cellController: FeedImageCellController?
    var viewModel: FeedImageViewModel<UIImage>

    init(description: String,
         location: String,
         image: UIImage) {
        viewModel = FeedImageViewModel<UIImage>(location: location,
                                                description: description,
                                                image: image,
                                                isLoading: false,
                                                showRetry: false)
    }
    
    func didRequestImage() {
        cellController?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
}
