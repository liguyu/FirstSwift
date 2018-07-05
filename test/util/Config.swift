//
//  Config.swift
//
//  Created by lgy on 2018/6/19.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

public class Config: NSObject {
    
    public class func initConfig() {
        //Caution!!! json object in App.config must be in strict syntatic form
        let path = Bundle.main.path(forResource: "App", ofType: "config")
        do {
            let content = try String(contentsOfFile: path!, encoding: .utf8)
            let data = content.data(using: .utf8)
            let config = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! [String: Any]
            let preferences = UserDefaults.standard
            for (key, value) in config {
                if preferences.object(forKey: key) == nil {
                    preferences.set(value, forKey: key)
                }
            }
            preferences.synchronize()
        } catch {
            print("加载配置文件出错！")
        }
    }
    
    public class func get(key: String) -> Any? {
        return UserDefaults.standard.object(forKey:key) 
    }

    public class func set(key: String, value: Any?) {
        let preferences = UserDefaults.standard
        preferences.set(value, forKey: key)
        preferences.synchronize()
    }

}
