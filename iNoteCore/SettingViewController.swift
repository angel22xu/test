//
//  SettingViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/22.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnMailto: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var btnTheme: UIButton!
    

    @IBAction func changeTheme(sender: AnyObject) {
        let alertView = UIAlertView()
        alertView.title = NSLocalizedString("THEME_ALERT_TITLE", comment: "标题")
        alertView.message = NSLocalizedString("THEME_ALERT_MSG", comment: "内容")
        alertView.addButtonWithTitle(NSLocalizedString("THEME_ALERT_CANCEL", comment: "取消"))
        alertView.addButtonWithTitle(NSLocalizedString("THEME_ALERT_OK", comment: "确定"))
        alertView.cancelButtonIndex=0
        alertView.delegate=self;
        alertView.show()
        
    
    }
    
    
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex==alertView.cancelButtonIndex){
        }
        else
        {
            let theme: Int = NSUserDefaults.standardUserDefaults().valueForKey("theme") as! Int
            
            let themeList: NSMutableArray = [1, 2, 3, 4, 5]
            
            // 从剩下的主题中挑选
            themeList.removeObject(theme)
            let randomIndex = Int(arc4random_uniform(UInt32(themeList.count)))
            
            NSUserDefaults.standardUserDefaults().setInteger(themeList[randomIndex] as! Int, forKey: "theme")
            
            // 设置背景主题
            self.view.backgroundColor = UIColor(patternImage: UIImage(imageLiteral: "setting_bk\(themeList[randomIndex] as! Int)"))

            
        }
    }
    
    
    @IBAction func help(sender: AnyObject) {
        print("help")
    }
    
    //商店评分
    @IBAction func review(sender: AnyObject) {
//        let url : NSURL = NSURL(string: "itms-apps://itunes.apple.com/app/id980864870")!
        let url : NSURL = NSURL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=980864870&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8")!

        if(UIApplication.sharedApplication().canOpenURL(url)){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // 联系开发者
    @IBAction func mailToDeveloper(sender: AnyObject) {
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let shortVersion: String? = infoDictionary! ["CFBundleShortVersionString"] as? String
       
        // 应用版本号
        let majorVersion = (shortVersion != nil) ? shortVersion! : "0.0"
        //系统版本号
        let systemVersion = UIDevice.currentDevice().systemVersion

        let body = NSString(format: NSLocalizedString("BODY", comment: "邮件内容"), systemVersion, majorVersion)
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Constant.EMAIL])
        mailComposerVC.setSubject(NSLocalizedString("SUBJECT", comment: "邮件标题"))
        mailComposerVC.setMessageBody(body as String, isHTML: false)
        self.presentViewController(mailComposerVC, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareToFriend(sender: AnyObject) {
        print("shareToFriend")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
        btnShare.setTitle(NSLocalizedString("SHARE", comment: "分享"), forState: UIControlState.Normal)
        btnMailto.setTitle(NSLocalizedString("MAILTO", comment: "联系开发者"), forState: UIControlState.Normal)
        btnHelp.setTitle(NSLocalizedString("HELP", comment: "帮助"), forState: UIControlState.Normal)
        btnTheme.setTitle(NSLocalizedString("THEME", comment: "主题"), forState: UIControlState.Normal)
        btnReview.setTitle(NSLocalizedString("REVIEW", comment: "评分"), forState: UIControlState.Normal)
        
        
        btnShare.backgroundColor = UIColor.whiteColor()
        btnShare.layer.cornerRadius = 5

        btnMailto.backgroundColor = UIColor.whiteColor()
        btnMailto.layer.cornerRadius = 5
        
        btnHelp.backgroundColor = UIColor.whiteColor()
        btnHelp.layer.cornerRadius = 5
        
        btnTheme.backgroundColor = UIColor.whiteColor()
        btnTheme.layer.cornerRadius = 5

        btnReview.backgroundColor = UIColor.whiteColor()
        btnReview.layer.cornerRadius = 5

        
        //x, y, width, height
//        btnShare.frame=CGRectMake(10, 150, 500, 30)
        
        
        // 设置背景主题
        let theme: Int = NSUserDefaults.standardUserDefaults().valueForKey("theme") as! Int
        self.view.backgroundColor = UIColor(patternImage: UIImage(imageLiteral: "setting_bk\(theme)"))

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
