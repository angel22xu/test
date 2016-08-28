//
//  AlarmViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/8/21.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var notificationSetting: UIButton!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var dtLabel: UILabel!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    
    @IBOutlet weak var notificationView: UIView!
    //日志ID, 主键, 从上个页面传过来
    var vigSegue = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initToolBar()
        
        // Do any additional setup after loading the view.
        titleText.placeholder = "title"
        titleText.font = UIFont.systemFontOfSize(16)
        tips.hidden = true
        
        if (isAllowedNotification() == false){
            notificationView.hidden = false
        }else{
            notificationView.hidden = true
        }
        
        
        deadlinePicker.addTarget(self, action: #selector(AlarmViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)

        
    }

    // 去系统设定通知页面
    @IBAction func notificationSettingAction(sender: AnyObject) {
        let settingUrl = NSURL(string:"prefs:root=NOTIFICATIONS_ID")!
        if UIApplication.sharedApplication().canOpenURL(settingUrl)
        {
            UIApplication.sharedApplication().openURL(settingUrl)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        
        // 获取第一行文字，作为标题保存在 indexConfig表里
        let dt: String = Tool.getCurrentDateStr()
        let title = titleText.text
        
        // 内容为空时不让设定提醒
        if (title?.compare("") == NSComparisonResult.OrderedSame){
            tips.hidden = false
            tips.text = "Please input the alarm content"
            tips.textColor = UIColor.redColor()
            tips.font = UIFont.systemFontOfSize(14)
            return
        }
        
        let t = Title(dict: ["noteID": Int(vigSegue)!, "title": title!, "dt": dt ])
        t.updateTitle()

        let UUID: String = NSUUID().UUIDString
        
        let todoItem = TodoItem(deadline: deadlinePicker.date, title: title!, UUID: UUID)
        TodoList.sharedInstance.addItem(todoItem) // schedule a local notification to persist this item
        self.navigationController?.popToRootViewControllerAnimated(true) // return to list view
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // 键盘上追加一个完成Done按钮
    func initToolBar(){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        
        
        let doneButton = UIBarButtonItem(image: UIImage(named: "done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AlarmViewController.donePressed))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        self.titleText.delegate = self
        self.titleText.inputAccessoryView = toolBar
    }
    
    // 收起输入键盘
    func donePressed(){
        self.titleText.resignFirstResponder()
    }

    
    func datePickerChanged(datePicker:UIDatePicker) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        dtLabel.text = formatter.stringFromDate(datePicker.date)
    }
    
    
    // 判断是否开启了系统通知
    func isAllowedNotification() -> Bool
    {
        let setting: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        
        if(UIUserNotificationType.None != setting.types){
            return true
        }
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}
