//
//  NoteViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

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
    
    /*
     拍照功能
     */
    @IBAction func fromPhotograph(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)){
            // 创建图片控制器
            let picker = UIImagePickerController()
            
            // 设置代理
            picker.delegate = self
            
            // 只是来源
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            
            //允许编辑
            picker.allowsEditing = true
            
            //打开相机
            self.presentViewController(picker, animated: true, completion:{()-> Void in })
            
        }else{
                print("I can not find the camera.")
        }
        
    }
    
    /*
     实现imagePicker delegate事件
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var image: UIImage!
        
        // 判断，图片是否允许修改
        if (picker.allowsEditing){
            //裁剪后图片
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }else{
            //原始图片
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        print("imagePickerController")
        
        //            detailTextView?
//        let imageV = UIImageView(image: UIImage(named: "video"))
        
        // 获取textview光标的位置
//        var cursorPosition: CGFloat = 0
//        if ((detailTextView.selectedTextRange) != nil) {
////            cursorPosition = [detailTextView caretRectForPosition:textView.selectedTextRange.start].origin.y;
//            
//            cursorPosition = detailTextView.caretRectForPosition(detailTextView.selectedTextRange!.start).origin.y
//        } else {
//        }

        let selectRange = detailTextView.selectedRange
        
        print("length: \(selectRange.length), localtion: \(selectRange.location)")
        
        let imageV = UIImageView(image: image)
        let path = UIBezierPath(rect: CGRectMake(0, CGFloat(selectRange.location), imageV.frame.width, imageV.frame.height))
        detailTextView.textContainer.exclusionPaths = [path]
        detailTextView.addSubview(imageV)
        
        let currentDateStr: String = Tool.getCurrentDateStr()
        let randStr: String = Tool.getRandomStringOfLength(2)
        
        let imageName: String = currentDateStr + randStr + ".png"
        print("imageName: \(imageName)")
        
        //  保存图片
        self.saveImage(image, newSize: CGSize(width: 256, height: 256), percent: 0.5, imageName: imageName)
        
        //  文件名
        
        
        // 同步图片信息到数据库
        var content: String = detailTextView.text
        content = content + "![\(imageName)]"
        // 对content追加图片信息
        
        let ct = Content(dict: ["noteID": vigSegue, "content": content])
        ct.updateContent()

        
    }
    
    // 当用户取消时，调用该方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //保存图片至沙盒
    func saveImage(currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
        
        print("saveImage, \(imageName)")
        //压缩图片尺寸
        UIGraphicsBeginImageContext(newSize)
        currentImage.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        let imageData: NSData = UIImageJPEGRepresentation(newImage, percent)!
        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
        
        // 获取沙盒路径
        let documentPath = Tool.getDocumentPath()
        let fullPath: String = documentPath.stringByAppendingPathComponent(imageName)
        print("fullPath, \(fullPath)")

        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    
    // 解析内容，是图片的话显示图片
    func analysis(content: String){
        print("analysis: \(content)")
        
        var imageNameStr = String()

        // 显示图片准备
        let documentPath = Tool.getDocumentPath()
        var fullPath = String()
        var imageV: UIImageView
        var path: UIBezierPath
        
        
        // 开始分析
        for (var index = 0; index < content.characters.count; index += 1){
            
            print("index: \(index)")
            var startIndex = content.startIndex.advancedBy(index)
            var endIndex = content.startIndex.advancedBy(index+1)
            var range = Range<String.Index>(start: startIndex, end: endIndex)
            var rangeStr = content.substringWithRange(range)
            print("rangeStr: \(rangeStr)")

            if (rangeStr == "!"){
                startIndex = content.startIndex.advancedBy(index+1)
                endIndex = content.startIndex.advancedBy(index+2)
                range = Range<String.Index>(start: startIndex, end: endIndex)
                rangeStr = content.substringWithRange(range)

                print("rangeStr1: \(rangeStr)")
                
                if(rangeStr == "["){
                    startIndex = content.startIndex.advancedBy(index+2)
                    endIndex = content.startIndex.advancedBy(index+22)
                    range = Range<String.Index>(start: startIndex, end: endIndex)
                    rangeStr = content.substringWithRange(range)
                    
                    imageNameStr = rangeStr
                    print("rangeStr2: \(rangeStr)")

                    
                    // 页面上显示图片
                    fullPath = documentPath.stringByAppendingPathComponent(imageNameStr)
                    imageV = UIImageView(image: UIImage(named:  fullPath))
                    path = UIBezierPath(rect: CGRectMake(0, 0, imageV.frame.width, imageV.frame.height))
                    detailTextView.textContainer.exclusionPaths = [path]
                    detailTextView.addSubview(imageV)
                    
                }
                
                

            }
            
        }
        
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
                
                print("内容： \(arrayM[0].content)")
                // 解析数据库读取出来的内容
                // TODO
                analysis(arrayM[0].content!)
                
            }
        }
        
        
        // 测试begin
//        let documentPath = Tool.getDocumentPath()
//        let fullPath: String = documentPath.stringByAppendingPathComponent("currentImage.png")
//        
//        let imageV = UIImageView(image: UIImage(named:  fullPath))
//        let path = UIBezierPath(rect: CGRectMake(0, 0, imageV.frame.width, imageV.frame.height))
//        detailTextView.textContainer.exclusionPaths = [path]
//        detailTextView.addSubview(imageV)

        // 测试end
        
        
        
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
