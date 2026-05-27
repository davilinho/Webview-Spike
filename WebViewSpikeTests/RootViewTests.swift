//
//  RootViewTests.swift
//  WebViewSpikeTests
//

import Testing
import SwiftUI
@testable import WebViewSpike

@MainActor
struct RootViewTests {

    @Test func demoIdentityIsStablePerInstance() {
        let a = RootView.Demo(title: "x", url: URL(string: "https://x")!)
        #expect(a.id == a.id)
    }

    @Test func demoEqualityUsesAllFields() {
        let url = URL(string: "https://x")!
        let a = RootView.Demo(title: "x", url: url)
        let b = RootView.Demo(title: "x", url: url)
        // Different UUIDs -> different identity even with same title/url.
        #expect(a != b)
    }

    @Test func rootViewCanBeInstantiated() {
        let view = RootView()
        _ = view.body
        #expect(Bool(true))
    }
}
