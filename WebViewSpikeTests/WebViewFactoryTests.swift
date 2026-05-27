//
//  WebViewFactoryTests.swift
//  WebViewSpikeTests
//

import Testing
import WebKit
@testable import WebViewSpike

@MainActor
struct WebViewFactoryTests {

    @Test func sharedDataStoreIsDefault() {
        #expect(WebViewFactory.sharedDataStore === WKWebsiteDataStore.default())
    }

    @Test func makeReturnsConfiguredWebView() {
        let webView = WebViewFactory.make()

        #expect(webView.allowsBackForwardNavigationGestures == true)
        #expect(webView.allowsLinkPreview == false)
        #expect(webView.isOpaque == false)
        #expect(webView.configuration.allowsInlineMediaPlayback == true)
        #expect(webView.configuration.mediaTypesRequiringUserActionForPlayback == [])
        #expect(webView.configuration.suppressesIncrementalRendering == false)
        #expect(webView.configuration.defaultWebpagePreferences.allowsContentJavaScript == true)
        #expect(webView.configuration.websiteDataStore === WebViewFactory.sharedDataStore)
        #expect(webView.scrollView.decelerationRate == .normal)
    }

    @Test func makeInjectsBootstrapUserScript() {
        let webView = WebViewFactory.make()
        let scripts = webView.configuration.userContentController.userScripts
        #expect(scripts.contains { $0.injectionTime == .atDocumentStart })
    }

    @Test func makeRegistersLocalAssetsSchemeHandler() {
        let webView = WebViewFactory.make()
        let handler = webView.configuration.urlSchemeHandler(forURLScheme: "app-assets")
        #expect(handler is LocalAssetsSchemeHandler)
    }

    @Test func makeRegistersMessageHandlerWhenProvided() {
        // Just ensure providing a handler does not crash and the WebView is created.
        final class Dummy: NSObject, WKScriptMessageHandler {
            func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {}
        }
        let webView = WebViewFactory.make(messageHandler: Dummy())
        #expect(webView.configuration.userContentController.userScripts.isEmpty == false)
    }
}
