//
//  Content.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/15.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import Foundation


class Content : NSObject {
    
    // 日志ID
    var noteID: Int = 0
    
    // 标题
    var content: String?
    
    //天气
    var weather: String?
    
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
    func updateContent() -> Bool {
        // 拼接sql语句, String类型需要用''引起来
//        print ("noteID: \(noteID), content: \(content!), weather: \(weather!)")

        let sql = "REPLACE INTO DataConfig (noteID, content, weather) VALUES (\(noteID), '\(content!)', '\(weather!)');"
        
//        print("插入sql: \(sql)")
        
        // 使用单例插入数据
        return SQLiteManager.sharedManager.execSQL(sql)
    }
    /**
     查找对象
     - returns: Content数组
     */
    class func loadContents(noteID: Int) -> [Content]? {
        // 1. 成成sql语句
        let sql = "SELECT noteID, content, weather FROM DataConfig WHERE noteID=\(noteID);"
        
        print(sql)
        // 2.执行sql语句,返回查询结果
        guard let array = SQLiteManager.sharedManager.execRecordSet(sql) else {
            print("没有查询content到数据")
            return nil
        }
        
        // 定义存放模型的数组
        var arrayM = [Content]()
        
        // 3. 遍历数组，字典转模型
        for dict in array {
            let temp = Content(dict: dict)
            
            // 将对象添加到数组
            arrayM.append(temp)
        }
        
        return arrayM
    }
}