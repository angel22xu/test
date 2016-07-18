//
//  TodoListTableViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController {
    @IBOutlet weak var itemSetting: UIBarButtonItem!
    @IBOutlet weak var noteNaviItem: UINavigationItem!

    @IBOutlet weak var itemNew: UIBarButtonItem!
    var todoItems = NSMutableArray()
    var arrayM = [Title]()


    @IBAction func insertNewItem(sender: AnyObject) {
    
        let dt: String = Tool.getCurrentDateStr()
        
        var noteID: Int = Int(arc4random()) % 1000000
        noteID = noteID + Int(dt)!
        let t = Title(dict: ["noteID": noteID, "title": "", "dt": dt ])
        
        if t.insertTtile() {
            todoItems.insertObject(t, atIndex: 0);
            let indexPath = NSIndexPath(forRow: 0, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );

        }else {
            print ("插入title失败")
        }
        
    }
    // 清数据
    func clear(){
        todoItems.removeAllObjects()
        arrayM.removeAll()
        
        self.tableView.reloadData()
    }
    
    // 刷新主场景
    func refresh(){
        arrayM = Title.loadTitles()!
        
        if arrayM.isEmpty {
            print ("没有数据")
        }else{
//            print ("有数据呦")
        }
 
        var index = 0
        for tobj in arrayM{
            todoItems.insertObject(tobj, atIndex: index);
            let indexPath = NSIndexPath(forRow: index, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
            index += 1
            
        }
        
    }


    

    override func viewDidLoad() {
        super.viewDidLoad()
        SQLiteManager.sharedManager.openDB()


//        dispatch_async(dispatch_get_main_queue(), {
//            self.refresh()
//            return
//        })
        
        refresh()
        
        // 刷新主界面
        initPage()
    }

    // 初始化界面
    private func initPage(){
        self.tableView.rowHeight = 66
        itemSetting.title = NSLocalizedString("SETTING", comment: "设定")
        itemNew.title = NSLocalizedString("NEW", comment: "写日记")
        noteNaviItem.title = NSLocalizedString("TITLE", comment: "日记标题")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
    
        cell.textLabel!.text = item.title
        cell.detailTextLabel?.text = Tool.formatDt(item.dt!)
        
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
            let t = todoItems[indexPath.row] as! Title
            // 删除标志改为1，表示扔进垃圾桶，方便恢复
            t.delFlag = 1
            t.updateStaus()
            
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
        
        if(segue.identifier == "noteSegue"){
            print("identifier1:  \(segue.identifier)")

            let destinationController = segue.destinationViewController as! NoteViewController
            let path = self.tableView.indexPathForSelectedRow
            let t = todoItems[path!.row] as! Title
            
            destinationController.vigSegue = String(t.noteID)
            destinationController.noteTime = t.dt!

            
        }else if(segue.identifier == "settingSegue"){
            print("identifier2:  \(segue.identifier)")

            _ = segue.destinationViewController as! SettingViewController

        }
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.clear()
        self.refresh()


    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.clear()

    }

}
