//
//  Tool.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/15.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import Foundation

class Tool: NSObject {
    
    //获取当前日期时间
    static func getCurrentDateStr()->String{
        let nowDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = formatter.stringFromDate(nowDate)
        print(dateString)
        return dateString
    }
    
    
    //字符串转换日期时间
    static func getCurrentDate(dateString1: String) -> NSDate {
        let formatter1 = NSDateFormatter()
        formatter1.dateFormat = "yyyy-M-d"
        let date1 = formatter1.dateFromString(dateString1)
        print(date1)
        return date1!
    }
    
    //日期转换字符串
    static func getCurDatetimeStr() -> String{
        let date2 = NSDate()
        let formatter2 = NSDateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd"
        let dateString2 = formatter2.stringFromDate(date2)
        print(dateString2)
        return dateString2
    }
    
}
