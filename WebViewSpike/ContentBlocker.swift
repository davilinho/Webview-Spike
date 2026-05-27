//
//  ContentBlocker.swift
//  WebViewSpike
//
//  Compiles and applies WKContentRuleList rules to block heavy trackers/ads.
//

import WebKit

final class ContentBlocker {

    static let shared = ContentBlocker()
    private init() {}

    private var compiled: WKContentRuleList?
    private var isCompiling = false

    /// Minimal example rules (you can extend this with EasyList-style lists converted to JSON).
    private let rulesJSON = """
    [
      {
        "trigger": { "url-filter": ".*doubleclick\\\\.net.*" },
        "action": { "type": "block" }
      },
      {
        "trigger": { "url-filter": ".*google-analytics\\\\.com.*" },
        "action": { "type": "block" }
      },
      {
        "trigger": { "url-filter": ".*\\\\.(gif|png|jpg)$", "resource-type": ["image"] },
        "action": { "type": "css-display-none", "selector": "img[src*='ads']" }
      }
    ]
    """

    func install(into controller: WKUserContentController) {
        if let compiled {
            controller.add(compiled)
            return
        }
        guard !isCompiling else { return }
        isCompiling = true

        WKContentRuleListStore.default()?.compileContentRuleList(
            forIdentifier: "wvspike-block-list",
            encodedContentRuleList: rulesJSON
        ) { [weak self] list, error in
            self?.isCompiling = false
            guard let list, error == nil else { return }
            self?.compiled = list
            controller.add(list)
        }
    }
}
