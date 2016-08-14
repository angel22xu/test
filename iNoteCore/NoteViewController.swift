//
//  NoteViewController.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/14.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate{

    //日志ID, 主键, 从上个页面传过来
    var vigSegue = ""
    //日志时间, 从上个页面传过来
    var noteTime = ""
    
    var gString =  NSMutableAttributedString()
    
    @IBOutlet weak var returnBtn: UIButton!
    @IBOutlet weak var finishBtn: UIBarButtonItem!
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var photeBtn: UIBarButtonItem!
    @IBOutlet weak var noteUpdateTime: UILabel!
    let size:Float = 64.0
    
    // 键盘高度
    var keyHeight = CGFloat()
    
    var cursorY: CGFloat = 0
    var cursorR: CGFloat = 0
    
    @IBAction func saveContent(sender: AnyObject) {
        
        //  TODO    这行代码会有bug，不能直接这样获取文本
        let content: String = detailTextView.textStorage.getPlainString()
        // TODO  获取detailTextView上的所有数据信息（图片，文字，视频，音频)
        
        let weather: String = "sunshine"
        
        let ct = Content(dict: ["noteID": Int(vigSegue)!, "content": content, "weather": weather ])
        ct.updateContent()
        
        // 获取第一行文字，作为标题保存在 indexConfig表里
        let dt: String = Tool.getCurrentDateStr()
        var title = detailTextView.text

        if title.characters.count < 15{
        }else{
            title = (title as NSString).substringToIndex(15) +  "・・・"
        }
        
        let t = Title(dict: ["noteID": Int(vigSegue)!, "title": title, "dt": dt ])
        t.updateTitle()
        
        // 收起输入键盘
        detailTextView.resignFirstResponder()
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteUpdateTime.text = Tool.formatDt1(noteTime)
        
        self.initTextView()
        
        //设置格式
        resetTextStyle()

        finishBtn.title = NSLocalizedString("SAVE", comment: "保存")
        photeBtn.title = NSLocalizedString("PHOTE", comment: "拍照")
        
        // 键盘上追加一个完成Done按钮
        initToolBar()

        // 添加监听事件
        let centerDefault = NSNotificationCenter.defaultCenter()
        centerDefault.addObserver(self, selector: #selector(NoteViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        centerDefault.addObserver(self, selector: #selector(NoteViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    // 键盘上追加一个完成Done按钮
    func initToolBar(){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "完成"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(NoteViewController.donePressed))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        self.detailTextView.delegate = self
        self.detailTextView.inputAccessoryView = toolBar
        
    }
    
    // 收起输入键盘
    func donePressed(){
        detailTextView.resignFirstResponder()
    }

    
    func initTextView(){
        gString  = NSMutableAttributedString(attributedString: detailTextView.attributedText)
        var arrayM = [Content]()
        if vigSegue == "" {
            
        }else{
            arrayM = Content.loadContents(Int(vigSegue)!)!
            if arrayM.isEmpty{
                detailTextView.text = ""
            }else{
                // 解析数据库读取出来的内容
                analysis_adv(arrayM[0].content!)
            }
        }
        
        detailTextView.scrollEnabled = true
//        detailTextView.selectedRange = NSMakeRange(0, 0)
 
//        detailTextView.setContentOffset(CGPointZero, animated: false)
//        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    //拍视频
    @IBAction func takeVideo(sender: AnyObject) {
    }
    
    
    /*
     拍照功能
     */
    @IBAction func fromPhotograph(sender: AnyObject) {
        
        detailTextView.resignFirstResponder()
        var sheet: UIActionSheet
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: "取消"), destructiveButtonTitle: nil,otherButtonTitles: NSLocalizedString("FROM_ALBUM", comment: "从相册选择"), NSLocalizedString("TAKE_PHOTE", comment: "拍照"))
        }else{
            sheet = UIActionSheet(title:nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: "取消"), destructiveButtonTitle: nil, otherButtonTitles: NSLocalizedString("FROM_ALBUM", comment: "从相册选择"))
        }
        sheet.showInView(self.view)
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // 创建图片控制器
        let picker = UIImagePickerController()

        
        if(buttonIndex != 0){
            if(buttonIndex==1){                                     //相册
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                detailTextView.resignFirstResponder()
            }else if(buttonIndex == 2){   //  相机
                sourceType = UIImagePickerControllerSourceType.Camera
            }else{   // 视频
                sourceType = UIImagePickerControllerSourceType.Camera
                picker.mediaTypes = [kUTTypeMovie as String]
            }
            // 设置代理
            picker.delegate = self
            
            // 只是来源
            picker.sourceType = sourceType
            
            //允许编辑
            picker.showsCameraControls = true

//            picker.allowsEditing = true
            
            let version = UIDevice.currentDevice().systemVersion
           
            if(Float(version) > 8.0){
                print("version:\(version)")
                
                ////bug：Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.  未解决

                picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            }
            
            
//            if self.presentedViewController != nil{
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }

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
       
        print("picker.mediaTypes: \(picker.mediaTypes)")
        let gTextAttachment = MediaTextAttachment()
        let currentDateStr: String = Tool.getCurrentDateStr()
        let randStr: String = Tool.getRandomStringOfLength(2)
        let imageName: String = currentDateStr + randStr + ".png"

        if(picker.mediaTypes == ["public.image"]){   // 拍照，图片相关
            var image: UIImage!
            

            // 判断，图片是否允许修改
            if (picker.allowsEditing){
                //裁剪后图片
                image = info[UIImagePickerControllerEditedImage] as! UIImage
            }else{
                //原始图片
                image = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            
            
            // 设图片标志（这里设置图片标志，主要是为了：表情转换字符串时 操作更简单）
            gTextAttachment.mediaTag = "![" + imageName + "]\n"
            
            // 设置图片
            gTextAttachment.image = scaleImage(image)
 
            let selectedRange = detailTextView.selectedRange
            
            detailTextView.textStorage.insertAttributedString(NSAttributedString(attachment: gTextAttachment), atIndex: selectedRange.location)
            
            print("imagePickerController 插入换行符")
            
            detailTextView.selectedRange = NSMakeRange(selectedRange.location+1, selectedRange.length)
            
            // 重置格式
            resetTextStyle()
            
            
            // 计算新的光标位置，并恢复光标的位置
            let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
            detailTextView.selectedRange = newSelectedRange
            
            
            //  TODO 跟画质有没有关系保存图片
            self.saveImage(image, newSize: CGSize(width: image.size.width, height: image.size.height), percent: 1, imageName: imageName)
            
        }else if(picker.mediaTypes == ["public.movie"]){   // 视频
            if let url = info[UIImagePickerControllerMediaURL] as? NSURL {
                // 端末のカメラロールに保存する
                UISaveVideoAtPathToSavedPhotosAlbum(url.path!, self, #selector(NoteViewController.video(_:didFinishSavingWithError:contextInfo:)), nil)
                
                
                print("url: \(url.path)")
                
                
            }
        }else{
            print("picker.mediaTypes: \(picker.mediaTypes) is not found")
        }
    }
    
    func video(videoPath: String, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        print("video: \(videoPath)")
        if (error != nil) {
            print("動画の保存に失敗しました。")
        } else {
            print("動画の保存に成功しました。")
        }
    }
    
    // 当用户取消时，调用该方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //保存图片至沙盒
    func saveImage(currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
        //压缩图片尺寸
        UIGraphicsBeginImageContext(newSize)
        currentImage.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
//        let imageData: NSData = UIImageJPEGRepresentation(newImage, percent)!
        let imageData: NSData = UIImagePNGRepresentation(newImage)!
        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
        
        // 获取沙盒路径
        let documentPath = Tool.getDocumentPath()
        let fullPath: String = documentPath.stringByAppendingPathComponent(imageName)

        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    
    // 解析内容，是图片的话显示图片
    func analysis_adv(content: String){
        print("analysis_adv content : \(content)")
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
            // 叹号
            if (rangeStr == exclamationMark){
                rangeStr = getSubstring(content, iStart: index + 1, iEnd: index + 2)
                rightRangeStr = getSubstring(content, iStart: index + 22, iEnd: index + 23)
                // 判断是否左括号右括号
                if(rangeStr == leftBrachket && rightRangeStr == rightBrachket){
                    let gTextAttachment = MediaTextAttachment()


                    rangeStr = getSubstring(content, iStart: index + 2, iEnd: index + 22)

                    imageNameStr = rangeStr
//                    print ("there is a picture imageNameStr: \(imageNameStr)")

                    // 页面上显示图片
                    fullPath = documentPath.stringByAppendingPathComponent(imageNameStr)
                    //下面使用新的方法来显示图片
                    
                    gTextAttachment.mediaTag = "![" + imageNameStr + "]"
                    gTextAttachment.image = scaleImage(UIImage(named:  fullPath)!)
                    

                    self.detailTextView.textStorage.insertAttributedString(NSAttributedString(attachment: gTextAttachment), atIndex: self.detailTextView.selectedRange.location)
                                        
                    self.detailTextView.selectedRange = NSMakeRange(self.detailTextView.selectedRange.location+1, self.detailTextView.selectedRange.length)
                    
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
                
                
                self.detailTextView.textStorage.insertAttributedString(NSAttributedString.init(string: mojiStr), atIndex: self.detailTextView.selectedRange.location)
                self.detailTextView.selectedRange = NSMakeRange(self.detailTextView.selectedRange.location+1, self.detailTextView.selectedRange.length)
                
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
//        let range = Range<String.Index>(start: startIndex, end: endIndex)
        let range: Range<String.Index> = startIndex ..< endIndex
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
        
        //设置字体大小
        detailTextView.textStorage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16), range: wholeRange)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 打开UITextView，默认显示最顶部（只有文字的时候没有问题，有图片的时候不好使）
        self.detailTextView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    // 监听键盘显示事件
    func keyboardWillShow(aNotification: NSNotification){
        //将通知的用户信息取出,转化为字典类型，里面所存的就是我们所需的信息:键盘动画的时长、时间曲线;键盘的位置、高度信息
        let userinfo: NSDictionary = aNotification.userInfo!
        
        //取出键盘高度
        let nsValue = userinfo.objectForKey(UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = nsValue?.CGRectValue()
        let height = keyboardRec?.size.height
        
        
        let options = UIViewAnimationOptions(rawValue: UInt((userinfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        
        self.keyHeight = height!
        
        self.cursorR = self.detailTextView.caretRectForPosition(self.detailTextView.selectedTextRange!.start).origin.y

        
        // 延迟执行， 这里不延迟执行的话，每次获取到的光标位置是上一次的位置
        let time: NSTimeInterval = 0.1
        let delay = dispatch_time(DISPATCH_TIME_NOW,
                                  Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.5, delay: 0.1, options:options, animations: {
//                print("keyboardWillShow y1:\(self.cursorY)")
                if(self.cursorY == 0){
                    self.cursorY = self.cursorR
                }
//                print("keyboardWillShow y2:\(self.cursorY)")

                if(self.cursorY > self.keyHeight - 70){
                    var frame = self.view.frame
                    frame.origin.y = -self.keyHeight
                    self.view.frame = frame
                }
                }, completion: nil)
        }
    }
    
    // 监听键盘隐藏事件
    func keyboardWillHide(aNotification: NSNotification){
        UIView.animateWithDuration(0.5, animations: {
            var frame = self.view.frame
            frame.origin.y = 0
            self.view.frame = frame
            }, completion: nil)
    }
    
    func textViewDidChangeSelection(textView: UITextView){
        // 点击UITextView的时候，获取当前航坐在的坐标位置
        textView.scrollRangeToVisible(textView.selectedRange)
        self.cursorY = self.detailTextView.caretRectForPosition(self.detailTextView.selectedTextRange!.start).origin.y
//        print("textViewDidChangeSelection:\(self.cursorY)")

    }

    func textViewDidChange(textView: UITextView){
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
    }
    
    
}
