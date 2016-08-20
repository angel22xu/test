//
//  TodoListTableViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var itemSetting: UIBarButtonItem!
    @IBOutlet weak var noteNaviItem: UINavigationItem!

    @IBOutlet weak var itemNew: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems = NSMutableArray()
    var titles = [Title]()

    
    // 显示的内容
    var result = NSMutableArray()
    
    

    @IBAction func insertNewItem(sender: AnyObject) {
    
        let dt: String = Tool.getCurrentDateStr()
        let hh: String = Tool.getCurrentHH()
        
        var noteID: Int = Int(arc4random() % 1000000)
        
        if( Int(hh) > 0){
            noteID = noteID + Int(hh)!
        }
        
        let t = Title(dict: ["noteID": noteID, "title": "", "dt": dt ])
        
        if t.insertTtile() {
            self.result.insertObject(t, atIndex: 0);

            let indexPath = NSIndexPath(forRow: 0, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic );

        }else {
            print ("插入title失败")
        }
        
    }
    // 清数据
    func clear(){
        self.todoItems.removeAllObjects()
        
        // 0820
        self.result.removeAllObjects()
        
        self.titles.removeAll()
        
        self.tableView.reloadData()
    }
    
    // 刷新主场景
    func refresh(){
        
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()

        
        self.titles = Title.loadTitles()!
        
        if self.titles.isEmpty {
        }else{
        }
        
        // 不加beginupdates 和 endupdates，点击搜索之后的结果，返回会报错
        self.tableView.beginUpdates()
 
        var index = 0
        for tobj in self.titles{
            self.todoItems.insertObject(tobj, atIndex: index);
            let indexPath = NSIndexPath(forRow: index, inSection: 0);
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
            index += 1
            
        }
        
        self.result = self.todoItems
        self.tableView.endUpdates()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 为了多显示一会launch image，主页面延长1秒
        NSThread.sleepForTimeInterval(1.0)
        
        // 打开数据库
        SQLiteManager.sharedManager.openDB()
    
        refresh()
        
        // 刷新主界面
        initPage()
        
        self.searchBar.delegate = self
        self.searchBar.placeholder = "serach"
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // 没有搜索内容时显示全部内容
        if searchText == "" {
            self.result = self.todoItems
        } else {
            
            self.result = NSMutableArray()
            
            // 匹配用户输入的前缀，不区分大小写
            var index = 0
            for arr in self.titles {
                if ((arr.title?.lowercaseString.hasPrefix(searchText.lowercaseString)) == true){
                    self.result.insertObject(arr, atIndex: index)
                    index += 1
                }
            }
            
            print("index = \(index)")
        }
        
        // 刷新tableView 数据显示
        self.tableView.reloadData()
    }
    
    // 搜索触发事件，点击虚拟键盘上的search按钮时触发此方法
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    // 书签按钮触发事件
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        
        print("搜索历史")
    }
    
    // 取消按钮触发事件
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // 搜索内容置空
        searchBar.text = ""
        self.result = self.todoItems
        
        self.tableView.reloadData()
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
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.result.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ToDoCell", forIndexPath: indexPath)

        // Configure the cell...
        let item = self.result[indexPath.row] as! Title
    
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
            let t = self.result[indexPath.row] as! Title

            // 删除标志改为1，表示扔进垃圾桶，方便恢复
            t.delFlag = 1
            t.updateStaus()

            self.result.removeObjectAtIndex(indexPath.row)
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
            let destinationController = segue.destinationViewController as! NoteViewController
            let path = self.tableView.indexPathForSelectedRow
          
            let t = self.result[path!.row] as! Title
            
            destinationController.vigSegue = String(t.noteID)
            destinationController.noteTime = t.dt!

            
        }else if(segue.identifier == "settingSegue"){
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
