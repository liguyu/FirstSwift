//
//  HttpDelegate.swift
//  test
//
//  Created by apple on 2018/6/14.
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

class HttpDelegate: NSObject {
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

