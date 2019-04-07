//
//  PagingControllerProtocolExtension.swift
//  PagingDataControllerExtension
//
//  Created by NGUYEN CHI CONG on 3/16/19.
//

import Foundation
import PagingDataController
import UIKit

@objc public enum PagingFirstLoadingStyle: Int {
    case none
    case autoTrigger
    case progressHUD // Heads-up Display
}

extension PagingControllerConfigurable where Self: PagingControllerProtocol {
    public func setupForPagingDataSource() {
        dataSource.settings = PageDataSettings(pageSize: provider.pageSize)
        if let _dataSourceDelegate = pagingView as? PageDataSourceDelegate {
            dataSource.delegate = _dataSourceDelegate
        }
    }
    
    public func setupForPullDownToRefresh(nativeControl: Bool = false) {
        if nativeControl {
            let refreshControl = UIRefreshControl { [weak self] control in
                self?.loadFirstPageWithCompletion { [weak self] in
                    guard let self = self else { return }
                    self.pagingScrollView.reloadContent(instantReloadContent: self.instantReloadContent) {
                        control.endRefreshing()
                    }
                }
            }
            
            if #available(iOS 10.0, *) {
                pagingScrollView.refreshControl = refreshControl
            } else {
                pagingScrollView.addSubview(refreshControl)
            }
        } else {
            pagingScrollView.addPullToRefresh { [weak self] in
                self?.loadFirstPageWithCompletion { [weak self] in
                    guard let self = self else { return }
                    self.pagingScrollView.reloadContent(instantReloadContent: self.instantReloadContent) { [weak self] in
                        self?.pagingScrollView.pullToRefreshView.stopAnimating()
                    }
                }
            }
        }
    }
    
    public func setupForPullUpToLoadMore() {
        pagingScrollView.addInfiniteScrolling { [weak self] in
            self?.loadNextPageWithCompletion { [weak self] in
                guard let self = self else { return }
                self.pagingScrollView.reloadContent(instantReloadContent: self.instantReloadContent) { [weak self] in
                    self?.pagingScrollView.infiniteScrollingView.stopAnimating()
                }
            }
        }
        
        pagingScrollView.showsInfiniteScrolling = dataSource.hasMore
    }
    
    public func triggerPull(nativeRefreshControl: Bool = false) {
        if nativeRefreshControl {
            if let control = pagingScrollView.nativeRefreshControl {
                control.beginRefreshing()
                loadFirstPageWithCompletion { [weak self] in
                    guard let self = self else { return }
                    self.pagingScrollView.reloadContent(instantReloadContent: self.instantReloadContent,
                                                        end: control.endRefreshing)
                }
            } else {
                print("*** Refresh control not found ***")
            }
        } else {
            pagingScrollView.triggerPullToRefresh()
        }
    }
    
    public func loadDataFirstPage() {
        startLoading()
        loadFirstPageWithCompletion { [weak self] in
            guard let self = self else { return }
            self.pagingScrollView.reloadContent(instantReloadContent: self.instantReloadContent,
                                                end: self.stopLoading)
        }
    }
    
    public func setupPagingControlling(nativeRefreshControl: Bool = false,
                                       firstLoadingStyle style: PagingFirstLoadingStyle = .progressHUD) {
        setupForPagingDataSource()
        setupForPullDownToRefresh(nativeControl: nativeRefreshControl)
        setupForPullUpToLoadMore()
        
        switch style {
        case .autoTrigger:
            triggerPull(nativeRefreshControl: nativeRefreshControl)
        case .progressHUD:
            loadDataFirstPage()
        default:
            break
        }
    }
}

extension PagingControllerConfigurable where Self: PagingControllerProtocol {
    public func setupForPaging() {
        setupPagingControlling(nativeRefreshControl: true)
    }
}

extension PagingControllerProtocol where Self.PagingProvider == Self {
    public var provider: PagingProvider {
        return self
    }
}
