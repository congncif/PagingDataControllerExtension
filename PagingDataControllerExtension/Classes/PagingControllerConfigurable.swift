//
//  PagingControllerConfigurable.swift
//  PagingDataControllerExtension
//
//  Created by NGUYEN CHI CONG on 3/16/19.
//

import Foundation
import UIKit

public protocol PagingControllerConfigurable: AnyObject {
    var pagingView: PagingControllerViewable { get }
}

extension PagingControllerConfigurable {
    public var instantReloadContent: Bool {
        return pagingView.instantReloadContent
    }

    public var pagingScrollView: UIScrollView {
        return pagingView.pagingScrollView
    }

    public func startLoading() {
        pagingView.startLoading()
    }

    public func stopLoading() {
        pagingView.stopLoading()
    }
}

extension PagingControllerConfigurable where Self: PagingControllerViewable {
    public var pagingView: PagingControllerViewable { return self }
}
