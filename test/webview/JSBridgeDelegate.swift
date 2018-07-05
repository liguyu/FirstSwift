//
//  JSBridgeDelegate.swift
//
//  Created by lgy on 2018/6/14.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import WebKit

private typealias WKNavigationHandler = JSBridgeDelegate

extension WKNavigationHandler {
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(self.injectJS(), completionHandler: nil)
    }
    
    func injectJS() -> String{
        var js =
        """
            var HostApp = {};
            function toBeInvokedBySwift(a, b, c) {
                var s = 'a:' + a + ',b:' + b + ',c:' + c
                window.alert('native2browser: ' + s)
                return s
            }
        """
        let args = """
                let args = {}
                for(var i = 0; i < arguments.length; i++) {
                    args[fargs[i]] = arguments[i]
                }
            """
        let funcs = self.hostApp.getJSSignatures()
        for f in funcs {
            let fparts = f.split(separator: ":")
            let fname = fparts[0].split(separator: "(")
            var fargs = [Substring.SubSequence]()
            if fname[1].trimmingCharacters(in: .whitespacesAndNewlines) != ")" {
                fargs = fname[1].split(separator: ")")[0].split(separator: ",")
            }
            var formalArgs = "let fargs = []; "
            for farg in fargs {
                formalArgs = formalArgs + "fargs.push('\(farg)');"
            }
            js = js + ";HostApp.\(fname[0]) = function(\(fname[1]) {\(formalArgs)\n\(args)\n"
                + "var json = {func: '\(fname[0])', args: args, ret: '\(fparts[1])'}\n"
                + "var r = JSON.parse(prompt(JSON.stringify(json)));\n"
                + "if (r.code === 500) throw 'native call failed.';\n"
                + "if('\(fparts[1])' === 'number') return Number(r.gut);\n"
                + "if('\(fparts[1])' === 'json') return r.gut;\n"
                + "if('\(fparts[1])' === 'string') return r.gut;\n"
                + "}\n"
        }
        return js
    }
}

private typealias WKUIHandler = JSBridgeDelegate

extension WKUIHandler {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        let ac = UIAlertController(title: "系统信息", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        let vc = findViewController(view: webView.superview!)!
        vc.present(ac, animated: true)
        completionHandler()
    }
    
    func findViewController(view: UIView) -> UIViewController? {
        var parentResponder: UIResponder? = view
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let dict = Util.convertToDict(jsonStr: prompt.data(using: String.Encoding.utf8)!)
        let funcName = dict["func"] as! String
        let ret = dict["ret"] as! String
        let fs = Selector(funcName + ":")
        if self.hostApp.responds(to: fs) {
            let unmanaged = self.hostApp.perform(fs, with: dict)
            if ret == "void" {
                var result = Dictionary<String, Any>();
                result["code"] = 200
                completionHandler(Util.nSDictionary2String(result as NSDictionary))
            }
            else if(ret == "string") {
                var result = Dictionary<String, Any>();
                result["code"] = 200
                result["gut"] = unmanaged?.takeUnretainedValue() as! String
                completionHandler(Util.nSDictionary2String(result as NSDictionary))
            }
            else if(ret == "number") {
                var result = Dictionary<String, Any>();
                result["code"] = 200
                result["gut"] = String(describing: unmanaged?.takeUnretainedValue())
                completionHandler(Util.nSDictionary2String(result as NSDictionary))
            }
            else if(ret == "json") {
                var result = Dictionary<String, Any>();
                result["code"] = 200
                result["gut"] = unmanaged?.takeUnretainedValue() as! NSDictionary
                completionHandler(Util.nSDictionary2String(result as NSDictionary))
            } else {
                var result = Dictionary<String, Any>();
                result["code"] = 500
                completionHandler(Util.nSDictionary2String(result as NSDictionary))
            }
        } else {
            var result = Dictionary<String, Any>();
            result["code"] = 500
            completionHandler(Util.nSDictionary2String(result as NSDictionary))
        }
    }
}

public class JSBridgeDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
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
    
    public func callJs(script: String) {
        let urlString = "javascript:\(script)"
        self.wk.evaluateJavaScript(urlString) { (result, error) in
            if result != nil {
                print(result!)
            }
        }
    }
    
    public func loadPage(htmlUrlStr: String, baseUrlStr: String) {
        var baseUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        var htmlUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        htmlUrl.appendPathComponent(htmlUrlStr)
        baseUrl.appendPathComponent(baseUrlStr)
        wk.loadFileURL(URL(fileURLWithPath: htmlUrl.path, isDirectory: false), allowingReadAccessTo: URL(fileURLWithPath: baseUrl.path, isDirectory: true))
    }
}
