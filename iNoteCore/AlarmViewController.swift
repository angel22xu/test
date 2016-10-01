//
//  AlarmViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/8/21.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var alarmNavi: UINavigationItem!
    @IBOutlet weak var notificationSetting: UIButton!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var dtLabel: UILabel!
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var alarmLable: UILabel!
    
    @IBOutlet weak var switchLabel: UILabel!
    
    //日志ID, 主键, 从上个页面传过来
    var vigSegue = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initToolBar()
        
        initPage()
        
        deadlinePicker.addTarget(self, action: #selector(AlarmViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)

        
    }
    
    func initPage(){
        alarmNavi.title = NSLocalizedString("ALARMDETAIL", comment: "提醒")

        titleText.placeholder = NSLocalizedString("REMINDER_TITLE", comment: "提醒标题")
        titleText.font = UIFont.systemFontOfSize(16)
        tips.hidden = true

        if (isAllowedNotification() == false){    // 手机设定未开启通知
            
            let textview=UITextView(frame:CGRectMake(10, 100, self.view.bounds.width - 20, 150))
            textview.layer.borderWidth=1  //边框粗细
            textview.layer.borderColor=UIColor.grayColor().CGColor //边框颜色
            textview.text = NSLocalizedString("REMINDER_SETTING_TIPS", comment: "允许通知设定提示")
            textview.editable = false
            textview.selectable = false
            self.view.addSubview(textview)
            
            
            
            let imageTips = UIImageView.init(frame: CGRectMake(10, 260, self.view.bounds.width - 20, 150))
            imageTips.image = UIImage(named: "notification")
            self.view.addSubview(imageTips)
            
            
            
            // 允许通知按钮样式设定
            let settingPushBtn = UIButton(type: UIButtonType.System)
            settingPushBtn.frame = CGRectMake(10, 450, self.view.bounds.width - 20, 50)
            settingPushBtn.setTitle(NSLocalizedString("REMINDER_SETTING_BTNPUSH", comment: "允许通知设定"), forState: UIControlState.Normal)
            settingPushBtn.addTarget(self, action: #selector(AlarmViewController.notificationSettingAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            settingPushBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            settingPushBtn.backgroundColor = UIColor.lightGrayColor()
            settingPushBtn.layer.cornerRadius = 5
            
            self.view.addSubview(settingPushBtn)
            
            self.view.addSubview(settingPushBtn)

            
            
            
            // 其它所有内容全部隐藏
            titleText.hidden = true
            alarmSwitch.hidden = true
            switchLabel.hidden = true
            deadlinePicker.hidden = true
            dtLabel.hidden = true
            okBtn.hidden = true
            alarmLable.hidden = true
            

            
        }else{
            switchLabel.text = NSLocalizedString("REMINDER_LB1", comment: "指定时间通知")
            alarmLable.text = NSLocalizedString("REMINDER_LB2", comment: "闹钟时间")
            
            // 确认按钮设定
            okBtn.backgroundColor = UIColor.lightGrayColor()
            okBtn.layer.cornerRadius = 5
            okBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
            // 获取标题数据库默认数据
            let t = Title.loadTitle(Int(self.vigSegue)!)
            if(t?.redminderFlag == Constant.REMINDER_ON){ //已经设定过提醒
                titleText.text = t?.subtitle
                dtLabel.text = t?.redminerDT
                
                // 设定默认时间选择器
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                deadlinePicker.date = formatter.dateFromString((t?.redminerDT)!)!
                
                // 在已经设定过提醒的情况下
                okBtn.setTitle(NSLocalizedString("REMINDER_BTNMODIFY", comment: "修改"), forState: UIControlState.Normal)
                
            }else{   // 初始画面
                
                alarmSwitch.on = false
                deadlinePicker.hidden = true
                dtLabel.hidden = true
                okBtn.hidden = true
                alarmLable.hidden = true
                
                okBtn.setTitle(NSLocalizedString("REMINDER_BTNOK", comment: "确认"), forState: UIControlState.Normal)
                
            }

            
            
        }
        
        // 不使用这2个标签
        dtLabel.hidden = true
        alarmLable.hidden = true

        
        
    }
    
    // 提醒功能开关
    @IBAction func alarmSwitchAction(sender: AnyObject) {
        
        if(alarmSwitch.on){   //开启
            deadlinePicker.hidden = false
//            dtLabel.hidden = false
            okBtn.hidden = false
//            alarmLable.hidden = false
            
            // 设置提醒标签的默认时间
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            dtLabel.text = formatter.stringFromDate(deadlinePicker.date)

        }else{  // 关闭
            deadlinePicker.hidden = true
            dtLabel.hidden = true
            okBtn.hidden = true
            alarmLable.hidden = true
            
            
            // 关闭数据库，本地提醒数据删除
            Title.closeReminder(Int(vigSegue)!)
            
            let todoItem = TodoItem(deadline: deadlinePicker.date, title: "", UUID: vigSegue)
            TodoList.sharedInstance.removeItem(todoItem) // schedule a local notification to persist this item
            
            
            
        }
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
            tips.text = NSLocalizedString("REMINDER_WARING", comment: "提示输入提醒标题")
            tips.textColor = UIColor.redColor()
            tips.font = UIFont.systemFontOfSize(14)
            return
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let t = Title(dict: ["noteID": Int(vigSegue)!, "subtitle": title!, "redminderFlag": Constant.REMINDER_ON, "redminerDT":  dtLabel.text!, "dt": dt])
        t.updateSubtitle()

        let todoItem = TodoItem(deadline: deadlinePicker.date, title: title!, UUID: vigSegue)
        TodoList.sharedInstance.addItem(todoItem) // schedule a local notification to persist this item
        self.navigationController?.popViewControllerAnimated(true)
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
