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
    
//    var gTextAttachment = MediaTextAttachment()
    //  屏幕大小 TODO 改成动态读取
    let SCREEN_WIDTH = CGFloat(320)
    let SCREEN_HEIGHT = CGFloat(480)
    
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
        
        // 获取第一行文字，作为标题保存在 indexConfig表里
        let dt: String = Tool.getCurrentDateStr()
        var title = detailTextView.text

        if title.characters.count < 15{
        }else{
            title = (title as NSString).substringToIndex(15) +  "・・・"
        }
        
        let t = Title(dict: ["noteID": vigSegue, "title": title, "dt": dt ])
        t.updateTitle()
        
        
        // 收起输入键盘
        detailTextView.resignFirstResponder()
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        gString  = NSMutableAttributedString(attributedString: detailTextView.attributedText)
        var arrayM = [Content]()
        print("vigSegue: \(vigSegue)")
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
//        detailTextView.editable = false
        detailTextView.backgroundColor = UIColor.grayColor()
//        resetTextStyle()
        
//        detailTextView.scrollEnabled = false
//        detailTextView.becomeFirstResponder()
        
        // 自定义事件
//        UIGestureRecognizer类用于手势识别，它的子类有主要有六个分别是：
//        UITapGestureRecognizer（轻击一下）
//        UIPinchGestureRecognizer（两指控制的缩放）
//        UIRotationGestureRecognizer（旋转）
//        UISwipeGestureRecognizer（滑动，快速移动）
//        UIPanGestureRecognizer（拖移，慢慢移动）
//        UILongPressGestureRecognizer（长按）
        
        // TODO 注册事件不好用，有待调试
//        detailTextView.addGestureRecognizer(UILongPressGestureRecognizer(target: detailTextView, action: #selector(NoteViewController.handleTap(_:))))
        
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
            
            let version = UIDevice.currentDevice().systemVersion
           
            if(Float(version) > 8.0){
                print("version:\(version)")
                
                ////bug：Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.  未解决

                picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            }
            
            
            //打开相机
            self.presentViewController(picker, animated: true, completion:{()-> Void in })
            print("detailTextView.textStorage in fromPhotograph: \(detailTextView.textStorage.getPlainString())")

            
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
        
        let gTextAttachment = MediaTextAttachment()
        print("detailTextView.textStorage before: \(detailTextView.textStorage.getPlainString())")


        // 判断，图片是否允许修改
        if (picker.allowsEditing){
            //裁剪后图片
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }else{
            //原始图片
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        
        let currentDateStr: String = Tool.getCurrentDateStr()
        let randStr: String = Tool.getRandomStringOfLength(2)
        let imageName: String = currentDateStr + randStr + ".png"
        
        // 设图片标志（这里设置图片标志，主要是为了：表情转换字符串时 操作更简单）
        gTextAttachment.mediaTag = "![" + imageName + "]"
        
        // 设置图片
        gTextAttachment.image = scaleImage(image)
        
//        print("imageName: \(imageName), currentDateStr: \(currentDateStr), randStr: \(randStr), detailTextView.selectedRange.location: \(detailTextView.selectedRange.location), detailTextView.textStorage before: \(detailTextView.textStorage.getPlainString())")
        
        
        let selectedRange = detailTextView.selectedRange
        
        detailTextView.textStorage.insertAttributedString(NSAttributedString(attachment: gTextAttachment), atIndex: selectedRange.location)


        detailTextView.selectedRange = NSMakeRange(selectedRange.location+1, selectedRange.length)
        print("detailTextView.textStorage after: \(detailTextView.textStorage.getPlainString())")

        
        // 重置格式
        resetTextStyle()

        
        // 计算新的光标位置，并恢复光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
        detailTextView.selectedRange = newSelectedRange

        
        //  保存图片
        // TODO  大小要重新定义
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
        
        // 显示文字标识，会不断重置
        var showTextFlag = false
        // 文字数，不断累加
        var txtCnt: Int = 0
        
        // 显示多媒体标识，会不断重置
        var showMediaFlag = false
        var mediaCnt: Int = 0
        

        
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
                    let gTextAttachment = MediaTextAttachment()


                    rangeStr = getSubstring(content, iStart: index + 2, iEnd: index + 22)

                    imageNameStr = rangeStr
                    print ("there is a picture imageNameStr: \(imageNameStr)")

                    // 页面上显示图片
                    fullPath = documentPath.stringByAppendingPathComponent(imageNameStr)
                    //下面使用新的方法来显示图片
                    
                    gTextAttachment.mediaTag = "![" + imageNameStr + "]"
                    gTextAttachment.image = scaleImage(UIImage(named:  fullPath)!)
                    
                    detailTextView.textStorage.insertAttributedString(NSAttributedString(attachment: gTextAttachment), atIndex: detailTextView.selectedRange.location)
                                        
                    detailTextView.selectedRange = NSMakeRange(detailTextView.selectedRange.location+1, detailTextView.selectedRange.length)
                    
                    showMediaFlag = true
                    index += 23
                    mediaCnt += 1
                    
                    
                }
                else{ // 是文本内容
                    mojiStr += rangeStr
                    showTextFlag = true

                    // index必须位于最后
                    index += 1
                    txtCnt += 1
                }
            }
            else{ // 是文本内容
                mojiStr += rangeStr
                showTextFlag = true
                // index必须位于最后
                index += 1
                txtCnt += 1
            }
            
            
            if (showTextFlag && showMediaFlag) || (showTextFlag && txtCnt > 0) {
                
                detailTextView.textStorage.insertAttributedString(NSAttributedString.init(string: mojiStr), atIndex: detailTextView.selectedRange.location)
                detailTextView.selectedRange = NSMakeRange(detailTextView.selectedRange.location+1, detailTextView.selectedRange.length)
                mojiStr = ""
                showTextFlag = false
                showMediaFlag = false
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

    //设置textView的字体属性
    func resetTextStyle(){
        let wholeRange:NSRange = NSMakeRange(0, detailTextView.textStorage.length)
        detailTextView.textStorage.removeAttribute(NSFontAttributeName, range: wholeRange)
        detailTextView.textStorage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16), range: wholeRange)
        
//        detailTextView.scrollRangeToVisible(NSMakeRange(detailTextView.textStorage.length, 1))
        
    }

    func handleTap(sender: UILongPressGestureRecognizer) {
        print ("handleTap")
        if sender.state == .Ended {
            print("收回键盘")
            detailTextView.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("NoteViewControllerのviewWillAppearが呼ばれた")
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHidden:", name: UIKeyboardWillHideNotification, object: nil)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("NoteViewControllerのviewDidAppearが呼ばれた")
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("NoteViewControllerのviewWillDisappearが呼ばれた")
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("NoteViewControllerのviewDidDisappearが呼ばれた")
    }
    
    func keyboardWillShow(aNotification: NSNotification){

        
        let userInfo: NSDictionary? = aNotification.userInfo
        let aValue: NSValue? = userInfo?.objectForKey(UIKeyboardFrameEndUserInfoKey) as? NSValue
        let keyboardRect = aValue?.CGRectValue()
        
        
        let keyboardHeight = keyboardRect?.size.height
        
        var frame = detailTextView!.frame
        var offset = frame.origin.y + 32 - (self.view.frame.size.height - keyboardHeight!)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if offset > 0{
                self.view.frame = CGRectMake(0, -offset, self.SCREEN_WIDTH, self.SCREEN_HEIGHT)
            }
        })
    }
    
    func keyboardWillHidden(notification: NSNotification){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(0, 0, self.SCREEN_WIDTH, self.SCREEN_HEIGHT)
        })
    }
}
