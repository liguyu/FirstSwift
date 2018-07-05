//
//  Util.swift
//
//  Created by lgy on 2018/6/19.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

public class Util: NSObject {
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
    
    public class func convertToDict(jsonStr: String) -> NSDictionary {
        do {
            let str = jsonStr.data(using: .utf8)
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: str!, options: []) as? NSDictionary {
                
                return convertedJsonIntoDict
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return NSDictionary()
    }
    
    public class func nSDictionary2String(_ dict: NSDictionary) -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dict, options: []) {
            return String(data: theJSONData, encoding: .utf8)
        }
        return nil
    }
}

