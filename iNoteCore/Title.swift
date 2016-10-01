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
    
    // 提醒标题
    var subtitle: String = ""
    
    // 提醒标记，0默认值，1表示开启
    var redminderFlag: Int = 0
    
    // 提醒时间
    var redminerDT: String  = ""
    
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
        let sql = "INSERT INTO IndexConfig (noteID, title, dt, delFlag, subtitle, redminderFlag, redminerDT) VALUES (\(noteID), '\(title!)', '\(dt!)', \(delFlag), '\(subtitle)', \(redminderFlag), '\(redminerDT)');"
        
        // 使用单例插入数据
        return SQLiteManager.sharedManager.execSQL(sql)
    }

    /**
     更新模型数据到数据库
     returns:  是否更新成功
     */
    func updateTitle() -> Bool {
        // 断言
        assert(noteID > 0, "noteID 不正确")
        
        // 生成sql语句
        let sql = "UPDATE IndexConfig set title = '\(title!)', dt = \(dt!) WHERE noteID = \(noteID)"
        
        // 执行sql
        return SQLiteManager.sharedManager.execSQL(sql)
    }

    /**
     更新模型数据到数据库
     returns:  是否更新成功
     */
    func updateSubtitle() -> Bool {
        // 断言
        assert(noteID > 0, "noteID 不正确")
        
        // 生成sql语句
        let sql = "UPDATE IndexConfig set subtitle = '\(subtitle)', redminderFlag = \(redminderFlag), redminerDT='\(redminerDT)' WHERE noteID = \(noteID)"
        
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
     更新模型数据到数据库, 改变删除标志
     returns:  是否更新成功
     */
    static func closeReminder(nid: Int) -> Bool {
        
        // 生成sql语句
        let sql = "UPDATE IndexConfig set redminderFlag = \(Constant.REMINDER_OFF), redminerDT = '' WHERE noteID = \(nid)"
        
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
     查找对象
     - returns: Title数组
     */
    class func loadTitles() -> [Title]? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, title, dt, subtitle,redminderFlag, redminerDT FROM IndexConfig WHERE delFlag=0 ORDER BY dt DESC;"
        
        // 2.执行sql语句,返回查询结果
        guard let array = SQLiteManager.sharedManager.execRecordSet(sql) else {
            print("没有查询到数据")
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
     查找对象
     - returns: Title
     */
    class func loadTitle(nid: Int) -> Title? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, title, dt, subtitle, redminderFlag, redminerDT FROM IndexConfig WHERE delFlag=0 and noteID=\(nid)"
        
        // 2.执行sql语句,返回查询结果
        
        let rt = SQLiteManager.sharedManager.recordDictBySQL(sql)
        
        return Title(dict: rt)
    }

    
    /**
     查找已经被删除的对象
     - returns: Title数组
     */
    class func loadDeletedTitles() -> [Title]? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, title, dt, subtitle, redminderFlag, redminerDT FROM IndexConfig WHERE delFlag=1;"
        
        // 2.执行sql语句,返回查询结果
        guard let array = SQLiteManager.sharedManager.execRecordSet(sql) else {
            print("没有查询到数据")
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
        let properties = ["noteID", "title", "dt", "subtitle"]
        return "title: \n \t \(dictionaryWithValuesForKeys(properties)) \n"
    }
}