//
//  PYLTakeAwayServicePopUpViewController.swift
//  Peyala
//
//  Created by Soumen Das on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PYLTakeAwayServicePopUpViewController: PYLBasePopUpViewController,UITextFieldDelegate {
    
    enum popUpType: Int {
        case kTakeAway = 0
        case kDelivery = 1
    }
    
    // MARK: - Outlet Collections
    
    @IBOutlet weak var buttonCross:         UIButton!
    @IBOutlet weak var buttonTakeAwayNow:   UIButton!
    @IBOutlet weak var buttonTakeAwayLater: UIButton!
    @IBOutlet weak var viewCenter:          UIView!
    @IBOutlet weak var textFieldForTime:    UITextField!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textFieldTimeSlot: TJTextField!
    @IBOutlet weak var viewForTimeSlot: UIView!

    @IBOutlet var constraintTimeSlotHeight: NSLayoutConstraint!
    var dissmissPopUpAction:(()->())!
    var chooseOkAction:(()->())!
    var sourceViewController: UIViewController?
    var getPopUpType: popUpType?
    var branchDetails: [[String:AnyObject]] = []
    
    
    
    let arrOptions = [["image":"ServiceOptionTakeAwayIcon","optionOne":"Takeaway now","optionTwo":"Takeaway later"],
                      ["image":"ServiceOptionDeliverycar","optionOne":"Delivery now","optionTwo":"Delivery later"]]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create time slot here
        debugPrint("iii\(branchDetails)")
        self.radioButtonAction(buttonTakeAwayNow)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        //        buttonCross.center = CGPointMake(CGRectGetMaxX(viewCenter.frame), CGRectGetMinY(viewCenter.frame))
        buttonCross.center = CGPoint(x: viewCenter.frame.maxX, y: viewCenter.frame.minY)
        var frame: CGRect
        frame = buttonCross.frame
        frame.origin.x = frame.origin.x - popupRedCrossButtonPadding
        frame.origin.y = frame.origin.y + popupRedCrossButtonPadding
        buttonCross.frame = frame
        self.view.bringSubview(toFront: viewCenter)
        self.view.bringSubview(toFront: buttonCross)
    }
    
    //MARK:- UITextField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if(textField == textFieldForTime) {
            var cafeclosingTime = ""
            var cafestartTime = ""
            if let closingTime = branchDetails[0]["branch_order_end_time"] as? String{
                cafeclosingTime =  closingTime.getAESDecryption()
            }
            if let startTime = branchDetails[0]["branch_start_time"] as? String{
                cafestartTime =  startTime.getAESDecryption()
            }
            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: getAvailableTimeIntervals(cafeclosingTime,cafeStartTime:cafestartTime), position: .bottom, pickerTitle: "", preSelected: textField.text!, selected: { (value, index) in
               
                guard (value as! String).length > 0 else { return }
                textField.text = "\(value as! String)"
                
                PYLHelper.helper.selectedSlot = "\(Date().convertTime24("\(textField.text!.components(separatedBy: " - ").first!)"))-\(Date().convertTime24("\(textField.text!.components(separatedBy: " - ").last!)"))"
            })
        }
        return true
    }
    
    func getAvailableTimeIntervals(_ cafeCloseTime:String,cafeStartTime:String) -> [String]{
        let closingTimePart = cafeCloseTime.length > 0 ? cafeCloseTime.components(separatedBy: ":").first!.toFloat() : "22:00".components(separatedBy: ":").first!.toFloat()
        var closingHour = "\(closingTimePart!)"
        closingHour = closingHour.components(separatedBy: ".").first!
        
        let openHourPart = cafeStartTime.length > 0 ? cafeStartTime.components(separatedBy: ":").first!.toFloat() : "10:00".components(separatedBy: ":").first!.toFloat()
        //let OpeningMinute = cafeStartTime.components(separatedBy: ":").last!.toFloat()
        var openingHour = "\(openHourPart!)"
        openingHour = openingHour.components(separatedBy: ".").first!
        
        var arrSlots = [String]()
        let currentTime = Date().currentTime24()
        if currentTime.Hour > Int(openingHour) && currentTime.Hour < Int(closingHour) {
            for i in currentTime.Hour ..< Int(closingHour)! {
                arrSlots.append("\(Date().convertTime12("\(i)")) - \(Date().convertTime12("\(i+1)"))")
            }
            return arrSlots
        }
        return []
        
    }
    
    // MARK: - User Defined Functiom
    
    internal class func showTakeAwayPopUp(_ sourceController: UIViewController, branchData:[[String:AnyObject]], type: popUpType, selected:@escaping ()->(), dissmiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: "PYLTakeAwayServicePopUpViewController") as! PYLTakeAwayServicePopUpViewController
        viewController.sourceViewController = sourceController
        viewController.chooseOkAction = selected
        viewController.dissmissPopUpAction = dissmiss
        viewController.getPopUpType = type
        viewController.branchDetails = branchData
        viewController.presentPopUP(sourceController,type: type)
    }
    
    func presentPopUP(_ sourceController: UIViewController, type: popUpType) {
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        
        presentAnimationToView()
        
        let dictOption = arrOptions[type.rawValue]
        imageViewIcon.image = UIImage(named: dictOption["image"]!)
        buttonTakeAwayNow.setTitle(dictOption["optionOne"], for: UIControlState())
        buttonTakeAwayLater.setTitle(dictOption["optionTwo"], for: UIControlState())
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.viewCenter.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        imagevwBackground.alpha = 0.0
        buttonCross.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
             self.imagevwBackground.alpha = 0.7
            self.buttonCross.isHidden = false
            self.viewCenter.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimate(_ Closed:Bool) {
        UIView.animate(withDuration: 0.25, animations: {
             self.imagevwBackground.alpha = 0.0
            self.buttonCross.isHidden = true
            self.viewCenter.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if Closed == true{
                if self.dissmissPopUpAction != nil {
                    self.dissmissPopUpAction()
                }
            }else{
                if self.chooseOkAction != nil {
                    self.chooseOkAction()
                }
            }
        }) 
    }
    
    func setupUI() {
        if !IS_IPAD() {
            buttonTakeAwayNow.contentHorizontalAlignment = .left
            buttonTakeAwayNow.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            
            buttonTakeAwayLater.contentHorizontalAlignment = .left
            buttonTakeAwayLater.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        }
    }
    
    // MARK: - Button Action
    
    @IBAction func radioButtonAction(_ sender: UIButton) {
        if sender == buttonTakeAwayNow {
            let currentTime = Date().currentTime24()
            PYLHelper.helper.selectedSlot = "\(currentTime.Hour)-\(currentTime.Hour + 1)"
            buttonTakeAwayNow.isSelected = true
            buttonTakeAwayLater.isSelected = false
            viewForTimeSlot.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {
                self.viewForTimeSlot.alpha = 0
                self.constraintTimeSlotHeight.constant = 0
            })
        }
        else {
            var cafeclosingTime = ""
            var cafeStartTime = ""
            if let closingTime = branchDetails[0]["branch_order_end_time"] as? String{
                cafeclosingTime =  closingTime.getAESDecryption()
            }
            if let startTime = branchDetails[0]["branch_start_time"] as? String{
                cafeStartTime =  startTime.getAESDecryption()
            }
            if getAvailableTimeIntervals(cafeclosingTime,cafeStartTime: cafeStartTime).count > 0  {
                textFieldForTime.text = getAvailableTimeIntervals(cafeclosingTime, cafeStartTime: cafeStartTime)[0]
                textFieldForTime.isEnabled = true
                PYLHelper.helper.selectedSlot = "\(Date().convertTime24("\(textFieldForTime.text!.components(separatedBy: " - ").first!)"))-\(Date().convertTime24("\(textFieldForTime.text!.components(separatedBy: " - ").last!)"))"
            }else{
                textFieldForTime.text = "No slots available"
                textFieldForTime.isEnabled = false
            }
            buttonTakeAwayNow.isSelected = false
            buttonTakeAwayLater.isSelected = true
            viewForTimeSlot.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {
                  self.viewForTimeSlot.alpha = 1
                  self.constraintTimeSlotHeight.constant = IS_IPAD() ? 50 : 30
            })
        }
    }
    
    
    @IBAction func okButtonAction(_ sender: AnyObject) {
        guard (buttonTakeAwayNow.isSelected != buttonTakeAwayLater.isSelected) else {
            self.view.showToastWithMessage(SELECT_ANY_ANSWER)
            return
        }
    
        dismissAnimate(false)
      
    }
    
    @IBAction func crossButtonAction(_ sender: AnyObject) {
        dismissAnimate(true)
       
    }
}
