//
//  RandomLabelView.swift
//  RandomLabelView
//
//  Created by 高添 on 15/6/1.
//  Copyright (c) 2015年 高添. All rights reserved.
//  弹幕弹出工具，
//  外部只需要通过单例方法调用BarrageManager即可值

import UIKit

var frameArray = Array<CGRect>()       // frame数组
let barrageHeight: CGFloat = 40.0      // 弹幕高度
let SCREEN_HEIGHT:CGFloat = UIScreen.mainScreen().bounds.size.height
let SCREEN_WIDTH :CGFloat = UIScreen.mainScreen().bounds.size.width

// 弹幕管理类
class BarrageManager: NSObject {
    var isAnimation = false
    
    // 消息数组copy
    private var messageCopy = [NSDictionary]()
    
    // 单例
    class func shareInstance() -> BarrageManager {
        struct GTSingleton {
            static var predicate: dispatch_once_t = 0
            static var instance: BarrageManager? = nil
        }
        dispatch_once(&GTSingleton.predicate, { () -> Void in
            GTSingleton.instance = BarrageManager()
        })
        return GTSingleton.instance!
    }
    
    // 弹出警告弹幕
    func showWarnMessage(message:String,time:NSTimeInterval){
        //    if isAnimation {return}
        //    isAnimation = true
        let window = UIApplication.sharedApplication().keyWindow
        let messageLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        let centerX = window!.frame.size.width/2
        let centerY = window!.frame.size.height/2
        let str = NSString(string: "  " + message + "  ")
        messageLabel.font = UIFont.boldSystemFontOfSize(14.0)
        let size = str.sizeWithAttributes([NSFontAttributeName : messageLabel.font])
        messageLabel.frame = CGRectMake(0, 0, size.width, 30)
        messageLabel.layer.cornerRadius = 15
        messageLabel.clipsToBounds = true
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.center = CGPointMake(centerX, centerY)
        messageLabel.backgroundColor = UIColor(red: 141/255, green: 141/255, blue: 141/255, alpha: 0.85)
        messageLabel.text = message
        messageLabel.textColor = UIColor.whiteColor()
        window!.addSubview(messageLabel)
        
        UIView.animateWithDuration(time, animations: { () -> Void in
            messageLabel.alpha = 0
            }) { (finish) -> Void in
                messageLabel.removeFromSuperview()
                //        self.isAnimation = false
        }
    }
    
    // 消息数组，此处可修改业务逻辑，
    private var messageArray = [NSDictionary]() {
        didSet {
            if frameArray.count < 5 && messageCopy.count > 0 {
                
                // 取出弹幕内容
                let message = messageCopy.last!
                // 删除消息
                self.messageCopy.removeLast()
                
                // 头像地址
//                let imagePath = imageBeforeStr + userOrderModel!.imagePath
                // 创建弹幕视图
                let barrageView = BarrageView()
                
                barrageView.labelString = message["message"] as! String;
//                barrageView.iconURL = NSURL(string: imagePath)!
                
                // 计算弹幕frame
                let caculate = Caculate()
//                barrageView.frame = caculate.fixedBarrageFrame(messageStr)
                barrageView.frame = caculate.caculateSlideBarrageFrame(barrageView.labelString)

                // 生成的frame存进数组
                frameArray.insert(barrageView.frame, atIndex: 0)
                
                // 弹幕添加到window上
                let window: AnyObject? = UIApplication.sharedApplication().windows.first
                window!.addSubview(barrageView)
                
                barrageView.deleteMessage = {() -> Void in
                    frameArray.removeLast()
                    self.messageArray.removeLast()
                }
            }
        }
    }
    
    // MARK: 弹幕弹出方法
    func showBarrage(message: NSDictionary) {
        
        messageCopy.insert(message, atIndex: 0)
        messageArray.insert(message, atIndex: 0)
    }
}

// 计算弹幕frame、宽度类
class Caculate {
    
    let shopingCartHeight:CGFloat = 50.0   // 底部购物车高度
    
    // MARK: 根据弹幕内容计算弹幕长度
    func caculateBarrageWidth(messageStr: String) -> CGFloat {
        
        let label = UILabel()
        label.text = messageStr
        label.font = UIFont.systemFontOfSize(13)
        label.sizeToFit()
        
        // 计算弹幕长度
        let barrageWidth: CGFloat = barrageHeight + label.frame.width + 20.0
        
        // 获取弹幕frame
        return barrageWidth
        
    }
    
    // MARK: 加减菜弹幕时弹出的弹幕
    func fixedBarrageFrame(messageStr: String) -> CGRect {
        
        // 计算弹幕长度
        let barrageWidth: CGFloat = caculateBarrageWidth(messageStr)
        
        let newFrame = CGRectMake(0, SCREEN_HEIGHT - shopingCartHeight - barrageHeight, barrageWidth, barrageHeight)
        
        return newFrame
    }
    
    
    
    // MARK: 自动生成弹幕frame
    func caculateBarrageFrame(messageStr: String) -> CGRect {
        
        let barrageWidth: CGFloat = caculateBarrageWidth(messageStr)
        
        let window = UIApplication.sharedApplication().keyWindow
        var newFrame = CGRectNull
        
        while true {
            var j = 0
            // 生成随机点
            
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
            
            let randomX = arc4random_uniform(UInt32(window!.frame.width - barrageWidth))
            let randomY = arc4random_uniform(UInt32(window!.frame.height - barrageHeight - shopingCartHeight - statusBarHeight - 60 - 44)) + UInt32(statusBarHeight + 60 + 44)
            
            newFrame = CGRectMake(CGFloat(randomX), CGFloat(randomY), barrageWidth, barrageHeight)
            if frameArray.count == 0 {
                return newFrame
            } else {
                for i in 0..<frameArray.count {
                    let barrageFrame = frameArray[i]
                    if CGRectIntersectsRect(newFrame, barrageFrame) {
                        break
                    }
                    j++
                }
            }
            if j == frameArray.count {
                return newFrame
            }
        }
    }
    
