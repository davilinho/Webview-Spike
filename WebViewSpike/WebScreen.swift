//
//  WebScreen.swift
//  WebViewSpike
//
//  SwiftUI screen that shows a reused WebView with a native toolbar,
//  a progress bar and a snapshot during transitions to avoid flashes.
//

import SwiftUI
import WebKit

struct WebScreen: View {

    let url: URL
    @StateObject private var coordinator = WebViewCoordinator()
    @State private var snapshot: UIImage?

    private var webView: WKWebView {
        WebViewPool.shared.webView(for: url, messageHandler: coordinator)
    }

    var body: some View {
        VStack(spacing: 0) {
            if coordinator.isLoading {
                ProgressView(value: coordinator.progress)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
            }

            ZStack {
                OptimizedWebView(webView: webView, coordinator: coordinator)

                if let snapshot {
                    Image(uiImage: snapshot)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
        }
        .navigationTitle(coordinator.title.isEmpty ? url.host ?? "" : coordinator.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onAppear {
            coordinator.bind(to: webView)
            // If we come back with a snapshot, fade it out once the page is ready.
            if snapshot != nil {
                Task {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    withAnimation(.easeOut(duration: 0.2)) { snapshot = nil }
                }
            }
        }
        .onDisappear {
            // Capture a snapshot so there is no white flash when we come back.
            webView.takeSnapshot(with: nil) { image, _ in
                Task { @MainActor in self.snapshot = image }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: coordinator.goBack) { Image(systemName: "chevron.left") }
                .disabled(!coordinator.canGoBack)
            Spacer()
            Button(action: coordinator.goForward) { Image(systemName: "chevron.right") }
                .disabled(!coordinator.canGoForward)
            Spacer()
            Button {
                coordinator.isLoading ? coordinator.stop() : coordinator.reload()
            } label: {
                Image(systemName: coordinator.isLoading ? "xmark" : "arrow.clockwise")
            }
            Spacer()
            if let url = coordinator.url {
                ShareLink(item: url) { Image(systemName: "square.and.arrow.up") }
            }
        }
    }
}
