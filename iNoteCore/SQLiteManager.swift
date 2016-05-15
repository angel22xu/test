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
        let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString
        
        // 获取数据库完整路径
        let path = documentPath.stringByAppendingPathComponent(dbName)
        print(path)
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
        
        print("打开数据库成功")
        
        // 创建一个索引表，有2个字段，日记ID，标题, 日期
        let sql1 = "CREATE TABLE IF NOT EXISTS  IndexConfig (noteID INTEGER PRIMARY KEY, title TEXT, dt TEXT)"

        
        //创建一个数据表，有3个字段，分别是 日记ID、内容，天气
        let sql2 = "CREATE TABLE IF NOT EXISTS  DataConfig (noteID INTEGER PRIMARY KEY, content TEXT ,  weather TEXT)"

        
        if createTable(sql1) && createTable(sql2){
            print("打开数据表成功")
        } else {
            print("打开数据表失败")
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
        
        
        print("sql: \(sql)")
        
        // 执行sql
        return execSQL(sql)
    }
}