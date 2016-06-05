//
//  MediaTextAttachment.swift
//  iNoteCore
//
//  Created by xuxiaomin on 16/5/29.
//  Copyright © 2016年 xuxiaomin. All rights reserved.
//

import UIKit
import Foundation

// 存放媒体标识（图片，mp3，录音，视频）
class MediaTextAttachment: NSTextAttachment{
    var mediaTag:NSString?
    var mediaSize:CGFloat?
    
//    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
//        return self.scaleImageSizeToWidth(mediaSize!)
//    }
    
    
    func scaleImageSizeToWidth(width:CGFloat)->CGRect{
        //Scale factor
        var factor:CGFloat = 1.0
        
        //Get image size
        let oriSize = self.image?.size
        
        //Calculate factor
        factor = width/oriSize!.width
        //Get new size
        let newSize = CGRectMake(0, 0, oriSize!.width * factor, oriSize!.height * factor)
        return newSize
        
    }
    
    
    
}

//extension NSAttributedString {
//    func getPlainString()->String{
//        let plainString = NSMutableString(string: self.string)
//        
//        
//        var  base = 0
//        let ranges =  NSMakeRange(0, self.length)
//        
//        print("getPlainString: \(plainString), length: \(self.length)")
//
//        self.enumerateAttribute(NSAttachmentAttributeName, inRange:ranges, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired)
//        { (value, range, error) -> Void in
//            if (value != nil) {
//                if value is MediaTextAttachment{
//                    let makeRange = NSMakeRange(range.location+base, range.length)
//                    let  media = value as! MediaTextAttachment
//                    
//                    print("media.mediaTag!: \(media.mediaTag)")
//
//                    plainString.replaceCharactersInRange(makeRange, withString: media.mediaTag as! String)
//                    base = base + (media.mediaTag?.length)!-1
//                }
//                
//            }
//        }
//        
//        
//        return plainString as String
//    }
//}



extension NSAttributedString {
    func getPlainString()->String{
        let plainString = NSMutableString(string: self.string)
        var  base = 0
        let ranges =  NSMakeRange(0, self.length)
        self.enumerateAttribute(NSAttachmentAttributeName, inRange:ranges, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired)
        { (value, range, error) -> Void in
            if (value != nil) {
                if value is MediaTextAttachment{
                    let makeRange = NSMakeRange(range.location+base, range.length)
                    let  emoji = value as! MediaTextAttachment
                    plainString.replaceCharactersInRange(makeRange, withString: emoji.mediaTag! as String)
                    base = base + (emoji.mediaTag?.length)!-1
                }
                
            }
        }
        
        
        return plainString as String
    }
}