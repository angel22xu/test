//
//  PageItemController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/7/16.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class PageItemController: UIViewController {
    
    @IBOutlet var offImage: UIImageView!
    // MARK: - Variables
    var itemIndex: Int = 0
    var imageName: String = "" {
        
        didSet {
            
            if let imageView = contentImageView {
                imageView.image = UIImage(named: imageName)
            }
            
        }
    }
    
    @IBOutlet var contentImageView: UIImageView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
        
        //双击监听
        let tapDouble=UITapGestureRecognizer(target:self,action:#selector(tapDoubleDid(_:)))
        tapDouble.numberOfTapsRequired=2
        tapDouble.numberOfTouchesRequired=1
        self.view.addGestureRecognizer(tapDouble)
        
        // 向上滑动
        let swipeUp = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)

        // 向下滑动
        let swipeDown = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    // 双击事件
    func tapDoubleDid(sender:UITapGestureRecognizer){
        if sender.view == self.view{
            let alertView = UIAlertView()
            alertView.title = NSLocalizedString("THEME_ALERT_TITLE", comment: "标题")
            alertView.message = NSLocalizedString("THEME_ALERT_MSG", comment: "内容")
            alertView.addButtonWithTitle(NSLocalizedString("THEME_ALERT_CANCEL", comment: "取消"))
            alertView.addButtonWithTitle(NSLocalizedString("THEME_ALERT_OK", comment: "确定"))
            alertView.cancelButtonIndex=0
            alertView.delegate=self;
            alertView.show()
        
        }
    }
    
    // 向上向下滑动事件
    func swipe(recognizer:UISwipeGestureRecognizer){
//        let sb = UIStoryboard(name: "Storyboard", bundle:nil)
//        let vc = sb.instantiateViewControllerWithIdentifier("settingStoryBoard") as! SettingViewController
//        self.presentViewController(vc, animated:true, completion:nil)

    }
    
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex==alertView.cancelButtonIndex){
        }
        else
        {
            let themeID = (imageName as NSString).substringWithRange(NSMakeRange(7, 1))
            NSUserDefaults.standardUserDefaults().setInteger(Int(themeID)! , forKey: "theme")
            
        }
    }

}
