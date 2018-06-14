//
//  ViewController.swift
//  test
//
//  Created by apple on 2018/5/28.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import WebKit



private typealias wkScriptMessageHandler = ViewController
extension wkScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "HostApp" {
            print(message.body)
            let dict = message.body as! NSDictionary
            let className = dict["clazz"] as! String
            let functionName = dict["func"] as! String
            let package = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            if let cls = NSClassFromString(package + "." + className) as? NSObject.Type{
                let obj = cls.init()
                let fs = Selector(functionName + ":")
                if obj.responds(to: fs) {
                    let unmanaged = obj.perform(fs, with: dict)
                    let d = unmanaged?.takeUnretainedValue() as! NSDictionary
                    print("首先调用postMessage")
                    print(d)
//                let functionSelector = Selector("log2:")
//                print(obj.responds(to: #selector(Callme.maybe)))
//                print(obj.responds(to: Selector(("maybe"))))
//                print(obj.responds(to: Selector(("log:"))))
//                print(obj.responds(to: Selector(("log3WithData:"))))
//                print(obj.responds(to: Selector(("log4WithData1:d2:"))))
//                print(obj.responds(to: Selector(("log5:d2:"))))
//                if obj.responds(to: functionSelector) {
//                    let unmanaged = obj.perform(functionSelector, with: dict as NSDictionary)
//                    let d = unmanaged?.takeUnretainedValue() as! NSDictionary
//                    print(d)
                } else {
                    print("方法未找到！")
                }
//                let aselector = Selector("test:")
//                let setSelector = Selector("test:msg:")
//                var dict = Dictionary<String, Any?>()
//                dict["abc"] = 1
//                //if obj.responds(to: setSelector) {
//                    obj.performSelector(inBackground: aselector, with: dict as! NSDictionary)
//                //}
//                let functionSelector = Selector(functionName)
//                if obj.responds(to: functionSelector) {
//                    obj.perform(functionSelector)
//                } else {
//                    print("方法未找到！")
//                }
            } else {
                print("类未找到！")
            }
        }
    }
}

private typealias wkNavigationDelegate = ViewController
extension wkNavigationDelegate {
    /**
     in case of error
     */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //在此处注入js
        webView.evaluateJavaScript(self.injectJS(), completionHandler: nil)
    }
    

}

private typealias wkUIDelegate = ViewController
extension wkUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        print(message);
        let ac = UIAlertController(title: "提示信息", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(ac, animated: true)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let dict = HttpDelegate.convertToDict(jsonStr: prompt.data(using: String.Encoding.utf8)!)
        print("调用prompt")
        print(dict)
        completionHandler(prompt)
//        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
//
//        alertController.addTextField { (textField) in
//            textField.text = defaultText
//        }
//
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//            if let text = alertController.textFields?.first?.text {
//                completionHandler(text)
//            } else {
//                completionHandler(defaultText)
//            }
//        }))
//
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
//            completionHandler(nil)
//        }))
//
//        present(alertController, animated: true, completion: nil)
        
    }

}

/**
 * so called webviewcontext
 */
public class WebViewContext {
    var webView: WKWebView
    
    public init(webView: WKWebView) {
        self.webView = webView
    }
}



