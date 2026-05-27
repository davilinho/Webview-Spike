//
//  LocalAssetsSchemeHandler.swift
//  WebViewSpike
//
//  Serves resources from the app bundle when the URL uses the `app-assets://` scheme.
//  e.g.: <img src="app-assets:///logo.png"> -> Bundle.main/logo.png
//

import Foundation
import WebKit
import UniformTypeIdentifiers

final class LocalAssetsSchemeHandler: NSObject, WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start urlSchemeTask: any WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }

        let filename = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil),
              let data = try? Data(contentsOf: fileURL) else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
            return
        }

        let mime = (UTType(filenameExtension: fileURL.pathExtension)?.preferredMIMEType) ?? "application/octet-stream"
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": mime,
                "Content-Length": "\(data.count)",
                "Cache-Control": "public, max-age=31536000, immutable"
            ]
        )!

        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: any WKURLSchemeTask) {
        // No async work to cancel.
    }
}
