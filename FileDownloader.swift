//
//  FileDownloader.swift
//  test
//
//  Created by apple on 2018/6/4.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit



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
