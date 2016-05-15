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
        
//        todoItems.insertObject(NSDate(), atIndex: 0);
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0);
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );
    
        let dt: String = Tool.getCurrentDateStr()
        print(dt)
        
        var noteID: Int = Int(arc4random()) % 1000000
        noteID = noteID + Int(dt)!
        let t = Title(dict: ["noteID": noteID, "title": dt, "dt": dt ])
        
        if t.insertTtile() {
//            print ("插入title成功")
            todoItems.insertObject(t, atIndex: 0);
            let indexPath = NSIndexPath(forRow: 0, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );

        }else {
            print ("插入title失败")
        }
//        let c = Content(dict: ["noteID": 3, "content": "jintian lajfalsjfdlsdflsdsdfsd", "weather": "qingtian" ])
//        
//        if c.insertContent() {
//            print ("插入content成功")
//        }else {
//            print ("插入content失败")
//        }
        
        
    }
    
    // 刷新主场景
    func refresh(){

        var arrayM = [Title]()
        arrayM = Title.loadTitles()!
        
        if arrayM.isEmpty {
            print ("没有数据")
        }else{
//            print ("有数据呦")
        }
 
        for tobj in arrayM{
            todoItems.insertObject(tobj, atIndex: 0);
            let indexPath = NSIndexPath(forRow: 0, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );
            
        }
        
    }


    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        print("begin create table")
        SQLiteManager.sharedManager.openDB()
        print("end create table")
        
        // 刷新主界面
        print("begin refresh")
        refresh()
        print("end refresh")

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
        return todoItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ToDoCell", forIndexPath: indexPath)

        // Configure the cell...
        let item = todoItems[indexPath.row] as! Title
    
        cell.textLabel!.text = String(item.noteID)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        NoteViewController ＊destinationController = ［segue.destinationViewController］
        let destinationController = segue.destinationViewController as! NoteViewController
        
        let path = self.tableView.indexPathForSelectedRow
        let cell = self.tableView.cellForRowAtIndexPath(path!)
        print ("激活了点击操作")
        
        destinationController.vigSegue = (cell?.textLabel?.text)!
        
    }
    

}
