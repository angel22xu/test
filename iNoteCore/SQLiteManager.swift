//
//  SQLiteManager.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/15.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import Foundation

/// SQLite 管理器
class SQLiteManager {
    
    /// 单例
    static let sharedManager = SQLiteManager()

    // 数据库句柄: COpaquePointer(含糊的指针)通常是一个结构体指针
    private var db: COpaquePointer = nil
    
    //默认数据库名
    static let DBFILE_NAME = "psList.sqlite3"

    
    /**
     打开数据库 DB(DataBase)
     - parameter dbName: 数据库名称
     */
    func openDB(dbName: String = DBFILE_NAME) {
        // 获取沙盒路径
        let documentPath = Tool.getDocumentPath()
        
        // 获取数据库完整路径
        let path = documentPath.stringByAppendingPathComponent(dbName)
        print("db path: \(path)")
        /*
         参数:
         1.fileName: 数据库完整路径
         2.数据库句柄:
         返回值:
         Int
         SQLITE_OK 表示打开数据库成功
         
         注意:
         1.如果数据库不存在,会创建数据库,再打开
         2.如果存在,直接打开
         */
        //        sqlite3_open(path.cStringUsingEncoding(NSUTF8StringEncoding)!, &db)
        // 创建数据表

        
        
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("打开数据库失败")
            return
        }
        
//        print("打开数据库成功")
        
        // 创建一个索引表，有2个字段，日记ID，标题, 日期
        let sql1 = "CREATE TABLE IF  NOT EXISTS  IndexConfig (noteID INTEGER PRIMARY KEY, title TEXT, dt TEXT, delFlag INTEGER, subtitle TEXT, redminderFlag INTEGER, redminerDT TEXT)"

        
        //创建一个数据表，有3个字段，分别是 日记ID、内容，天气
        let sql2 = "CREATE TABLE IF  NOT EXISTS  DataConfig (noteID INTEGER PRIMARY KEY, content TEXT ,  weather TEXT)"

//        let sql1 = "CREATE TABLE IF NOT EXISTS  IndexConfig (noteID INTEGER PRIMARY KEY, title TEXT, dt TEXT, delFlag INTEGER)"
//        
//        
//        //创建一个数据表，有3个字段，分别是 日记ID、内容，天气
//        let sql2 = "CREATE TABLE IF NOT EXISTS  DataConfig (noteID INTEGER PRIMARY KEY, content TEXT ,  weather TEXT)"


        if createTable(sql1) && createTable(sql2){
            print("打开数据表成功")
        } else {
            print("打开数据表失败")
            dropTable("DROP TABLE IndexConfig")
            dropTable("DROP TABLE DataConfig")
        }
    }

    /**
     执行sql语句
     - parameter sql: sql语句
     - returns: sql语句是否执行成功
     */
    func execSQL(sql: String) -> Bool {
        /**
         sqlite执行sql语句:
         
         参数:
         1.COpaquePointer: 数据库句柄
         2.sql: 要执行的sql语句
         3.callback: 执行完成sql后的回调,通常为nil
         4.UnsafeMutablePointer<Void>: 回调函数第一个参数的地址,通常为nil
         5.错误信息的指针,通常为nil
         
         返回值:
         Int:    SQLITE_OK表示执行成功
         */
        return (sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK)
    }

    // MARK: - 创建数据表
    private func createTable(sql: String) -> Bool {
        
        
//        print("sql: \(sql)")
        
        // 执行sql
        return execSQL(sql)
    }

    // MARK: - 创建数据表
    private func dropTable(sql: String) -> Bool {
        
        
        //        print("sql: \(sql)")
        
        // 执行sql
        return execSQL(sql)
    }
    
    /**
     获取单条记录
     - parameter stmt: 准备语句对象
     - returns: 单条记录对应的字典
     */
    private func recordDict(stmt: COpaquePointer) -> [String: AnyObject] {
        // 定义字典, 存放一条记录
        var dict = [String: AnyObject]()
        // 获取记录的字段数
        let columnCount = sqlite3_column_count(stmt)
        // 获取每个字段的名称,类型和内容
        for i in 0..<columnCount {
            // 获取字段的名称
            let cName = sqlite3_column_name(stmt, i)
            let name = String(CString: cName, encoding: NSUTF8StringEncoding)!
//            print("字段\(i): 名称:\(name)")
            
            // 获取字段类型
            let type = sqlite3_column_type(stmt, i)
//            print("字段\(i): 类型:\(type)")
            
            
            // 根据字段类型,获取字段的值
            var value: AnyObject? = nil
            switch type {
            case SQLITE_INTEGER:
                value = Int(sqlite3_column_int64(stmt, i))
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt, i)
            case SQLITE_TEXT:
                // UnsafePointer<Uint8> -> UnsafePointer<CChar>
                let cValue = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
                value = String(CString: cValue, encoding: NSUTF8StringEncoding)
            case SQLITE_NULL:
                // OC的字典和数组对象中不允许插入nil.可以插入NSNull
                value = NSNull()
            default:
                print("不支持的类型")
            }
            // 将获取到的字段存放到字典中
            dict[name] = value ?? NSValue()
//            print("字段\(i): 名称:\(name), 值:\(value)")
        }
