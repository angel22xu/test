//
//  TodoListTableViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController {
    
    var todoItems = NSMutableArray()
    
    @IBAction func insertNewItem(sender: AnyObject) {
//        todoItems.insertObject(NSDate(), atIndex: 0)
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    
        todoItems.insertObject(NSDate(), atIndex: 0);
        let indexPath = NSIndexPath(forRow: 0, inSection: 0);
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );
    
        
    }
    
    
    let DBFILE_NAME = "psList.sqlite3"
    var db:COpaquePointer = nil
    //获取sqlite3数据库文件位置
    func applicationDocumentsDirectoryFile() ->String {
        let  documentDirectory: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = documentDirectory[0].stringByAppendingPathComponent(DBFILE_NAME) as String
        NSLog("path : %@", path)
        print(path)
        return path
    }
    
    //创建一个系统配置表
    func getSysConfig()->Dictionary<String,String>{
        var theResult:Dictionary<String,String>=Dictionary<String,String>()
        let writableDBPath = self.applicationDocumentsDirectoryFile()
        let cpath = writableDBPath.cStringUsingEncoding(NSUTF8StringEncoding)
        
        if sqlite3_open(cpath!, &db) != SQLITE_OK {
            sqlite3_close(db)
            assert(false, "数据库打开失败。")
        } else {
            //创建一个系统参数配置表，有3个字段，分别是 名字、值和备注
            let sql = "CREATE TABLE IF NOT EXISTS  SysConfig (name TEXT PRIMARY KEY, value TEXT , comment TEXT)"
            let cSql = sql.cStringUsingEncoding(NSUTF8StringEncoding)
            
            if (sqlite3_exec(db,cSql!, nil, nil, nil) != SQLITE_OK) {
                sqlite3_close(db)
                assert(false, "建表失败。")
            }
            sqlite3_close(db)
        }
        
        return theResult
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        print("begin create table")
        getSysConfig()
        print("end create table")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        return 0
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 0
        return todoItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ToDoCell", forIndexPath: indexPath)

        // Configure the cell...
        let item = todoItems[indexPath.row] as! NSDate
        cell.textLabel!.text = item.description

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            todoItems.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
