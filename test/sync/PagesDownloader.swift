//
//  PagesDownloader.swift
//
//  Created by lgy on 2018/6/14.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class PagesDownloader: NSObject {
    var restUrl: String
    var prefix: String!
    var newPrefix: String!
    
    init(restUrl: String) {
        self.restUrl = restUrl
        super.init()
    }
    
    public func setPrefix(prefix: String, newPrefix: String) {
        self.prefix = prefix.replacingOccurrences(of: "/", with: "\\")
        self.newPrefix = newPrefix
    }
    
    public func downloadWebSite(url: String) {
        HttpDelegate.syncGet(url: url, respondResult: onH5FileNamesGot)
    }
    
    func onH5FileNamesGot(data: Data?) ->Bool {
        if data != nil {
            if let fileNameDump  = String(data: data!, encoding: String.Encoding.utf8) as String? {
                let fileTimestampPair = fileNameDump.split(separator: "|")
                for fileTimestamp in fileTimestampPair {
                    let pair = fileTimestamp.split(separator: ",")
                    var fnWithNoDiskPrefix = newPrefix + String(pair[0][pair[0].index(pair[0].startIndex, offsetBy: prefix.count)...])
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
                    let b = HttpDelegate.syncPost(url: "\(restUrl)dir", body: String(pair[0])) {
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

    func populateBz() {
        
    }
}
