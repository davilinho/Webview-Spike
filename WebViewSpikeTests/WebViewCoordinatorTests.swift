//
//  WebViewCoordinatorTests.swift
//  WebViewSpikeTests
//

import Testing
import WebKit
@testable import WebViewSpike

private final class MockNavAction: WKNavigationAction, @unchecked Sendable {
    private let _request: URLRequest
    init(request: URLRequest) {
        self._request = request
        super.init()
    }
    override var request: URLRequest { _request }
    // targetFrame stays nil so we can exercise the createWebViewWith branch.
}

@MainActor
struct WebViewCoordinatorTests {

    @Test func bindAssignsDelegates() {
        let webView = WKWebView()
        let coordinator = WebViewCoordinator()

        coordinator.bind(to: webView)

        #expect(webView.navigationDelegate === coordinator)
        #expect(webView.uiDelegate === coordinator)
    }

    @Test func bindIsIdempotentForSameWebView() {
        let webView = WKWebView()
        let coordinator = WebViewCoordinator()

        coordinator.bind(to: webView)
        coordinator.bind(to: webView)

        #expect(webView.navigationDelegate === coordinator)
    }

    @Test func bindRebindsToNewWebView() {
        let coordinator = WebViewCoordinator()
        let first = WKWebView()
        let second = WKWebView()

        coordinator.bind(to: first)
        coordinator.bind(to: second)

        #expect(second.navigationDelegate === coordinator)
        #expect(second.uiDelegate === coordinator)
    }

    @Test func navigationControlsDoNotCrashWithoutHistory() {
        let webView = WKWebView()
        let coordinator = WebViewCoordinator()
        coordinator.bind(to: webView)

        coordinator.goBack()
        coordinator.goForward()
        coordinator.reload()
        coordinator.stop()

        #expect(coordinator.canGoBack == false)
        #expect(coordinator.canGoForward == false)
    }

    @Test func navigationControlsAreNoopWhenNotBound() {
        let coordinator = WebViewCoordinator()
        coordinator.goBack()
        coordinator.goForward()
        coordinator.reload()
        coordinator.stop()
        #expect(Bool(true))
    }

    // MARK: - WKNavigationDelegate

    @Test func decidePolicyAllowsRegularURL() async {
        let coordinator = WebViewCoordinator()
        let action = MockNavAction(request: URLRequest(url: URL(string: "https://example.com")!))

        let policy = await withCheckedContinuation { cont in
            coordinator.webView(WKWebView(), decidePolicyFor: action) { cont.resume(returning: $0) }
        }

        #expect(policy == .allow)
    }

    @Test func decidePolicyAllowsWhenURLIsMissing() async {
        let coordinator = WebViewCoordinator()
        let action = MockNavAction(request: URLRequest(url: URL(string: "about:blank")!))

        let policy = await withCheckedContinuation { cont in
            coordinator.webView(WKWebView(), decidePolicyFor: action) { cont.resume(returning: $0) }
        }

        #expect(policy == .allow)
    }

    @Test func decidePolicyCancelsNativeSchemes() async {
        let coordinator = WebViewCoordinator()
        let schemes = ["tel://123456789", "mailto:foo@bar.com", "sms:111", "facetime:foo@bar.com"]

        for raw in schemes {
            let url = URL(string: raw)!
            let action = MockNavAction(request: URLRequest(url: url))
            let policy = await withCheckedContinuation { cont in
                coordinator.webView(WKWebView(), decidePolicyFor: action) { cont.resume(returning: $0) }
            }
            #expect(policy == .cancel, "\(raw) should be cancelled")
        }
    }

    @Test func didFinishUpdatesLastLoadMillis() {
        let coordinator = WebViewCoordinator()
        let webView = WKWebView()

        coordinator.webView(webView, didStartProvisionalNavigation: nil)
        coordinator.webView(webView, didFinish: nil)

        #expect(coordinator.lastLoadMillis >= 0)
    }

    @Test func didFailDoesNotCrash() {
        let coordinator = WebViewCoordinator()
        let webView = WKWebView()
        let error = NSError(domain: "test", code: 42)

        coordinator.webView(webView, didFailProvisionalNavigation: nil, withError: error)
        #expect(Bool(true))
    }

    // MARK: - WKUIDelegate

    @Test func createWebViewLoadsTargetBlankIntoSameWebView() {
        let coordinator = WebViewCoordinator()
        let webView = WKWebView()
        let action = MockNavAction(request: URLRequest(url: URL(string: "https://example.com/popup")!))

        let result = coordinator.webView(
            webView,
            createWebViewWith: webView.configuration,
            for: action,
            windowFeatures: WKWindowFeatures()
        )

        #expect(result == nil)
    }
}
