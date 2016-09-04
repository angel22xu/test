//
//  AppDelegate.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // 设定默认主题
        let theme: Int? = NSUserDefaults.standardUserDefaults().valueForKey("theme") as? Int
        
        if(theme != nil){
            print("theme is \(theme)")
        }else{
            print ("theme is nil")
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "theme")
        }
        
        // 8/29提醒功能追加
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "COMPLETE_TODO" // the unique identifier for this action
        completeAction.title = "Complete" // title for the action button
        completeAction.activationMode = .Background // UIUserNotificationActivationMode.Background - don't bring app to foreground
        completeAction.authenticationRequired = false // don't require unlocking before performing action
        completeAction.destructive = true // display action in red
        
        let remindAction = UIMutableUserNotificationAction()
        remindAction.identifier = "REMIND"
        remindAction.title = "Remind in 30 minutes"
        remindAction.activationMode = .Background
        remindAction.destructive = false
        
        let language = NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages")
        print("language: \(language?.objectAtIndex(0))")
        
        
        let todoCategory = UIMutableUserNotificationCategory() // notification categories allow us to create groups of actions that we can associate with a notification
        todoCategory.identifier = "TODO_CATEGORY"
        todoCategory.setActions([remindAction, completeAction], forContext: .Default) // UIUserNotificationActionContext.Default (4 actions max)
        todoCategory.setActions([completeAction, remindAction], forContext: .Minimal) // UIUserNotificationActionContext.Minimal - for when space is limited (2 actions max)
        
        // we're now providing a set containing our category as an argument
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: Set([todoCategory])))
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        let item = TodoItem(deadline: notification.fireDate!, title: notification.userInfo!["title"] as! String, UUID: notification.userInfo!["UUID"] as! String!)
        switch (identifier!) {
        case "COMPLETE_TODO":
            TodoList.sharedInstance.removeItem(item)
        case "REMIND":
            TodoList.sharedInstance.scheduleReminderforItem(item)
        default: // switch statements must be exhaustive - this condition should never be met
            print("Error: unexpected notification action identifier!")
        }
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("TodoListShouldRefresh", object: self)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NSNotificationCenter.defaultCenter().postNotificationName("TodoListShouldRefresh", object: self)
    }
    
    func applicationWillResignActive(application: UIApplication) { // fired when user quits the application
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        
        let todoItems: [TodoItem] = TodoList.sharedInstance.allItems() // retrieve list of all to-do items
        let overdueItems = todoItems.filter({ (todoItem) -> Bool in
            return todoItem.deadline.compare(NSDate()) != .OrderedDescending
        })
        UIApplication.sharedApplication().applicationIconBadgeNumber = overdueItems.count  // set our badge number to number of overdue items
    }

}

