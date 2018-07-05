//
//  SynDBDelegate.swift
//
//  Created by lgy on 2018/6/15.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SQLite

class SyncDBDelegate: NSObject {
    private var dbName: String
    
    init(dbName: String) {
        self.dbName = dbName
    }
    
    /*
     create db using ready-made script
     */
    public func createDBByScript(sql: String) {
        do {
            let _ = DBManager(dbName: dbName)
            let sqls = sql.split(separator: "\n")
            for statement in sqls {
                let _ = try DBManager.straightInsert(sql: String(statement))
            }
        } catch {
            print("生成数据库出错")
        }
    }
    
    public func sync(url: String) -> Bool {
        return HttpDelegate.syncPost(url: url, body: nil, respondResult: onMetaGot)
    }
    
    func onMetaGot(data: Data?) -> Bool {
        if data == nil {
            return false
        } else {
            let dict = Util.convertToDict(jsonStr: data!)
            do {
                DBMeta.populateMaps(data: dict)
                try DBMeta.saveMeta(dict: dict)
                let _ = try createOrUpdateDB(dbName: dbName)
                print("建库完成")
                return true
            } catch let e {
                print("创建数据库出错：\(e)")
                return false
            }
        }
    }
    
    func createOrUpdateDB(dbName: String) throws -> Bool {
        
        let _ = DBManager(dbName: dbName)
        let entities = Config.get(key: "entities") as! [String]
        // create or update tables
        for entity in entities {
            try createOrUpdateTable(entity: entity.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        // create or update associations
        for entity in entities {
            createOrUpdateLinkColumns(entity: entity.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return true
    }
    
    func createOrUpdateLinkColumns(entity: String) {
        let meta = DBMeta.metaMap[entity] as! [String: Any?]
        let tableName = meta["tableName"] as! String
        do {
            let tableColumns = try DBMeta.queryTableColumns(tableName: tableName)
            let associations = meta["associations"]
            print("更新表关联：\(tableName)")
            if associations == nil {
                return
            } else {
                let links = associations as! [String : Any?]
                for (_, value) in links {
                    let pair = Array(value as! Dictionary<String, String>)
                    if tableColumns.keys.contains(pair[0].key.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        continue
                    }
                    let sql = "ALTER TABLE \(tableName) ADD \(pair[0].key) \(DBMeta.normalizeColType(colType: pair[0].value))"
                    let _ = try DBManager.straightExecute(sql:sql)
                }
            }
        } catch let e {
            print("生成或更新链接出错：\(e)")
        }
    }
    
    func createOrUpdateTable(entity:  String) throws{
        if !DBMeta.metaMap.keys.contains(entity) {
            throw RuntimeException.error("不存在实体\(entity)")
        }
        let meta = DBMeta.metaMap[entity] as! [String: Any?]
        let tableName = meta["tableName"] as! String
        if try DBManager.hasTable(tableName: tableName) {
            print("更新表：\(tableName)")
            try updateTable(meta: meta, tableName: tableName)
        } else {
            print("创建表：\(tableName)")
            try createTable(meta: meta, tableName: tableName)
        }
    }
    
    func updateTable(meta: Dictionary<String, Any?>, tableName: String) throws {
        let tableColumns = try DBMeta.queryTableColumns(tableName: tableName)
        let metaColumns = getColumnsFromMeta(meta: meta)
        // 如果列不在表中
        for (key, value) in metaColumns {
            if !tableColumns.keys.contains(key) {
                let _ = try DBManager.straightExecute(sql: "ALTER TABLE \(tableName) ADD \(key) \(value)")
            }
        }
    }

    func getColumnsFromMeta(meta: [String : Any?]) -> [String : String] {
        var ret = [String : String]()
        let columns = meta["columns"] as! Dictionary<String, Any?>
        for (_, value) in columns {
            let pair = Array(value as! Dictionary<String, String>)
            ret[pair[0].key.trimmingCharacters(in: .whitespacesAndNewlines)] = DBMeta.normalizeColType(colType: pair[0].value)
        }
        return ret
    }
    
    func createTable(meta: Dictionary<String, Any?>, tableName: String) throws {
        let columns = meta["columns"] as! Dictionary<String, Any?>
        let idColName = meta["idColName"] as! String
        let idGenerator = meta["idGenerator"] as! String
        var sql = "CREATE TABLE \(tableName) ("
        for (_, value) in columns {
            let pair = Array(value as! Dictionary<String, String>)
            sql += " \(pair[0].key.trimmingCharacters(in: .whitespacesAndNewlines)) \(DBMeta.normalizeColType(colType: pair[0].value)) , "
        }
        if idGenerator == DBMeta.ID_AUTO || idGenerator == DBMeta.ID_SEQ {
            sql += " \(idColName) INTEGER PRIMARY KEY AUTOINCREMENT )"
        } else {
            sql += " \(idColName) TEXT PRIMARY KEY )"
        }
        print("生成表\(tableName)sql:\(sql)")
        let _ = try DBManager.straightExecute(sql: sql)
    }
    
}
