//
//  UIViewController+PagingData.swift
//  PagingDataControllerExtension
//
//  Created by NGUYEN CHI CONG on 8/11/16.
//  Copyright © 2016 FOLY. All rights reserved.
//

import Foundation
import PagingDataController
import SiFUtilities
import SVPullToRefresh

public typealias PullHandler = ((() -> Swift.Void)?) -> Swift.Void

extension UIScrollView {
    public var nativeRefreshControl: UIRefreshControl? {
        if #available(iOS 10.0, *) {
            return refreshControl
        } else {
            return subviews.filter { (subview) -> Bool in
                subview is UIRefreshControl
            }.first as? UIRefreshControl
        }
    }
}

extension UIViewController: PageDataSourceDelegate {
    @objc open var instantReloadContent: Bool {
        return false
    }
    
    @objc open var pagingScrollView: UIScrollView {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        fatalError("*** No scroll view in managed by \(classForCoder) ***")
    }
    
    // MARK: - Setup layout
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public func setupScrollViewForPaging(pullDownHandler: @escaping PullHandler, pullUpHandler: @escaping PullHandler) {
        setupPullToRefreshView(pullHandler: pullDownHandler)
        setupInfiniteScrollingView(pullHanlder: pullUpHandler)
    }
    
    public func setupPullToRefreshView(pullHandler: @escaping PullHandler) {
        pagingScrollView.addPullToRefresh { [weak self] in
            pullHandler({ [weak self] in
                guard let this = self else { return }
                this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent,
                                                    end: { [weak self] in
                                                        self?.pagingScrollView.pullToRefreshView.stopAnimating()
                })
            })
        }
    }
    
    public func setupInfiniteScrollingView(pullHanlder: @escaping PullHandler) {
        pagingScrollView.addInfiniteScrolling { [weak self] in
            pullHanlder({ [weak self] in
                guard let this = self else { return }
                this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent,
                                                    end: { [weak self] in
                                                        self?.pagingScrollView.infiniteScrollingView.stopAnimating()
                })
            })
        }
    }
    
    // MARK: - Page Data Delegate
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc open func pageDataSourceDidChanged(hasNextPage: Bool, infiniteScrollingShouldChange changed: Bool) {
        guard changed else {
            return
        }
        let delayTime = DispatchTime.now() + 0.25
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            self?.pagingScrollView.showsInfiniteScrolling = hasNextPage
        }
    }
    
    @objc open func startLoading() {
        showLoading()
    }
    
    @objc open func stopLoading() {
        hideLoading()
    }
}

@objc public enum PagingFirstLoadStyle: Int {
    case none
    case autoTrigger
    case progressHUD // Heads-up Display
}

extension PagingControllerProtocol where Self: UIViewController {
    public func setupForPagingDataSource() {
        dataSource.settings = PageDataSettings(pageSize: provider.pageSize)
        dataSource.delegate = self
    }
    
    public func setupForPullDownToRefresh(nativeControl: Bool = false) {
        if nativeControl {
            let refreshControl = UIRefreshControl(actionHandler: { [weak self] control in
                self?.loadFirstPageWithCompletion({ [weak self] in
                    guard let this = self else { return }
                    this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent,
                                                        end: {
                                                            control.endRefreshing()
                    })
                })
            })
            
            if #available(iOS 10.0, *) {
                pagingScrollView.refreshControl = refreshControl
            } else {
                pagingScrollView.addSubview(refreshControl)
            }
        } else {
            pagingScrollView.addPullToRefresh { [weak self] in
                self?.loadFirstPageWithCompletion({ [weak self] in
                    guard let this = self else { return }
                    this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent,
                                                        end: { [weak self] in
                                                            self?.pagingScrollView.pullToRefreshView.stopAnimating()
                    })
                })
            }
        }
    }
    
    public func setupForPullUpToLoadMore() {
        pagingScrollView.addInfiniteScrolling { [weak self] in
            self?.loadNextPageWithCompletion({ [weak self] in
                guard let this = self else { return }
                this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent,
                                                    end: { [weak self] in
                                                        self?.pagingScrollView.infiniteScrollingView.stopAnimating()
                })
            })
        }
        
        pagingScrollView.showsInfiniteScrolling = dataSource.hasMore
    }
    
    public func setupForPaging(nativeRefreshControl: Bool = false, firstLoadstyle: PagingFirstLoadStyle = .progressHUD) {
        setupForPagingDataSource()
        setupForPullDownToRefresh(nativeControl: nativeRefreshControl)
        setupForPullUpToLoadMore()
        
        switch firstLoadstyle {
        case .autoTrigger:
            triggerPull(nativeRefreshControl: nativeRefreshControl)
        case .progressHUD:
            loadDataFirstPage()
        default:
            break
        }
    }
    
    public func triggerPull(nativeRefreshControl: Bool = false) {
        if nativeRefreshControl {
            if let control = pagingScrollView.nativeRefreshControl {
                control.beginRefreshing()
                loadFirstPageWithCompletion({ [weak self] in
                    guard let this = self else { return }
                    this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent, end: control.endRefreshing)
                })
            } else {
                print("*** Refresh control not found ***")
            }
        } else {
            pagingScrollView.triggerPullToRefresh()
        }
    }
    
    public func loadDataFirstPage() {
        startLoading()
        loadFirstPageWithCompletion({ [weak self] in
            guard let this = self else { return }
            this.pagingScrollView.reloadContent(instantReloadContent: this.instantReloadContent, end: this.stopLoading)
        })
    }
}