//        print("dict:    \(dict)")
//        print("-------")
        return dict
    }

    /**
     执行查询的SQL语句,获取查询的结果集
     - parameter sql: 查询数据的SQL语句
     - returns: 字典数组
     */
    func execRecordSet(sql: String) -> [[String: AnyObject]]?{
        
        // 准备语句对象
        var stmt: COpaquePointer = nil
        
        /*
         准备sql语句,返回准备语句对象(preapred_statement)
         
         参数:
         1.db: 数据库句柄
         2.zSql: sql语句
         3.nByte: sql语句的字节长度, -1 能够自动计算长度
         4.ppStmt: 准备语句对象,通过这个对象可以获取到记录.需要释放的
         5.pzTail: 未执行的sql语句,通常为nil
         */
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
//            print("sql语句有错误,准备失败")
            return nil
        }
        
//        print("sql语句正确,准备完毕")
        
        // 定义字典数组,存放整个查询结果
        var recordSet = [[String: AnyObject]]()
        
        // sqlite3_step(): 单步执行,每执行一次获取到一条记录, SQLITE_ROW表示获取到一行记录
        while sqlite3_step(stmt) == SQLITE_ROW {
            
            // 将查询到的一条记录存放到数组中
            recordSet.append(recordDict(stmt))
        }
        
        // 释放准备语句对象
        sqlite3_finalize(stmt)
        
        return recordSet
    }
    
    
    /**
     获取单条记录
     - parameter stmt: 准备语句对象
     - returns: 单条记录对应的字典
     */
    func recordDictBySQL(sql: String) -> [String: AnyObject] {
        
        // 准备语句对象
        var stmt: COpaquePointer = nil
        
        /*
         准备sql语句,返回准备语句对象(preapred_statement)
         
         参数:
         1.db: 数据库句柄
         2.zSql: sql语句
         3.nByte: sql语句的字节长度, -1 能够自动计算长度
         4.ppStmt: 准备语句对象,通过这个对象可以获取到记录.需要释放的
         5.pzTail: 未执行的sql语句,通常为nil
         */
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("sql语句有错误,准备失败")
            return [:]
        }

        
        // 定义字典, 存放一条记录
        var dict = [String: AnyObject]()

        while sqlite3_step(stmt) == SQLITE_ROW{
            // 获取记录的字段数
            let columnCount = sqlite3_column_count(stmt)
            // 获取每个字段的名称,类型和内容
            for i in 0..<columnCount {
                // 获取字段的名称
                let cName = sqlite3_column_name(stmt, i)
                let name = String(CString: cName, encoding: NSUTF8StringEncoding)!
//                print("字段\(i): 名称:\(name)")
                
                // 获取字段类型
                let type = sqlite3_column_type(stmt, i)
//                print("字段\(i): 类型:\(type)")
                
                
                // 根据字段类型,获取字段的值
                var value: AnyObject? = nil
                switch type {
                case SQLITE_INTEGER:
                    value = Int(sqlite3_column_int64(stmt, i))
                case SQLITE_FLOAT:
                    value = sqlite3_column_double(stmt, i)
                case SQLITE_TEXT:
                    // UnsafePointer<Uint8> -> UnsafePointer<CChar>
                    let cValue = UnsafePointer<CChar>(sqlite3_column_text(stmt, i))
                    value = String(CString: cValue, encoding: NSUTF8StringEncoding)
                case SQLITE_NULL:
                    // OC的字典和数组对象中不允许插入nil.可以插入NSNull
                    value = NSNull()
                default:
                    print("不支持的类型")
                }
                // 将获取到的字段存放到字典中
                dict[name] = value ?? NSValue()
//                print("字段\(i): 名称:\(name), 值:\(value)")
            }
            
        }
        
//        print("dict:    \(dict)")
//        print("-------")

        // 释放准备语句对象
        sqlite3_finalize(stmt)

        return dict
    }
    
}