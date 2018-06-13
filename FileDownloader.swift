//
//  FileDownloader.swift
//  test
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

class SyncUrlDownload: NSObject {
    public class func syncGet(url: String, respondResult: @escaping (Data?) -> (Bool)) -> Bool {
        let aurl = URL(string: url)
        if aurl == nil {
            return false
        }
        var request = URLRequest(url: aurl!)
        request.httpMethod = "GET"
        let response = URLSession.shared.synchronousDataTask(urlrequest: request)
        if response.response == nil {
            NSLog("网络错误，请检查网络")
            return false
        }
        let sc = (response.response as! HTTPURLResponse).statusCode
        if response.error != nil || sc != 200 {
            if response.error  == nil {
                NSLog("错误码：%d", sc)
            } else {
                NSLog("请求发送出错：%s", response.error!.localizedDescription)
            }
            
            return false
        }
        return respondResult(response.data)
    }
    
    public class func syncPost(url: String, dict: Dictionary<String,Any>, respondResult: @escaping (Data?) -> (Bool)) -> Bool {
        let aurl = URL(string: url)
        if aurl == nil {
            return false
        }
        var request = URLRequest(url: aurl!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let response = URLSession.shared.synchronousDataTask(urlrequest: request)
        let sc = (response.response as! HTTPURLResponse).statusCode
        if response.error != nil || sc != 200 {
            if response.error  == nil {
                NSLog("错误码：%d", sc)
            } else {
                NSLog("请求发送出错：%s", response.error!.localizedDescription)
            }
            
            return false
        }
        return respondResult(response.data)
    }

    public class func syncPost(url: String, body: String, respondResult: @escaping (Data?) -> (Bool)) -> Bool {
        let aurl = URL(string: url)
        if aurl == nil {
            return false
        }
        var request = URLRequest(url: aurl!)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: String.Encoding.utf8)
        let response = URLSession.shared.synchronousDataTask(urlrequest: request)
        let sc = (response.response as! HTTPURLResponse).statusCode
        if response.error != nil || sc != 200 {
            if response.error  == nil {
                NSLog("错误码：%d", sc)
            } else {
                NSLog("请求发送出错：%s", response.error!.localizedDescription)
            }
            
            return false
        }
        return respondResult(response.data)
    }

    public class func convertToDict(jsonStr: Data) -> NSDictionary {
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: jsonStr, options: []) as? NSDictionary {
                
                return convertedJsonIntoDict
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return NSDictionary()
    }
}


class FileDownloader: NSObject, URLSessionDataDelegate {
    var downloadTask: URLSessionDownloadTask!
    var urlSession: URLSession!
    var url: String
    
    init(url: String) {
        self.url = url
        let configuration = URLSessionConfiguration.default
        super.init()
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // this will not work unless no completion callback is provided
        print("task got some data")
    }
    
    
    func convertToDict(jsonStr: NSData) -> NSDictionary {
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: jsonStr as Data, options: []) as? NSDictionary {
                
                return convertedJsonIntoDict
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return NSDictionary()
    }
    
    
    func sendGetRequest(completionHandler: @escaping (NSData?, NSError?) -> ()) -> URLSessionTask {
        
        let aurl = URL(string: self.url)
        
        var myRequest = URLRequest(url: aurl!)
        myRequest.httpMethod = "GET"

        let task = urlSession.dataTask(with: myRequest) {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if data != nil {
                    completionHandler(data! as NSData, nil)
                } else {
                    completionHandler(nil, error! as NSError)
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    func httpGet() {
        
        let aurl = URL(string: self.url)
        
        var myRequest = URLRequest(url: aurl!)
        myRequest.httpMethod = "GET"
        
        let task = urlSession.dataTask(with: myRequest)
        task.resume()
    }
    
    func sendPostRequest(dict: Dictionary<String,Any>, completionHandler: @escaping (NSData?, NSError?) -> ()) -> URLSessionTask {
        
        let aurl = URL(string: self.url)
        
        var myRequest = URLRequest(url: aurl!)
        myRequest.httpMethod = "POST"
        
        myRequest.httpBody = try! JSONSerialization.data(withJSONObject: dict, options: [])
        
        let task = urlSession.dataTask(with: myRequest) {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if data != nil {
                    completionHandler(data! as NSData, nil)
                } else {
                    completionHandler(nil, error! as NSError)
                }
            }
        }
        
        task.resume()
        
        return task
    }

    func sendPostRequest(body: String, completionHandler: @escaping (NSData?, NSError?) -> ()) -> URLSessionTask {
        
        let aurl = URL(string: self.url)
        
        var myRequest = URLRequest(url: aurl!)
        myRequest.httpMethod = "POST"
        
        myRequest.httpBody = body.data(using: .utf8)
        
        let task = urlSession.dataTask(with: myRequest) {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if data != nil {
                    completionHandler(data! as NSData, nil)
                } else {
                    completionHandler(nil, error! as NSError)
                }
            }
        }
        
        task.resume()
        
        return task
    }

}
