//
//  WebViewPool.swift
//  WebViewSpike
//
//  Keeps WKWebView instances alive and reusable, with pre-warming support.
//

import UIKit
import WebKit

final class WebViewPool {

    static let shared = WebViewPool()
    private init() {}

    private var cache: [URL: WKWebView] = [:]

    /// Returns a WebView for this URL. If it exists in cache it is reused; otherwise it is created and loaded.
    func webView(for url: URL, messageHandler: WKScriptMessageHandler? = nil) -> WKWebView {
        if let cached = cache[url] {
            return cached
        }
        let webView = WebViewFactory.make(messageHandler: messageHandler)
        webView.load(URLRequest(url: url))
        cache[url] = webView
        return webView
    }

    /// Starts loading a URL in the background so it is ready by the time the user navigates to it.
    func prewarm(url: URL) {
        guard cache[url] == nil else { return }
        let webView = WebViewFactory.make()
        // Attaching to an invisible window helps WebKit run the full render cycle.
        webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        PrewarmHost.shared.attach(webView)
        webView.load(URLRequest(url: url))
        cache[url] = webView
    }

    func evict(url: URL) {
        cache[url] = nil
    }

    func evictAll() {
        cache.removeAll()
    }
}

/// Invisible host to keep pre-warming WebViews inside the view hierarchy.
private final class PrewarmHost {
    static let shared = PrewarmHost()
    private let container = UIView(frame: .zero)

    private init() {
        container.isHidden = true
        container.isUserInteractionEnabled = false
    }

    func attach(_ webView: WKWebView) {
        if container.superview == nil,
           let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first {
            window.addSubview(container)
        }
        container.addSubview(webView)
    }
}
