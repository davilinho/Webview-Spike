//
//  WebViewCoordinator.swift
//  WebViewSpike
//
//  Coordinator that acts as NavigationDelegate, UIDelegate and ScriptMessageHandler.
//  Reports state to SwiftUI via @Published.
//

import Combine
import UIKit
import WebKit

@MainActor
final class WebViewCoordinator: NSObject, ObservableObject {

    @Published var title: String = ""
    @Published var url: URL?
    @Published var progress: Double = 0
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var lastLoadMillis: Double = 0

    private var cancellables: Set<AnyCancellable> = []
    private weak var webView: WKWebView?
    private var startTime: CFAbsoluteTime = 0

    #if DEBUG
    deinit { print("☠️ WebViewCoordinator deinit") }
    #endif

    func bind(to webView: WKWebView) {
        guard self.webView !== webView else { return }
        self.webView = webView
        webView.navigationDelegate = self
        webView.uiDelegate = self

        cancellables.removeAll()
        // Defer KVO emissions to the next runloop tick to avoid
        // "Publishing changes from within view updates is not allowed" when the bind
        // happens during a SwiftUI update (makeUIView / onAppear).
        let onMain = DispatchQueue.main

        webView.publisher(for: \.estimatedProgress)
            .receive(on: onMain)
            .sink { [weak self] in self?.progress = $0 }
            .store(in: &cancellables)

        webView.publisher(for: \.title)
            .receive(on: onMain)
            .sink { [weak self] in self?.title = $0 ?? "" }
            .store(in: &cancellables)

        webView.publisher(for: \.url)
            .receive(on: onMain)
            .sink { [weak self] in self?.url = $0 }
            .store(in: &cancellables)

        webView.publisher(for: \.isLoading)
            .receive(on: onMain)
            .sink { [weak self] in self?.isLoading = $0 }
            .store(in: &cancellables)

        webView.publisher(for: \.canGoBack)
            .receive(on: onMain)
            .sink { [weak self] in self?.canGoBack = $0 }
            .store(in: &cancellables)

        webView.publisher(for: \.canGoForward)
            .receive(on: onMain)
            .sink { [weak self] in self?.canGoForward = $0 }
            .store(in: &cancellables)
    }
    
    func goBack()    { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload()    { webView?.reloadFromOrigin() }
    func stop()      { webView?.stopLoading() }
}

// MARK: - WKNavigationDelegate

extension WebViewCoordinator: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow); return
        }

        // Schemes that we open natively (tel, mailto, deeplinks to other apps).
        if let scheme = url.scheme, ["tel", "mailto", "sms", "facetime"].contains(scheme) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel); return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        lastLoadMillis = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        #if DEBUG
        print("[WebView] didFinish \(webView.url?.absoluteString ?? "-") in \(Int(lastLoadMillis)) ms")
        #endif
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        #if DEBUG
        print("[WebView] fail: \(error.localizedDescription)")
        #endif
    }
}

// MARK: - WKUIDelegate (target=_blank, JS dialogs)


extension WebViewCoordinator: WKUIDelegate {

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Load target=_blank links in the same WebView instead of dropping them.
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}

// MARK: - WKScriptMessageHandler (JS -> Swift bridge)

extension WebViewCoordinator: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case "nav":
            #if DEBUG
            print("[JS->Swift] nav:", message.body)
            #endif
        case "metrics":
            #if DEBUG
            print("[JS->Swift] metrics:", message.body)
            #endif
        default: break
        }
    }
}
