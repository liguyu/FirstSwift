//
//  HostApp.swift
//
//  Created by lgy on 2018/6/14.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

/**
 * since xcode doesnt support enumerating all method names and their corresponding argument list
 * so the class should be self explanatory and provides all method signatures itself
 */
@objcMembers
public class HostApp: NSObject {
    var bridge: JSBridgeDelegate!
    
    // 由于swift对反射支持有限，需要每个类提供调用的signature
    // 函数写法以js为准， 返回值包括四类void, number, string, json
    public func getJSSignatures() -> [String] {
        return ["alert(s):void",
                "getAppVersion():number",
                "test(s):string",
                "getAppContext():json"]
    }
    
    public func alert(_ dict: NSDictionary) {
        
    }
    
    public func getAppVersion(_ dict: NSDictionary) -> Int32 {
        return 1
    }
    
    public func test(_ dict:NSDictionary) -> String {
        print(dict)
        return "The meaning of life is 42"
    }
    
    public func setBridge(bridge: JSBridgeDelegate) {
        self.bridge = bridge
    }
}

@objcMembers
public class MyHostApp: HostApp {
    public override func getJSSignatures() -> [String] {
        var remarks = super.getJSSignatures()
        remarks.append("echo(json):json")
        return remarks
    }
    
    public func echo(_ dict: NSDictionary) -> NSDictionary {
        return dict
    }
    
}
