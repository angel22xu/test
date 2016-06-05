//
//  Title.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/15.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import Foundation

class Title : NSObject {
    
    // 日志ID
    var noteID: Int = 0
    
    // 标题
    var title: String?
    
    //时间
    var dt: String?
    
    //删除标志, 0默认值，1表示扔进垃圾箱的数据
    var delFlag: Int = 0
    
    // 字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}

    /**
     将对象添加到数据库
     - returns: 是否插入成功
     */
    func insertTtile() -> Bool {
        // 拼接sql语句, String类型需要用''引起来
        let sql = "INSERT INTO IndexConfig (noteID, title, dt, delFlag) VALUES (\(noteID), '\(title!)', '\(dt!)', \(delFlag));"
        
        print("插入sql: \(sql)")
        
        // 使用单例插入数据
        return SQLiteManager.sharedManager.execSQL(sql)
    }

    /**
     更新模型数据到数据库
     returns:  是否更新成功
     */
    func updateTitle() -> Bool {
        print ("update title sql title: \(title), noteID: \(noteID)")

        // 断言
        assert(noteID > 0, "noteID 不正确")
        
        // 生成sql语句
        let sql = "UPDATE IndexConfig set title = '\(title!)', dt = \(dt!) WHERE noteID = \(noteID)"
        
        print ("update title sql: \(sql)")
        
        // 执行sql
        return SQLiteManager.sharedManager.execSQL(sql)
    }

    /**
     更新模型数据到数据库, 改变删除标志
     returns:  是否更新成功
     */
    func updateStaus() -> Bool {
        // 断言
        assert(noteID > 0, "noteID 不正确")
        
        // 生成sql语句
        let sql = "UPDATE IndexConfig set delFlag = \(delFlag), dt = \(dt!) WHERE noteID = \(noteID)"
        
        // 执行sql
        return SQLiteManager.sharedManager.execSQL(sql)
    }
    
    
    /**
     删除模型对应数据库中的记录
     returns: 是否删除成功
     */
    func deleteTitle() -> Bool {
        // 断言
        assert(noteID > 0, "noteID 不正确")
        
        // 生成sql
        let sql = "DELETE FROM IndexConfig WHERE noteID = \(noteID)"
        
        return SQLiteManager.sharedManager.execSQL(sql)
    }
    
    /**
     // 插入大批量数据
     */
    func testManyInsert() {
        
        // 开始插入时间
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 开启事务
        SQLiteManager.sharedManager.execSQL("BEGIN TRANSACTION")
        
        // 插入10000条数据
        for i in 0..<10000 {
            // 创建对象
            let p = Title(dict: ["noteID": 2324, "title": "20121205", "dt": "20121205"])
            
            // 如果没有手动开启事务,默认执行每条INSERT / UPDATE/ DELETE语句会自动开启事务.执行完毕后自动提交事务
            // 插入数据
            p.insertTtile()
            
            // 模拟事务失败
            if i == 1000 {
                // 回滚事务.回到开启事务时的状态
                SQLiteManager.sharedManager.execSQL("ROLLBACK TRANSACTION")
                break
            }
        }
        
        // 提交事务, 不管成功还是失败都需要提交事务
        SQLiteManager.sharedManager.execSQL("COMMIT TRANSACTION")
        
        let endTime = CFAbsoluteTimeGetCurrent()
        print("消耗时间: \(endTime - startTime)")
    }
    
    /**
     查找对象
     - returns: Title数组
     */
    class func loadTitles() -> [Title]? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, title, dt FROM IndexConfig WHERE delFlag=0 ORDER BY dt DESC;"
        
        // 2.执行sql语句,返回查询结果
        guard let array = SQLiteManager.sharedManager.execRecordSet(sql) else {
//            print("没有查询到数据")
            return nil
        }
        
        // 定义存放模型的数组
        var arrayM = [Title]()
        
        // 3. 遍历数组，字典转模型
        for dict in array {
            let temp = Title(dict: dict)
            
            // 将对象添加到数组
            arrayM.append(temp)
        }
        
        return arrayM
    }
    /**
     查找已经被删除的对象
     - returns: Title数组
     */
    class func loadDeletedTitles() -> [Title]? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, title, dt FROM IndexConfig WHERE delFlag=1;"
        
        // 2.执行sql语句,返回查询结果
        guard let array = SQLiteManager.sharedManager.execRecordSet(sql) else {
            //            print("没有查询到数据")
            return nil
        }
        
        // 定义存放模型的数组
        var arrayM = [Title]()
        
        // 3. 遍历数组，字典转模型
        for dict in array {
            let temp = Title(dict: dict)
            
            // 将对象添加到数组
            arrayM.append(temp)
        }
        
        return arrayM
    }

    // 对象打印方法
    override var description: String {
        let properties = ["noteID", "title", "dt"]
        return "title: \n \t \(dictionaryWithValuesForKeys(properties)) \n"
    }
}