//
//  SqliteHelper.swift
//
//  Created by lgy on 2018/6/19.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SQLite

class AtomicInteger {
    
    private let lock = DispatchSemaphore(value: 1)
    private var value = 0
    
    public func get() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        return value
    }
    
    public func set(_ newValue: Int) {
        
        lock.wait()
        defer { lock.signal() }
        value = newValue
    }
    
    public func incrementAndGet() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        value += 1
        return value
    }
}

public class DBManager{
    var openCounter: AtomicInteger = AtomicInteger()
    static var con: Connection!
    static var sqlExecutor: SqliteHelper!
    
    private static let lock = DispatchSemaphore(value: 1)

    /*
     swift constructor
    */
    init (dbName: String) {
        if(DBManager.sqlExecutor == nil) {
            DBManager.sqlExecutor = SqliteHelper()
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            // brutal and hardcore 简单粗暴
            DBManager.con = try! Connection("\(path)/\(dbName)")
        }
    }

    class func close() {
        lock.wait()
        defer {
            lock.signal()
        }
        DBManager.close()
    }

    class func hasTable(tableName: String) throws -> Bool {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.hasTable(con: con, tableName: tableName)
    }
    
    class func getDoubleScalar(sql: String) throws -> Double {
        lock.wait()
        defer {
            lock.signal()
        }
        let d = try sqlExecutor.getScalar(con: con, sql: sql)
        return d as! Double
    }

    class func getIntScalar(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try Int(truncatingIfNeeded: (sqlExecutor.getScalar(con: con, sql: sql)) as! Int64)
    }

    class func hasResultSet(sql: String) throws -> Bool {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.hasResultSet(con: con, sql: sql)
    }
    
    /*
     run sql
     */
    class func straightExecute(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.straightInsert(con: con, sql: sql)
    }
    
    /*
     run sql
     */
    class func update(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.update(con: con, sql: sql)
    }
    
    /*
     run sql
     */
    class func delete(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.delete(con: con, sql: sql)
    }
    
    /*
     insert return autoid
     */
    class func autoIdInsert(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.autoIdInsert(con: con, sql: sql)
     }
    
    /*
     insert return autoid
     */
    class func straightInsert(sql: String) throws -> Int {
        lock.wait()
        defer {
            lock.signal()
        }
        return try sqlExecutor.straightInsert(con: con, sql: sql)
    }
    
    /*
        get column meta data
    */
    class func queryTableColumns(tableName: String) throws -> [String : String] {
        lock.wait()
        defer {
            lock.signal()
        }
        var result = [String : String]()
        let stmt = try con.prepare("pragma table_info (\(tableName))")
        for row in stmt {
            result[row[stmt.columnNames.index(of: "name")!] as! String] = row[stmt.columnNames.index(of: "type")!] as? String
        }
        return result
    }
    /*
     
     */
    class func query(sql: String) throws -> [[String: Any?]] {
        lock.wait()
        defer {
            lock.signal()
        }
        var result = [[String: Any?]]()
        let stmt = try con.prepare(sql)
        for row in stmt {
            var record = [String: Any?]()
            for i in 0..<stmt.columnCount {
                record[stmt.columnNames[i]] = row[i]
            }
            result.append(record)
        }
        return result
    }
    
}


class SqliteHelper: NSObject {
    
    /*
     has a table with tableName
    */
    func hasTable(con: Connection, tableName: String) throws -> Bool {
        do {
            let stmt = try con.prepare("SELECT count(*) FROM sqlite_master WHERE type='table' AND name='\(tableName)'")
            let count = try stmt.scalar() as! Int64
            return count > 0
        } catch let error {
            throw RuntimeException.error("执行hasTable出错:\(error)")
        }
    }

    /*
     get scalar of aggregation
    */
    func getScalar(con: Connection, sql: String) throws -> Any? {
        do {
            let stmt = try con.prepare(sql)
            return try stmt.scalar()
        } catch let error {
            throw RuntimeException.error("执行getScalar出错:\(error)")
        }
    }
    
    /*
     if sql has result
     */
    func hasResultSet(con: Connection, sql: String) throws -> Bool {
        do {
            let stmt = try con.prepare(sql)
            for _ in stmt {
                return true
            }
            return false
        } catch let error {
            throw RuntimeException.error("执行hasResultSet出错:\(error)")
        }
    }
    
    /*
     run sql
     */
    func straightExecute(con: Connection, sql: String) throws -> Int {
        do {
            try con.execute(sql)
            return con.changes
        } catch let error {
            throw RuntimeException.error("执行straightExecute出错:\(error)")
        }
    }

    /*
     run sql
    */
    func update(con: Connection, sql: String) throws -> Int {
        do {
            try con.execute(sql)
            return con.changes
        } catch let error {
            throw RuntimeException.error("执行update出错:\(error)")
        }
    }

    /*
     run sql
     */
    func delete(con: Connection, sql: String) throws -> Int {
        do {
            try con.execute(sql)
            return con.changes
        } catch let error {
            throw RuntimeException.error("执行delete出错:\(error)")
        }
    }

    /*
     insert return autoid
     */
    func autoIdInsert(con: Connection, sql: String) throws -> Int {
        do {
            try con.execute(sql)
            return Int(truncatingIfNeeded: con.lastInsertRowid)
        } catch let error {
            throw RuntimeException.error("执行autoIdInsert出错:\(error)")
        }
    }

    /*
     insert return autoid
     */
    func straightInsert(con: Connection, sql: String) throws -> Int {
        do {
            try con.execute(sql)
            return con.changes
        } catch let error {
            throw RuntimeException.error("执行straightInsert出错:\(error)")
        }
    }

}


