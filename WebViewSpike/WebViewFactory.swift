//
//  WebViewFactory.swift
//  WebViewSpike
//
//  Creates WKWebView instances with an optimal, shared configuration.
//

import WebKit

enum WebViewFactory {

    /// Persistent data store: HTTP cache, IndexedDB, service workers, localStorage across launches.
    /// Since iOS 15 sharing the same data store is enough to share cookies / sessions across
    /// WebViews; `WKProcessPool` is deprecated and creating instances has no effect.
    static let sharedDataStore: WKWebsiteDataStore = .default()

    /// Builds a WKWebView ready to use.
    static func make(messageHandler: WKScriptMessageHandler? = nil) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = sharedDataStore
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = false
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        if #available(iOS 15.4, *) {
            config.preferences.isElementFullscreenEnabled = true
        }

        // Custom scheme to serve local assets without hitting the network.
        config.setURLSchemeHandler(LocalAssetsSchemeHandler(), forURLScheme: "app-assets")

        // Bootstrap script injected at document start (JS <-> Swift bridge).
        let bootstrap = WKUserScript(
            source: Self.bootstrapJS,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(bootstrap)

        if let messageHandler {
            config.userContentController.add(messageHandler, name: "nav")
            config.userContentController.add(messageHandler, name: "metrics")
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground
        webView.scrollView.decelerationRate = .normal

        // Content blocking (trackers / ads) compiled only once.
        ContentBlocker.shared.install(into: config.userContentController)

        return webView
    }

    /// JS injected at document start: exposes navigation helpers and reports metrics to native.
    private static let bootstrapJS = """
    (function () {
        window.SoonoBridge = {
            push(route) {
                window.webkit?.messageHandlers?.nav?.postMessage({ type: 'push', route });
                history.pushState({}, '', route);
            },
            back() { history.back(); }
        };

        window.addEventListener('load', function () {
            try {
                const nav = performance.getEntriesByType('navigation')[0];
                if (nav) {
                    window.webkit?.messageHandlers?.metrics?.postMessage({
                        domContentLoaded: nav.domContentLoadedEventEnd,
                        loadEvent: nav.loadEventEnd,
                        transferSize: nav.transferSize
                    });
                }
            } catch (e) { /* noop */ }
        });
    })();
    """
}
