//
//  WeakRefVirtualProxy.swift
//  NetworkModularization
//
//  Created by Shilpa Bansal on 28/03/21.
//
import EssentialFeed
final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ loadingViewModel: FeedLoadingViewModel) {
        object?.display(loadingViewModel)
    }
}