class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    

    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    var textLayer: CATextLayer!;
    
    var wk: WKWebView!
    var host: String = "http://192.168.20.21:8081/RestWork/rs/"
    var hostApp: MyHostApp!
    
    @IBAction func nativeCallJs(sender: UIButton) {
        let urlString = "javascript:toBeInvokedBySwift(1,2,'3')"
        wk.evaluateJavaScript(urlString) { (result, error) in
            if result != nil {
                print(result!)
            }
        }
    }
    
    @IBAction func fetchMeta(sender: UIButton) {
                var dict = Dictionary<String, Any>()
                dict["a"] = 1
                dict["b"] = "2"
                HttpDelegate.syncPost(url: "http://192.168.20.21:8081/RestWork/rs/db/meta2", dict: dict, respondResult: onResultGot2)
    }
    
    @IBAction func showMessage(sender: UIButton) {
        //downloadWithProgress()
        //postRequestDownload()
        //getAllFilesUnderAFolder(dir: "c:/test")
        //getAFile(fn: "c:\\test\\index.html")
        //textLayer.string = String(arc4random_uniform(100) + 1)
        //fetchAllFilesUnderAFolder(url: "http://192.168.20.21:8081/RestWork/rs/dir?path=c:/test")
        HttpDelegate.syncGet(url: "\(host)dir?path=c:/test", respondResult: onH5FileNamesGot)
//        HttpDelegate.syncGet(url: "http://192.168.20.21:8081/RestWork/rs/db/one/from%20t_singlevalue%20where%20name='appVer'", respondResult: onResultGot2)
    }
    
    func injectJS() -> String {
        var js =
        """
        HostApp = window.webkit.messageHandlers.HostApp
        //var person = prompt("Please enter your name", "Harry Potter");
        //window.alert(person)
        function toBeInvokedBySwift(a, b, c) {
            var s = 'a:' + a + ',b:' + b + ',c:' + c
            window.alert('native2browser: ' + s)
            return s
        }
        window.onerror = function(err) {
            console.log("window.onerror: " + err)
        }
        """
        var body =
        """
            let args = {}
            for(var i = 0; i < arguments.length; i++) {
                args['a'+ i] = arguments[i]
            }
        """
        let funcs = hostApp.getAnnations()
        for f in funcs {
            let fparts = f.split(separator: ":")
            let fname = fparts[1].split(separator: "(")
            js = js + "\nHostApp.\(fname[0])= function(\(fname[1]){\(body)\n;"
                + "var json = {func: '\(fname[0])', args: args, clazz: '\(fparts[0])'}; HostApp.postMessage(json); "
                + "var r = prompt(JSON.stringify(json)); window.alert('browser2native result: ' + r);"
                + "if('\(fparts[2])' !== 'Void') return r"
                + "}"
        }
        return js
    }
    
    func onH5FileNamesGot(data: Data?) ->Bool {
        if data != nil {
            if let fileNameDump  = String(data: data!, encoding: String.Encoding.utf8) as String? {
                let fileTimestampPair = fileNameDump.split(separator: "|")
                for fileTimestamp in fileTimestampPair {
                    let pair = fileTimestamp.split(separator: ",")
                    var fnWithNoDiskPrefix = String(pair[0][pair[0].index(pair[0].startIndex, offsetBy: 3)...])
                    fnWithNoDiskPrefix = fnWithNoDiskPrefix.replacingOccurrences(of: "\\", with: "/", options: .literal, range: nil)
                    print(fnWithNoDiskPrefix)
                    if !createDirIfNotExist(fullPath: fnWithNoDiskPrefix) {
                        NSLog("%s", "create directory failed")
                        return false
                    }
                    
                    // if file exists
                    if fileExists(fullPath: fnWithNoDiskPrefix) {
                        // get the file creation date
                        let dLocal = getFileCreationDate(fullPath: fnWithNoDiskPrefix)
                        if dLocal == nil {
                            NSLog("%s", "error getting file creation date")
                            return false
                        }
                        let dRemote = Int64(pair[1])
                        print("local file date:\(dLocal)\nRemote file date:\(dRemote)")
                        // if file created is old, delete
                        if dLocal! < dRemote! {
                            if !deleteFile(fullPath: fnWithNoDiskPrefix) {
                                NSLog("%s", "failed to delete file")
                                return false
                            }
                        } else {
                            continue
                        }
                    }
                    
                    //
                    // save file
                    let b = HttpDelegate.syncPost(url: "\(host)dir", body: String(pair[0])) {
                        (data) -> Bool in
                        if !self.saveFile(fullPath: fnWithNoDiskPrefix, data: data) {
                            return false
                        } else {
                            return true
                        }
                    }
                    if !b {
                        NSLog("%s", "保存文件失败！")
                        return false
                    }
                    
                }
                loadFileUrl()
                return true
            } else {
                NSLog("%s", "提取文件失败！")
                return false
            }
        } else {
            NSLog("返回数据为空")
            return false
        }
    }
    
    func loadFileUrl() {
        var baseUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        var htmlUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        htmlUrl.appendPathComponent("test/index.html")
        baseUrl.appendPathComponent("test")
        wk.loadFileURL(URL(fileURLWithPath: htmlUrl.path, isDirectory: false), allowingReadAccessTo: URL(fileURLWithPath: baseUrl.path, isDirectory: true))
    }
    
    func deleteFile(fullPath: String) -> Bool{
        var docUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        docUrl.appendPathComponent(fullPath)
        do {
            try FileManager.default.removeItem(at: docUrl)
            return true
        } catch {
            return false
        }
    }
    
    /**
     * 获取文件创建日期
    */
    func getFileCreationDate(fullPath: String) -> Int64? {
        var docUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        docUrl.appendPathComponent(fullPath)
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: docUrl.path) as NSDictionary
            return Int64(attrs.fileCreationDate()!.timeIntervalSince1970 * 1000)
        } catch {
            return nil
        }
    }
    
    func onResultGot2(data: Data?) -> Bool {
        if data == nil {
            return false
        } else {
            let dict = HttpDelegate.convertToDict(jsonStr: data!)
            print("dict: \(dict)")
            return true
        }
    }

    func onResultGot(data: Data?) -> Bool {
        if data == nil {
            return false
        } else {
            let result = String(data: data! as Data, encoding: String.Encoding.utf8) as String?
            print(result!)
            return true
        }
    }
    
    func onFileNamesGot(data: NSData?, error: NSError?) {
        if data != nil {
            if let fileNameDump  = String(data: data! as Data, encoding: String.Encoding.utf8) as String? {
                let fileTimestampPair = fileNameDump.split(separator: "|")
                for fileTimestamp in fileTimestampPair {
                    let pair = fileTimestamp.split(separator: ",")
                    let fnWithNoDiskPrefix = pair[0][pair[0].index(pair[0].startIndex, offsetBy: 3)...]
                    print(fnWithNoDiskPrefix)
                    print(Int(Date().timeIntervalSince1970*1000))
                    if !createDirIfNotExist(fullPath: String(fnWithNoDiskPrefix)) {
                        NSLog("%s", "create directory failed")
                    }
                    print(pair[1])
                }
            } else {
                    NSLog("%s", "提取文件失败！")
            }
        } else {
            print(error!)
        }
    }
    
    func fileExists(fullPath: String) -> Bool {
        var docUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        docUrl.appendPathComponent(fullPath)
        return FileManager.default.fileExists(atPath: docUrl.path)
    }
    
    func saveFile(fullPath: String, data: Data?) -> Bool {
        var docUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        docUrl.appendPathComponent(fullPath)
        do {
            try data?.write(to: docUrl)
            return true
        } catch {
            return false
        }
    }
    
    func createDirIfNotExist(fullPath: String) -> Bool {
        let lastIndex = fullPath.range(of: "/", options: .backwards)?.lowerBound
        if let li = lastIndex {
            let dirs = fullPath[fullPath.startIndex ..< li]
            var docUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            docUrl.appendPathComponent(String(dirs))
            if !FileManager.default.fileExists(atPath: docUrl.path) {
                do {
                    try FileManager.default.createDirectory(at: docUrl, withIntermediateDirectories:true, attributes: nil)
                } catch {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    

    func fetchAllFilesUnderAFolder(url: String) {
        let downloader = FileDownloader(url: url)
        downloader.sendGetRequest(completionHandler: onFileNamesGot)
    }
    
    func fetchAFile(url: String) {
        let downloader = FileDownloader(url: url)
        downloader.sendGetRequest(completionHandler: onFileNamesGot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllFilesUnderAFolder(dir: String) {
        let downloader = FileDownloader(url: "http://192.168.20.21:8081/RestWork/rs/dir?path=\(dir)")
        downloader.sendGetRequest {
            data, error in
            if data != nil {
                let outputStr  = String(data: data! as Data, encoding: String.Encoding.utf8) as String!
                print("data: \(outputStr)")
                //self.downloadTest()
            } else {
                print(error!)
            }
        }
    }
    
    func getAFile(fn: String) {
        let downloader = FileDownloader(url: "http://192.168.20.21:8081/RestWork/rs/dir")
        downloader.sendPostRequest (body:fn) {
            data, error in
            if data != nil {
                let outputStr  = String(data: data! as Data, encoding: String.Encoding.utf8) as String!
                print("data: \(outputStr)")
                let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                let dataPath: String = documentsUrl.appendingPathComponent("/MyFolder").absoluteString
                if !FileManager.default.fileExists(atPath: dataPath) {
                    try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
                }
                //write this file to document directory
                //outputStr?.write(to: URL, atomically: true, encoding: String.Encoding.utf8)
            } else {
                print(error!)
            }
        }
    }

    func loadHTML() {
        let s = """
                <html>
                <head>
                </head>
                <body>

                aaaaa
                <button type="button" onclick="test('sss')">asd</button>
                    <script>
                        var HostApp
                        function test(a) {
                            alert(a)
                            if(!HostApp) {
                                HostApp = window.webkit.messageHandlers.HostApp
                                HostApp.alert = function() {
                                    HostApp.postMessage({className: "Callme", functionName: "maybe"})
                                }
                            }
                            HostApp.postMessage({className: "Callme", functionName: "maybe"})
                            HostApp.alert()
                            return "asdgfkgkfkgf"
                        }
                        test('asd')
                    </script>
                </body></html>
            """
        wk.loadHTMLString(s, baseURL: nil)
    }
    
    
    func loadURL() {
        let urlString = "javascript:test({asd:'asd', 'def':5})"
        wk.evaluateJavaScript(urlString) { (result, error) in
            if result != nil {
                print(result!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let conf = WKWebViewConfiguration()
        conf.userContentController.add(self, name: "HostApp")
        self.wk = WKWebView(frame: CGRect(x: 0, y: 200, width: 400, height: 500), configuration: conf)
        self.wk.load(URLRequest(url: URL(string: "http://www.qq.com")!))
        self.view.addSubview(self.wk)
        self.wk.navigationDelegate = self
        self.wk.uiDelegate = self
        hostApp = MyHostApp()
        hostApp.setWebContext(WebViewContext(webView: self.wk))
        print(hostApp.classForCoder.description())
        //loadHTML()
        
        //download progress ui
        //createSpinner()
    }
    
    func downloadTest() {
        let downloader = FileDownloader(url: "http://192.168.20.21:8081/RestWork/rs/db/one/from%20t_singlevalue%20where%20name='appVer'")
        downloader.sendGetRequest {
            data, error in
            if data != nil {
                let dict = downloader.convertToDict(jsonStr: data!)
                print("dict: \(dict)")
                //self.downloadTest()
            } else {
                print(error!)
            }
        }
    }
    
    func downloadWithProgress() {
        let downloader = FileDownloader(url: "http://192.168.20.21:8081/RestWork/rs/db/one/from%20t_singlevalue%20where%20name='appVer'")
        downloader.httpGet()
    }

    func postRequestDownload() {
        let downloader = FileDownloader(url: "http://192.168.20.21:8081/RestWork/rs/db/meta2")
        var dict = Dictionary<String, Any>()
        dict["a"] = 1
        dict["b"] = "2"
        downloader.sendPostRequest(dict: dict) {
            data, error in
            if data != nil {
                let dict = downloader.convertToDict(jsonStr: data!)
                print("dict: \(dict)")
            } else {
                print(error!)
            }
        }
    }

    func createSpinner() {
        let replicatorLayer = CAReplicatorLayer()
        let r = self.view.bounds;
        
        // origin means top left corner
        replicatorLayer.frame = CGRect(origin: CGPoint(x: r.width/2-100, y: r.height/2-100), size: CGSize(width: 200, height: 200))
        
        replicatorLayer.instanceCount = 30
        replicatorLayer.instanceDelay = CFTimeInterval(1 / 30.0)
        replicatorLayer.preservesDepth = false
        replicatorLayer.instanceColor = UIColor.white.cgColor
        
        replicatorLayer.instanceRedOffset = 0.0
        replicatorLayer.instanceGreenOffset = -0.5
        replicatorLayer.instanceBlueOffset = -0.5
        replicatorLayer.instanceAlphaOffset = 0.0
        
        let angle = Float(Double.pi * 2.0) / 30
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        self.view.layer.addSublayer(replicatorLayer)
        
        let instanceLayer = CALayer()
        let layerWidth: CGFloat = 10.0
        let midX = self.view.bounds.midX - layerWidth / 2.0
        instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * 3.0)
        instanceLayer.backgroundColor = UIColor.white.cgColor
        replicatorLayer.addSublayer(instanceLayer)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        fadeAnimation.repeatCount = Float.greatestFiniteMagnitude
        
        instanceLayer.opacity = 0.0
        instanceLayer.add(fadeAnimation, forKey: "FadeAnimation")
        
        textLayer = CATextLayer()
        textLayer.frame = replicatorLayer.frame
        
        textLayer.string = "Taken for a ride"

        textLayer.foregroundColor = UIColor.darkGray.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        self.view.layer.addSublayer(textLayer)
    }
}

@objcMembers
class Callme: NSObject {
    func maybe() {
        print("反射成功！")
    }

    func log(_ data: String) {
        NSLog(data)
    }
    
    func log2(_ data: NSDictionary) ->NSDictionary {
        NSLog("log2 is invoked")
        print(data)
        return data
    }

    func log3(data: String) {
        NSLog(data)
    }

    func log4(data1: String, d2 data2: String) {
        NSLog(data1 + data2)
    }
    
    func log5(_ data1: String, d2 data2: String) {
        NSLog(data1 + data2)
    }

}
