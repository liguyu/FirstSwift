//
//  JSBridgeDelegate.swift
//  test
//
//  Created by apple on 2018/6/14.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import WebKit

private typealias WKNavigationHandler = JSBridgeDelegate

extension WKNavigationHandler {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //在此处注入js
        webView.evaluateJavaScript(self.injectJS(), completionHandler: nil)
    }
    
    func injectJS() -> String{
        let comments = self.hostApp.getAnnations()
        return ""
    }
}


class JSBridgeDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
    var wk: WKWebView
    var hostApp: HostApp
    var className: String
    
    init(wk: WKWebView, hostApp: HostApp) {
        self.wk = wk
        self.hostApp = hostApp
        self.className = hostApp.classForCoder.description()
        super.init()
        self.wk.uiDelegate = self
        self.wk.navigationDelegate = self
    }
    
}
