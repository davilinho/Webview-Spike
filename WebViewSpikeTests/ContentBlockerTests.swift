//
//  ContentBlockerTests.swift
//  WebViewSpikeTests
//

import Testing
import WebKit
@testable import WebViewSpike

@MainActor
struct ContentBlockerTests {

    @Test func installDoesNotCrash() async {
        let controller = WKUserContentController()
        ContentBlocker.shared.install(into: controller)
        // Allow the async compileContentRuleList to settle.
        try? await Task.sleep(nanoseconds: 200_000_000)
        // Second call should be safe regardless of cached state.
        ContentBlocker.shared.install(into: controller)
        #expect(Bool(true))
    }

    @Test func installIsIdempotentAcrossControllers() async {
        // Calling install twice on different controllers must not crash and
        // both controllers should accept the call regardless of cache state.
        let a = WKUserContentController()
        let b = WKUserContentController()
        ContentBlocker.shared.install(into: a)
        ContentBlocker.shared.install(into: b)
        try? await Task.sleep(nanoseconds: 500_000_000)
        // A third call once the rule list is already cached takes the fast path.
        let c = WKUserContentController()
        ContentBlocker.shared.install(into: c)
        #expect(Bool(true))
    }
}
