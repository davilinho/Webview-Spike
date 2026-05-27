//
//  OptimizedWebView.swift
//  WebViewSpike
//
//  UIViewRepresentable that reuses an already-instantiated WKWebView (does not create one every time).
//

import SwiftUI
import WebKit

struct OptimizedWebView: UIViewRepresentable {

    let webView: WKWebView
    let coordinator: WebViewCoordinator

    func makeUIView(context: Context) -> WKWebView {
        coordinator.bind(to: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Nothing to do: the instance stays the same and the coordinator manages the state.
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        // We do not destroy the WebView: it remains in the pool for reuse.
    }
}
