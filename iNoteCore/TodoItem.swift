//
//  TodoItem.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/8/28.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import Foundation

struct TodoItem {
    var title: String
    var deadline: NSDate
    var UUID: String
    
    init(deadline: NSDate, title: String, UUID: String) {
        self.deadline = deadline
        self.title = title
        self.UUID = UUID
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending) // deadline is earlier than current date
    }
}