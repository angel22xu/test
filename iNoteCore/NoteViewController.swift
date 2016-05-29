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
    
    var gString =  NSMutableAttributedString()
    var gTextAttachment = MediaTextAttachment()
    
    
    
    @IBOutlet weak var returnBtn: UIButton!
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    @IBOutlet weak var detailTextView: UITextView!
    
    let size:Float = 64.0

    
    @IBAction func saveContent(sender: AnyObject) {
        
        //  TODO    这行代码会有bug，不能直接这样获取文本
        let content: String = detailTextView.textStorage.getPlainString()
        // TODO  获取detailTextView上的所有数据信息（图片，文字，视频，音频)
        
        
        
        print("saveContent, \(content)")
        let weather: String = "sunshine"
        
        let ct = Content(dict: ["noteID": vigSegue, "content": content, "weather": weather ])
        ct.updateContent()
        
        // 收起输入键盘
        detailTextView.resignFirstResponder()
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        gString  = NSMutableAttributedString(attributedString: detailTextView.attributedText)
        var arrayM = [Content]()
        print(vigSegue)
        if vigSegue == "" {
            
        }else{
            arrayM = Content.loadContents(Int(vigSegue)!)!
            if arrayM.isEmpty{
                detailTextView.text = ""
            }else{
                // 解析数据库读取出来的内容
                // TODO
                analysis_adv(arrayM[0].content!)
                
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

        let selectRange = detailTextView.selectedRange
        
        print("length: \(selectRange.length), localtion: \(selectRange.location)")
        
        let currentDateStr: String = Tool.getCurrentDateStr()
        let randStr: String = Tool.getRandomStringOfLength(2)
        let imageName: String = currentDateStr + randStr + ".png"
        
        
        // 存储媒体文件标识
        gTextAttachment.mediaTag = "![" + imageName + "]"
        
        gTextAttachment.image = scaleImage(image)
        
        let textAttachmentString = NSAttributedString(attachment: gTextAttachment)
        let countString:Int = detailTextView.text.characters.count
        
        print("imageName: \(imageName), currentDateStr: \(currentDateStr), randStr: \(randStr), countString: \(countString), detailTextView.selectedRange.location: \(detailTextView.selectedRange.location)")
        
        detailTextView.textStorage.insertAttributedString(textAttachmentString, atIndex: detailTextView.selectedRange.location)


        detailTextView.selectedRange = NSMakeRange(detailTextView.selectedRange.location+1, detailTextView.selectedRange.length)


        //  保存图片
        self.saveImage(image, newSize: CGSize(width: 256, height: 256), percent: 0.5, imageName: imageName)
        
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

        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    
    // 解析内容，是图片的话显示图片
    func analysis_adv(content: String){
        print("analysis_adv: \(content)")
        
        // 存储内容的字符
        var mojiStr = String()
        var imageNameStr = String()
        
        // 显示图片准备
        let documentPath = Tool.getDocumentPath()
        var fullPath = String()

        
        //左括号
        let leftBrachket: String = "["
        //右括号
        let rightBrachket: String = "]"
        //叹号
        let exclamationMark: String = "!"
        
        var rangeStr: String
        var rightRangeStr: String
        
        var index: Int = 0
        
        while index < content.characters.count{
            
            rangeStr = getSubstring(content, iStart: index, iEnd: index + 1)
//            print("index: \(index),  rangeStr: \(rangeStr)")
            
            // 叹号
            if (rangeStr == exclamationMark){
                rangeStr = getSubstring(content, iStart: index + 1, iEnd: index + 2)
                rightRangeStr = getSubstring(content, iStart: index + 22, iEnd: index + 23)

                print("rangeStr1: \(rangeStr), rightRangeStr: \(rightBrachket)")
                
                // 判断是否左括号右括号
                if(rangeStr == leftBrachket && rightRangeStr == rightBrachket){
                    print ("there is a picture")

                    rangeStr = getSubstring(content, iStart: index + 2, iEnd: index + 22)

                    imageNameStr = rangeStr
                    
                    // 页面上显示图片
                    fullPath = documentPath.stringByAppendingPathComponent(imageNameStr)
                    // 虾面使用新的方法来显示图片

                    gTextAttachment.image = scaleImage(UIImage(named:  fullPath)!)
                    let countString:Int = detailTextView.text.characters.count
                    
                    
                    gString.insertAttributedString(NSAttributedString(attachment: gTextAttachment), atIndex: countString)
                    detailTextView.attributedText  = gString
                    
                    index += 23
                    
                    
                }
                else{ // 是文本内容
                    mojiStr += rangeStr
//                    print("else 1111   index: \(index),  mojiStr: \(mojiStr)")
                    
                    gString.insertAttributedString(NSAttributedString.init(string: rangeStr), atIndex: index)
                    
                    detailTextView.attributedText = gString
                    
                    // index必须位于最后
                    index += 1
                    
                }
                
            }
            else{ // 是文本内容
                mojiStr += rangeStr
//                print("else 2222 index: \(index),  mojiStr: \(mojiStr)")
                
                gString.insertAttributedString(NSAttributedString.init(string: rangeStr), atIndex: index)
                    
                detailTextView.attributedText = gString
                
                // index必须位于最后
                index += 1
            }
        }
        
    }
    
    //  获取字符串中的某个字符
    func getSubstring(content: String, iStart: Int, iEnd: Int) -> String{
        let startIndex = content.startIndex.advancedBy(iStart)
        let endIndex = content.startIndex.advancedBy(iEnd)
        let range = Range<String.Index>(start: startIndex, end: endIndex)
        return content.substringWithRange(range)
    }
    
    func scaleImage(image:UIImage)->UIImage{
        UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        image.drawInRect(CGRectMake(0, 0, self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledimage
        
    }

}
