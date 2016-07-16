//
//  SettingViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/22.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnMailto: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var btnTheme: UIButton!
    
    var currentPage:Int = 0
    var viewControllers = NSMutableArray()
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    
    // Initialize it right away here
    private let contentImages = ["main_bk1",
                                 "main_bk2",
                                 "main_bk3",
                                 "main_bk4",
                                 "main_bk5",]

    @IBAction func changeTheme(sender: AnyObject) {
        createPageViewController()
        setupPageControl()
        
    }
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if contentImages.count > 0 {
            let firstController = getItemController(0)!
            let startingViewControllers = [firstController]
            
            // 主题更换页面不显示默认的返回按钮
            self.navigationItem.setHidesBackButton(true, animated: false)
            
            pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        
        if itemController.itemIndex+1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
        
        if itemIndex < contentImages.count {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - Additions
    
    func currentControllerIndex() -> Int {
        
        let pageItemController = self.currentController()
        
        if let controller = pageItemController as? PageItemController {
            return controller.itemIndex
        }
        
        return -1
    }
    
    func currentController() -> UIViewController? {
        
        if self.pageViewController?.viewControllers?.count > 0 {
            return self.pageViewController?.viewControllers![0]
        }
        
        return nil
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