    // MARK: 屏幕右侧生成弹幕frame(滑动弹幕)
    func caculateSlideBarrageFrame(messageStr: String) -> CGRect {
        // 计算弹幕长度
        let barrageWidth: CGFloat = caculateBarrageWidth(messageStr)
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height   // 状态栏高度
        
        var newFrame = CGRectNull
        while true {
            var j = 0
            
            let randomY = arc4random_uniform(UInt32(SCREEN_HEIGHT - barrageHeight - shopingCartHeight - statusBarHeight - 60 - 44)) + UInt32(statusBarHeight + 60 + 44)
            
            newFrame = CGRectMake(SCREEN_WIDTH, CGFloat(randomY), barrageWidth, barrageHeight)
            if frameArray.count == 0 {
                return newFrame
            } else {
                for i in 0..<frameArray.count {
                    let barrageFrame = frameArray[i]
                    if CGRectIntersectsRect(newFrame, barrageFrame) {
                        break
                    }
                    j++
                }
            }
            if j == frameArray.count {
                return newFrame
            }
        }
    }
}

// 弹幕View
class BarrageView : UIView {
    
    var barrageLabel = UILabel()            // 弹幕label
    var barrageImageView: UIImageView!    // 弹幕人物头像
    var labelString: String = ""          // 弹幕内容
    var sliding = true     // 是否滑动
    var iconURL = NSURL()  {                  // 头像url
        didSet {
            // 此处可设置左侧头像
//            barrageImageView.sd_setImageWithURL(iconURL, placeholderImage: UIImage(named: "FaceIcon"))
            
        }
    }
    let iconWidth: CGFloat = barrageHeight          // 头像边长
    var deleteMessage = {() -> Void in}
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        // 设置弹幕自身属性
        self.alpha = 0
        self.backgroundColor = UIColor(red: 42 / 255.0, green: 165 / 255.0, blue: 127 / 255.0, alpha: 1)
        self.clipsToBounds = true
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = barrageHeight * 0.5
        
        // 创建头像
        barrageImageView = UIImageView(frame: CGRectMake(0, 0, iconWidth, iconWidth))
        barrageImageView.layer.masksToBounds = true
        barrageImageView.layer.cornerRadius = iconWidth * 0.5
        barrageImageView.backgroundColor = UIColor.blueColor()
        
        self.addSubview(barrageImageView)
        
        // 创建弹幕内容
        barrageLabel.textColor = UIColor.whiteColor()
        barrageLabel.font = UIFont.systemFontOfSize(13)
        
        self.addSubview(barrageLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // 设置label属性
        barrageLabel.text = labelString
        barrageLabel.frame = CGRectMake(barrageHeight + 10.0, 0, self.frame.width - barrageImageView.frame.width, barrageHeight)
        
        // 弹幕弹出动画
//                barrageFromOrignPop(self.frame)
//        barrageFromCenterPop(self.frame)
        
        barrageFromRightOfScreen()
        
        
    }
    
    // MARK: 以orign为起点弹出弹幕动画
    func barrageFromOrignPop(newFrame: CGRect) {
        
        self.frame = CGRectMake(newFrame.origin.x, newFrame.origin.y, 0, 0)
        
        // 弹出弹幕动画
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1
            self.frame = newFrame
        })
        
        // 弹幕消失动画
        UIView.animateWithDuration(1.5, delay: 2.0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            self.alpha = 0
            //            self.frame = CGRectMake(newFrame.origin.x, newFrame.origin.y, 0, 0)
            }, completion: { (finished) -> Void in
                // 移除弹幕和frame
                self.removeFromSuperview()
                self.deleteMessage()
        })
    }
    
    // MARK: 以center为起点弹出弹幕动画
    func barrageFromCenterPop(newFrame: CGRect) {
        
        // 计算center
        let centerX: CGFloat = newFrame.origin.x + newFrame.size.width * 0.5
        let centerY: CGFloat = newFrame.origin.y + newFrame.size.height * 0.5
        let center = CGPointMake(centerX, centerY)
        
        self.center = center
        self.bounds = CGRectMake(0, 0, 0, 0)
        
        // 弹出弹幕动画
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1
            self.bounds = CGRectMake(0, 0, newFrame.width, newFrame.height)
        })
        
        // 弹幕消失动画
        UIView.animateWithDuration(1.5, delay: 2.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alpha = 0
            //            self.bounds = CGRectMake(0, 0, 0, 0)
            }) { (finished) -> Void in
                // 移除弹幕和frame
                self.removeFromSuperview()
                self.deleteMessage()
        }
    }
    
    // MARK: 从屏幕右侧向左滑
    func barrageFromRightOfScreen() {
        self.alpha = 1
        
//        var anime = CATransition()
//        anime.duration = 2.0
//        anime.fillMode = kCAFillModeForwards
//        self.layer.addAnimation(anime, forKey: "abc")
        
        UIView.animateWithDuration(3.0, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.frame.origin.x -= SCREEN_WIDTH + self.frame.width
        }) { (finished) -> Void in
            self.removeFromSuperview()
            self.deleteMessage()
        }

    }
}
