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
    
    
    // 获取document路径
    static func getDocumentPath()->NSString{
        
        let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString
        
        return documentPath
    }
    
    
    
    /**
     生成随机字符串,
     
     - parameter length: 生成的字符串的长度
     
     - returns: 随机生成的字符串
     */
    static func getRandomStringOfLength(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.characters.count)))
            ranStr.append(characters[characters.startIndex.advancedBy(index)])
        }
        return ranStr
        
    }
    
    //处理时间字符串,yyyyMMddHHmmss
    static func formatDt(dtStr: String)-> String{

        
        //  获取当前时间
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month,
        NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute,NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: currentDate)

        // 数据库保存的时间
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.dateFromString(dtStr)
        let dateComponents1 = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month,
            NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Hour, NSCalendarUnit.Minute,NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: date!)
                
        //时间比较，今天的话，就显示具体小时分钟
        if (dateComponents.year == dateComponents1.year) && (dateComponents.month == dateComponents1.month) && (dateComponents.day == dateComponents1.day){
            formatter.dateFormat = "HH:mm"
            return  "Today \(formatter.stringFromDate(date!))"
        }else if (dateComponents.year == dateComponents1.year) && (dateComponents.month ==
            dateComponents1.month) && (dateComponents.day - dateComponents1.day == 1) {
            formatter.dateFormat = "HH:mm"
            return  "Yesterday \(formatter.stringFromDate(date!))"
        }else{
            formatter.dateFormat = "MMMM dd, yyyy"
            let convertedDate = formatter.stringFromDate(date!)
            return convertedDate
        }
        
    }
    //处理时间字符串,yyyyMMddHHmmss
    static func formatDt1(dtStr: String)-> String{
        // 数据库保存的时间
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.dateFromString(dtStr)
        
    
        formatter.dateFormat = NSLocalizedString("NOTETIMEFORMAT", comment: "日期格式")
        let convertedDate = formatter.stringFromDate(date!)
        return convertedDate
        
    }
}
