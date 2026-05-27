//
//  RootView.swift
//  WebViewSpike
//
//  App root: list of demo URLs + pre-warming / cleanup actions.
//

import SwiftUI
import WebKit

struct RootView: View {

    struct Demo: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let url: URL
    }

    private let demos: [Demo] = [
        .init(title: "WebKit docs",
              url: URL(string: "https://developer.apple.com/documentation/webkit")!),
        .init(title: "Apple Developer",
              url: URL(string: "https://developer.apple.com")!),
        .init(title: "Swift.org",
              url: URL(string: "https://www.swift.org")!),
        .init(title: "MDN",
              url: URL(string: "https://developer.mozilla.org")!),
        .init(title: "Google",
              url: URL(string: "https://www.google.com")!),
        .init(title: "Soono",
              url: URL(string: "https://dmartintech.com/soono")!)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Demos") {
                    ForEach(demos) { demo in
                        NavigationLink(value: demo) {
                            HStack {
                                Image(systemName: "safari")
                                VStack(alignment: .leading) {
                                    Text(demo.title).font(.body)
                                    Text(demo.url.host ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                WebViewPool.shared.prewarm(url: demo.url)
                            } label: {
                                Label("Prewarm", systemImage: "flame")
                            }
                            .tint(.orange)
                        }
                    }
                }

                Section("Maintenance") {
                    Button(role: .destructive) {
                        WebViewPool.shared.evictAll()
                    } label: {
                        Label("Clear WebView pool", systemImage: "trash")
                    }

                    Button {
                        clearWebsiteData()
                    } label: {
                        Label("Clear website cache", systemImage: "internaldrive")
                    }
                }
            }
            .navigationTitle("WebView Spike")
            .navigationDestination(for: Demo.self) { demo in
                WebScreen(url: demo.url)
            }
        }
    }

    private func clearWebsiteData() {
        // We avoid WKWebsiteDataTypeHistory because on the simulator it triggers
        // a noisy error when trying to contact `com.apple.coreduetd.knowledge`
        // (a daemon that does not exist on the simulator). On a real device you can
        // use `WKWebsiteDataStore.allWebsiteDataTypes()` directly.
        let types: Set<String> = [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeWebSQLDatabases,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeServiceWorkerRegistrations,
            WKWebsiteDataTypeFetchCache
        ]
        WebViewFactory.sharedDataStore.removeData(
            ofTypes: types,
            modifiedSince: .distantPast
        ) {}
    }
}

#Preview { RootView() }
