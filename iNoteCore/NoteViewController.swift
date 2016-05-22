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

}
