//
//  WebViewSpikeApp.swift
//  WebViewSpike
//
//  Created by David Martin Nevado on 27/05/2026.
//

import SwiftUI

@main
struct WebViewSpikeApp: App {
    init() {
        // Pre-warm the most likely URL as soon as the app launches.
        WebViewPool.shared.prewarm(url: URL(string: "https://developer.apple.com/documentation/webkit")!)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
