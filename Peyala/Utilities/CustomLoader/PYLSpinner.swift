//
//  PYLSpinner.swift
//  Peyala
//
//  Created by Soumen Das on 27/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

let MAIN_WINDOW = UIApplication.shared.windows.first
let SPINER_HEIGHT = IS_IPAD() ? CGFloat(80.0):CGFloat(50.0)
var isHudVisible = false

class PYLSpinner: UIView {
    
    var circleLayer: CAShapeLayer?
    var isAnimating = false
    
    
    static var tempSelf: PYLSpinner? = PYLSpinner()
    static var tempImage: UIImageView?
    static var tempBlurView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInIt()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInIt()
    }
    
    func commonInIt() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        circleLayer = CAShapeLayer()
        self.layer.addSublayer(circleLayer!)
        
        circleLayer?.fillColor = nil
        circleLayer?.lineCap = kCALineCapRound
        circleLayer?.lineWidth = 1.5
        
        circleLayer?.strokeColor = UIColor.orange.cgColor
        circleLayer?.strokeStart = 0.0
        circleLayer?.strokeEnd = 0.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !circleLayer!.frame.equalTo(self.bounds){
            self.updateCircleLayer()
        }
    }
    
    func updateCircleLayer() {
        let center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let radius = self.bounds.height / 2.0 - circleLayer!.lineWidth / 2.0
        let startAngle = CGFloat(0.0)
        let endAngle = CGFloat(2 * M_PI)
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        circleLayer?.path = path.cgPath
        circleLayer?.frame = self.bounds
    }
    
    func forceBeginRefreshing() {
        isAnimating = false
        beginRefreshing()
    }
    
    func beginRefreshing() {
        if isAnimating {
            return
        }
        
        isAnimating = true
        
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotateAnimation.values = [0, M_PI, 2 * M_PI]
        
        let headAnimation = CABasicAnimation()
        headAnimation.keyPath = "strokeStart"
        headAnimation.duration = 1.0;
        headAnimation.fromValue = 0.0;
        headAnimation.toValue = 0.25;
        
        let tailAnimation = CABasicAnimation()
        tailAnimation.keyPath = "strokeEnd"
        tailAnimation.duration = 1.0
        tailAnimation.fromValue = 0.0
        tailAnimation.toValue = 1.0
        
        let endHeadAnimation = CABasicAnimation()
        endHeadAnimation.keyPath = "strokeStart"
        endHeadAnimation.beginTime = 1.0
        endHeadAnimation.duration = 1.0
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1.0;
        
        let endTailAnimation = CABasicAnimation()
        endTailAnimation.keyPath = "strokeEnd"
        endTailAnimation.beginTime = 1.0
        endTailAnimation.duration = 1.0
        endTailAnimation.fromValue = 1.0
        endTailAnimation.toValue = 1.0
        
        let animations = CAAnimationGroup()
        animations.duration = 2.0
        animations.animations = [rotateAnimation, headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        animations.repeatCount = Float.infinity;
        
        circleLayer?.add(animations, forKey: "animations")
    }
    
    func endRefreshing() {
        isAnimating = false
        circleLayer?.removeAnimation(forKey: "animations")
    }
    
    class func show() {
        isHudVisible = true
        var spiner: PYLSpinner?
        var imageView: UIImageView?
        let bothFrame = CGRect(x: 100, y: 100, width: SPINER_HEIGHT, height: SPINER_HEIGHT)
        var backLayer: UIView?
        
        if (PYLSpinner.tempSelf)!.isAnimating {
            spiner = PYLSpinner.tempSelf
            imageView = PYLSpinner.tempImage
            backLayer = PYLSpinner.tempBlurView
        }else{
            spiner = PYLSpinner()
            imageView = UIImageView(frame: bothFrame)
            backLayer = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT ))
        }
        
        
        imageView!.image = UIImage(named: "ContactUsPeyalaLogo")
        imageView?.contentMode = .scaleAspectFit
        
        spiner!.circleLayer!.lineWidth = 2.0;
        spiner!.circleLayer!.strokeColor = UIColor.green.cgColor //whiteColor().CGColor
        
        spiner!.frame = imageView!.bounds
        
        backLayer?.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        imageView?.frame = CGRect(x: (backLayer!.bounds.width / 2) - (SPINER_HEIGHT / 2), y: (backLayer!.bounds.height / 2) - (SPINER_HEIGHT / 2), width: SPINER_HEIGHT, height: SPINER_HEIGHT)
        imageView!.addSubview(spiner!)
        backLayer!.addSubview(imageView!)
        MAIN_WINDOW!.addSubview(backLayer!)
        PYLSpinner.tempImage = imageView
        PYLSpinner.tempSelf = spiner
        PYLSpinner.tempBlurView = backLayer
        spiner!.beginRefreshing()
    }
    
    class func hide() {
        isHudVisible = false
        if PYLSpinner.tempBlurView != nil {
            PYLSpinner.tempSelf?.endRefreshing()
            PYLSpinner.tempBlurView!.removeFromSuperview()
        }
    }
    
    //MARK: App when comes to fore-ground
    func appBecameActive() {
        if isHudVisible {
            PYLSpinner.hide()
            PYLSpinner.show()
        }
    }
}
