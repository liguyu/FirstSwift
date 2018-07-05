//
//  DBMeta.swift
//  test
//
//  Created by apple on 2018/6/20.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class DBMeta: NSObject {
    static var metaMap: [String:Any?]!
    static var entityLiftMap: [String:Any?]!
    
    static var COL_STRING = "STRING";
    static var COL_DATE = "DATE";
    static var COL_TIME = "TIME";
    static var COL_BOOLEAN = "BOOLEAN";
    static var COL_NUMBER = "NUMBER";
    static var COL_NOTSUPPORTED = "NOT_SUPPORTED";
    
    static var ID_GUID = "ID_GUID";
    static var ID_SEQ = "ID_SEQ";
    static var ID_AUTO = "ID_AUTO";
    static var ID_ASSIGNED = "ID_ASSIGNED";
    static var ID_FOREIGNER = "ID_FOREIGNER";
    
    class func saveMeta(dict: NSDictionary) throws {
        let s = Util.nSDictionary2String(dict)!
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path.appendPathComponent("meta.json")
        try s.write(to: path, atomically: true, encoding: .utf8)
    }
    
    class func getMeta() throws -> [String : Any?] {
        if metaMap != nil {
            return DBMeta.metaMap
        } else {
            var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            path.appendPathComponent("meta.json")
            let s = try String(contentsOf: path, encoding: .utf8)
            return Util.convertToDict(jsonStr: s) as! [String : Any?]
        }
    }
    
    class func populateMaps(data: NSDictionary) {
        var dict = data as! Dictionary<String, Any?>
        metaMap = [:]
        entityLiftMap = [:]
        for (key, value) in dict {
            if key == "_entityLiftMap_" {
                metaMap[key] = value
                entityLiftMap[key] = value
            } else {
                let entityDict = dict[key] as! Dictionary<String, Any?>
                let entityMap = populateEntities(entityDict: entityDict)
                metaMap[key] = entityMap
            }
        }
    }
    
    class func populateEntities(entityDict: Dictionary<String, Any?>) -> Dictionary<String, Any?>{
        var dict: Dictionary<String, Any?> = [:]
        for (key, value) in entityDict {
            if key == "entityName" || key == "idName" || key == "idColName" || key == "idType" || key == "verName"
                || key == "verColName" || key == "verType" || key == "sequence" {
                dict[key] = value
            } else if key == "idGenerator" {
                let v = value as! String
                if v == "ID_SEQ" {
                    dict[key] = "ID_AUTO"
                } else {
                    dict[key] = value
                }
            } else if key == "tableName" {
                let v = value as! String
                if v.contains(".") {
                    let start = v.index(v.index(of: ".")!, offsetBy: 1)
                    let noSchemaV = v.suffix(from: start)
                    dict[key] = String(noSchemaV)
                } else {
                    dict[key] = v
                }
            } else if key == "columns" || key == "links" || key == "onetoone" || key == "onetomant" || key == "associations" ||
                key == "inverseid" || key == "subclasses" {
                let pairs = value as! Dictionary<String, Any?>
                let tpairs = transformPairs(pairs: pairs)
                dict[key] = tpairs
            } else if key == "inverses" {
                let cols = value as! Dictionary<String, Any?>
                let inverses = transformCols(cols: cols)
                dict[key] = inverses
            }
        }
        return dict
    }
    
    class func transformPairs(pairs: Dictionary<String, Any?>) -> Dictionary<String, Any?> {
        var dict: Dictionary<String, Any?> = [:]
        for (key, value) in pairs {
            if value is String {
                let pair = value as! String
                let colType = pair.split(separator: ":")
                let col = String(colType[0].suffix(from: colType[0].index(colType[0].startIndex, offsetBy: 1)))
                let type = String(colType[1].prefix(colType[1].count-1))
                dict[key] = [col : type]
            } else {
                dict[key] = value
            }
        }
        return dict
    }
    
    class func transformCols(cols: Dictionary<String, Any?>) -> Dictionary<String, Any?> {
        var dict: Dictionary<String, Any?> = [:]
        for (key, value) in cols {
            dict[key] = value
        }
        return dict
    }
    
    /*
     模式化数据类型
    */
    class func normalizeColType(colType: String) -> String {
            return "TEXT"
    }

    class func queryTableColumns(tableName: String) throws -> [String : String] {
        return try DBManager.queryTableColumns(tableName:tableName)
    }
}
