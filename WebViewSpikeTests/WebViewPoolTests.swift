//
//  WebViewPoolTests.swift
//  WebViewSpikeTests
//

import Testing
import WebKit
@testable import WebViewSpike

@MainActor
struct WebViewPoolTests {

    private func makePool() -> WebViewPool {
        let pool = WebViewPool.shared
        pool.evictAll()
        return pool
    }

    @Test func webViewForURLReturnsSameInstance() {
        let pool = makePool()
        let url = URL(string: "https://example.com/a")!

        let first = pool.webView(for: url)
        let second = pool.webView(for: url)

        #expect(first === second)
    }

    @Test func webViewForURLReturnsDifferentInstancesForDifferentURLs() {
        let pool = makePool()
        let a = pool.webView(for: URL(string: "https://example.com/a")!)
        let b = pool.webView(for: URL(string: "https://example.com/b")!)

        #expect(a !== b)
    }

    @Test func evictRemovesEntry() {
        let pool = makePool()
        let url = URL(string: "https://example.com/c")!
        let first = pool.webView(for: url)

        pool.evict(url: url)
        let second = pool.webView(for: url)

        #expect(first !== second)
    }

    @Test func evictAllRemovesAllEntries() {
        let pool = makePool()
        let urlA = URL(string: "https://example.com/x")!
        let urlB = URL(string: "https://example.com/y")!
        let a1 = pool.webView(for: urlA)
        let b1 = pool.webView(for: urlB)

        pool.evictAll()

        let a2 = pool.webView(for: urlA)
        let b2 = pool.webView(for: urlB)
        #expect(a1 !== a2)
        #expect(b1 !== b2)
    }

    @Test func prewarmCachesWebViewAndReusesIt() {
        let pool = makePool()
        let url = URL(string: "https://example.com/prewarm")!

        pool.prewarm(url: url)
        let webView = pool.webView(for: url)

        // Calling prewarm again must be a no-op (does not replace the instance).
        pool.prewarm(url: url)
        let again = pool.webView(for: url)

        #expect(webView === again)
    }
}
