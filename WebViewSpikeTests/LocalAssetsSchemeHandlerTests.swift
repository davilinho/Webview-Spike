//
//  LocalAssetsSchemeHandlerTests.swift
//  WebViewSpikeTests
//

import Testing
import WebKit
@testable import WebViewSpike

private final class MockSchemeTask: NSObject, WKURLSchemeTask {
    let request: URLRequest
    private(set) var receivedResponse: URLResponse?
    private(set) var receivedData: Data?
    private(set) var didFinishCalled = false
    private(set) var error: Error?

    init(url: URL) { self.request = URLRequest(url: url) }

    func didReceive(_ response: URLResponse) { self.receivedResponse = response }
    func didReceive(_ data: Data) {
        self.receivedData = (self.receivedData ?? Data()) + data
    }
    func didFinish() { didFinishCalled = true }
    func didFailWithError(_ error: Error) { self.error = error }
}

@MainActor
struct LocalAssetsSchemeHandlerTests {

    @Test func missingFileFailsWithError() {
        let handler = LocalAssetsSchemeHandler()
        let task = MockSchemeTask(url: URL(string: "app-assets:///does-not-exist.png")!)

        handler.webView(WKWebView(), start: task)

        #expect(task.error != nil)
        #expect(task.didFinishCalled == false)
        #expect(task.receivedResponse == nil)
    }

    @Test func stopIsNoOp() {
        let handler = LocalAssetsSchemeHandler()
        let task = MockSchemeTask(url: URL(string: "app-assets:///x")!)
        handler.webView(WKWebView(), stop: task)
        // Reaching here means it did not crash.
        #expect(Bool(true))
    }
}
