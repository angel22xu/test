//
//  SettingViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/22.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBAction func setLanguage(sender: AnyObject) {
        print("setLanguage")
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
        let url = NSURL(string: "mailto:xuxiaomin024@gmail.com")
        UIApplication.sharedApplication().openURL(url!)
    }
    @IBAction func shareToFriend(sender: AnyObject) {
        print("shareToFriend")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(Tool.getDocumentPath())
        print(Tool.getRandomStringOfLength(10))
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
