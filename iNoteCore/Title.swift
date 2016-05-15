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
        let sql = "INSERT INTO IndexConfig (noteID, title, dt) VALUES (\(noteID), '\(title!)', '\(dt!)');"
        
        print("插入sql: \(sql)")
        
        // 使用单例插入数据
        return SQLiteManager.sharedManager.execSQL(sql)
    }
}