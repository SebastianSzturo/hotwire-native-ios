import UIKit
import WebKit

public protocol VisitableDelegate: AnyObject {
    func visitableViewWillAppear(_ visitable: Visitable)
    func visitableViewDidAppear(_ visitable: Visitable)
    func visitableViewWillDisappear(_ visitable: Visitable)
    func visitableViewDidDisappear(_ visitable: Visitable)
    func visitableDidRequestReload(_ visitable: Visitable)
    func visitableDidRequestRefresh(_ visitable: Visitable)
}

public protocol Visitable: AnyObject {
    var visitableViewController: UIViewController { get }
    var visitableDelegate: VisitableDelegate? { get set }
    var visitableView: VisitableView { get }
    var initialVisitableURL: URL { get }
    var currentVisitableURL: URL { get }

    func visitableDidRender()
    func showVisitableActivityIndicator()
    func hideVisitableActivityIndicator()

    func visitableDidActivateWebView(_ webView: WKWebView)
    func visitableWillDeactivateWebView()
    func visitableDidDeactivateWebView()
}

extension Visitable {
    public func reloadVisitable() {
        visitableDelegate?.visitableDidRequestReload(self)
    }

    public func showVisitableActivityIndicator() {
        visitableView.showActivityIndicator()
    }

    public func hideVisitableActivityIndicator() {
        visitableView.hideActivityIndicator()
    }

    public func visitableDidActivateWebView(_ webView: WKWebView) {
        // No-op
    }

    public func visitableDidDeactivateWebView() {
        // No-op
    }

    func activateVisitableWebView(_ webView: WKWebView) {
        visitableView.activateWebView(webView, forVisitable: self)
        visitableDidActivateWebView(webView)
    }

    func deactivateVisitableWebView() {
        visitableWillDeactivateWebView()
        visitableView.deactivateWebView()
        visitableDidDeactivateWebView()
    }

    func updateVisitableScreenshot() {
        visitableView.updateScreenshot()
    }

    func showVisitableScreenshot() {
        visitableView.showScreenshot()
    }

    func hideVisitableScreenshot() {
        visitableView.hideScreenshot()
    }

    func clearVisitableScreenshot() {
        visitableView.clearScreenshot()
    }

    func visitableWillRefresh() {
        visitableView.refreshControl.beginRefreshing()
    }

    func visitableDidRefresh() {
        visitableView.refreshControl.endRefreshing()
    }

    func visitableViewDidRequestRefresh() {
        visitableDelegate?.visitableDidRequestRefresh(self)
    }
}

public extension Visitable where Self: UIViewController {
    var visitableViewController: UIViewController {
        self
    }
}
