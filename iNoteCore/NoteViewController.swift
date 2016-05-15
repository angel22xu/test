//
//  NoteViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    var vigSegue = ""
    
    @IBOutlet weak var returnBtn: UIButton!
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBAction func saveContent(sender: AnyObject) {
        let content: String = detailTextView.text
        let weather: String = "sunshine"
        
        let ct = Content(dict: ["noteID": vigSegue, "content": content, "weather": weather ])
        ct.insertContent()
        
        // 收起输入键盘
        detailTextView.resignFirstResponder()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var arrayM = [Content]()
        print(vigSegue)
        if vigSegue == "" {
            
        }else{
            arrayM = Content.loadContents(Int(vigSegue)!)!
            if arrayM.isEmpty{
                detailTextView.text = ""
            }else{
                detailTextView.text =  arrayM[0].content
                
            }
        }
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
    func test(){
        /*
         定义弹框
         */
        var alert: UIAlertController!

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .Default) {
            (action: UIAlertAction!) -> Void in
            print("you choose ok")
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) {
            (action: UIAlertAction!) -> Void in
            print("you choose delete")
        }
        
        alert = UIAlertController(title: "simple alert", message: "this is a simple alert", preferredStyle: .Alert)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addAction(deleteAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}
