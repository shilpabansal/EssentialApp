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
        
        assert(snapshot: sut.snapshot(), named: "EMPTY_Feed")
    }
    
    func test_emptyFeedWithContent() {
        let sut =  makeSUT ()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT_light")
    }
    
    func test_feedWithError() {
        let sut =  makeSUT ()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ErrorMessage")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut =  makeSUT ()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    //MARK: - Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedViewController = storyBoard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedViewController.loadViewIfNeeded()
        return feedViewController
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Canon street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Bridgton SeaFront",
                image: nil
            )
        ]
    }
    
    private func assert(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        
        let snapshotURL = makeSnapshotURL(named: named, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG Data from snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
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
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func record(snapshot: UIImage, fileName: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        
        let snapshotURL = makeSnapshotURL(named: fileName, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
           try snapshotData?.write(to: snapshotURL)
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

    init(description: String?,
         location: String,
         image: UIImage?) {
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
