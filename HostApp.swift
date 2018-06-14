//
//  HostApp.swift
//  test
//
//  Created by apple on 2018/6/14.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

/**
 * since xcode doesnt support enumerating all method names and their corresponding argument list
 * so the class should be self explanatory and provides all method signatures itself
 */
@objcMembers
public class HostApp: NSObject {
    var wvContext: WebViewContext!
    
    // 由于swift对反射支持有限，需要每个类提供调用的signature
    public func getAnnations() -> [String] {
        return ["HostApp::alert(String):Void",
                "HostApp::getAppVersion():Int32",
                "MyHostApp::test(String):Int32"]
    }
    
    public func alert(msg: String) {
        
    }
    
    public func getAppVersion(msg: String) -> Int32 {
        return 1
    }
    
    public func test(_ msg:NSDictionary) -> NSDictionary{
        print(msg)
        return msg
    }
    
    public func setWebContext(_ wvContext: WebViewContext) {
        self.wvContext = wvContext
    }
}

@objcMembers
public class MyHostApp: HostApp {
    public override func getAnnations() -> [String] {
        var remarks = super.getAnnations()
        remarks.append("MyHostApp::echo(json):json")
        return remarks
    }
    
    public func echo(json: [String: Any]) -> [String: Any] {
        return json
    }
    
}
