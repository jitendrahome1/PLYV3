//
//  PYLAddLocationManuallyViewController.swift
//  Peyala
//
//  Created by Soumen Das on 13/09/16.
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


class PYLAddLocationManuallyViewController: PYLBaseViewController {
    
    //MARK: - Outlet Collection
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var buttonSelectCountry: UIButton!
    @IBOutlet weak var buttonEnterLocation: UIButton!
    
    var selectedCountryName: String = ""
    var selectedCountryID: String = ""
    var selectedBranchName: String = ""
    var selectedBranchID: String = ""
    var strPickerList = ""
    var pickerStr = ""
    var branchNameArray = [String]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            let arrRightBarBtn = self.navigationItem.rightBarButtonItems!
            let barBtnFlag = arrRightBarBtn.last!
            let buttonFlag = barBtnFlag.customView as! UIButton
            buttonFlag.isHidden = true
        }
        
        
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentWithAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Defined Function
    
    func presentWithAnimation() {
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        label1.translatesAutoresizingMaskIntoConstraints = true
        label2.translatesAutoresizingMaskIntoConstraints = true
        
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Float(M_PI * 2.0 * 2 * 0.5) as Float) //[NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 1000
        
        self.locationImage.layer.add(rotationAnimation, forKey:"rotationAnimation")
        
        var frame1 = label1.frame
        let OriginalFrame1 = frame1
        frame1.origin.x = 0
        frame1.origin.x = -frame1.size.width
        label1.frame = frame1
        
        var frame2 = label2.frame
        let OriginalFrame2 = frame2
        frame2.origin.x = self.view.bounds.size.width
        label2.frame = frame2
       
        /*
        let triggerTime = (Int64(NSEC_PER_SEC) * (1/2))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            UIView.animateWithDuration(0.5, animations: {
                
                self.label1.frame = OriginalFrame1
                self.label2.frame = OriginalFrame2
                
            }) { (true) in
                self.locationImage.layer.removeAnimationForKey("rotationAnimation")
            }
        })
        */
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options:UIViewAnimationOptions.curveEaseIn, animations: {
            self.label1.frame = OriginalFrame1
            self.label2.frame = OriginalFrame2
            }, completion: { (true) in
                self.locationImage.layer.removeAnimation(forKey: "rotationAnimation")
        })
    }
    
    func setUpperNavigationItems() {
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
//        self.rightLogoEnabled = false
        self.rightLogoEnabled = true
        self.title = "MANUAL LOCATION"
    }
    
    func fetchCountriesSuccessTasks() {
        PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: PYLHelper.helper.countryNameArray, position: .bottom, pickerTitle: "", preSelected: selectedCountryName, selected: { (value, index) in
            
            self.buttonSelectCountry.isEnabled = true
            guard (value as! String).length > 0 else { return }
            
            self.selectedCountryID = ((PYLHelper.helper.countryArrayDetails[index!]["country_id"]! as? String)!).getAESDecryption()
            PYLHelper.helper.selectedCountryFlagURL = ((PYLHelper.helper.countryArrayDetails[index!]["country_flag_img_url"]! as? String)!).getAESDecryption()
            self.buttonSelectCountry.setTitle("\(value!)", for: UIControlState())
            self.buttonSelectCountry.setTitle("\(value!)", for: .highlighted)
            self.buttonSelectCountry.setTitle("\(value!)", for: .selected)
            
            self.loadFlagImage()
            
            if self.selectedCountryName != value as! String {
                self.selectedBranchName = ""
                self.buttonEnterLocation.setTitle("Select Location", for: UIControlState())
                self.buttonEnterLocation.setTitle("Select Location", for: .highlighted)
                self.buttonEnterLocation.setTitle("Select Location", for: .selected)
            }
            
            self.selectedCountryName = "\(value)"
            //Tax tasks
            self.callTaxApi(self.selectedCountryID)
        })
    }
    
    // MARK: - Button Action
    
    @IBAction func selectCountryAction(_ sender: UIButton) {
        
        sender.isEnabled = false
        if PYLHelper.helper.countryNameArray.count > 0 {
            fetchCountriesSuccessTasks()
        } else {
            //            self.view.showToastWithMessage("\(NO_DATA_FOUND)")
            callCountryListApi({ (isSuccess) in
                
                guard isSuccess else {
                    sender.isEnabled = true
                    return
                }
                self.fetchCountriesSuccessTasks()
            })
        }
    }
    
    @IBAction func enterLocationAction(_ sender: UIButton) {
        
        if selectedCountryName.length > 0 {
            
            PYLAPIHandler.handler.getBranchesByCountry(selectedCountryID, success: { (response) in
                //                sender.enabled = true
                //                self.branchNameArray = [String]()
                //                
                //                if let getArray = response["branch_details"].arrayObject {
                //                    
                //                    if getArray.count > 0 {
                //                        
                //                        for (index, _) in getArray.enumerate() {
                //                            self.branchNameArray.append(((getArray[index]["branch_name"]! as? String)!).getAESDecryption())
                //                        }
                //                        
                //                        PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: self.branchNameArray, position: .Bottom, pickerTitle: "", preSelected: self.selectedBranchName, selected: { (value, index) in
                //                            
                //                            guard (value as! String).length > 0 else { return }
                //                            
                //                            self.selectedBranchName = "\(value)"
                //                            self.selectedBranchID = ((getArray[index]["branch_id"]! as? String)!).getAESDecryption()
                //                            self.buttonEnterLocation.setTitle("\(value)", forState: .Normal)
                //                            self.buttonEnterLocation.setTitle("\(value)", forState: .Highlighted)
                //                            self.buttonEnterLocation.setTitle("\(value)", forState: .Selected)
                //                        })
                //                    }
                //                }
                
                self.offlineOrSuccessResponseHandleGetBranchesByCountryApi(response!, sender: sender)
                },
                                                       offlineBlock: { (response) in
                                                        self.offlineOrSuccessResponseHandleGetBranchesByCountryApi(response!, sender: sender)
                }
                , failure: { (error) in
                    sender.isEnabled = true
            })
        } else {
            // show alert for no country selection
            sender.isEnabled = true
            self.view.showToastWithMessage("\(SELECT_COUNTRY_FIRST)")
        }
    }
    
    @IBAction func okButtonAction(_ sender: AnyObject) {
        
        if selectedCountryName.length > 0 && selectedBranchName.length > 0 {
            
            //self.pushToViewController(servicesStoryboard, viewController: String(PYLDashBoardViewController))
            PYLSpinner.show()
            // imageeeeeeeee downloaddd
            if let url = URL(string: PYLHelper.helper.selectedCountryFlagURL) {
                let request = URLRequest(url: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: .main, completionHandler: { (response, data, error) in
                    PYLSpinner.hide()
                    if data?.count > 0{
                        PYLHelper.helper.selectedCountryFlagImage = UIImage(data: data!)!
                    }
                    self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLDashBoardViewController.self))
                })
            }
            
        } else {
            self.view.showToastWithMessage("\(CHOOSE_OPTIONS)")
        }
    }
    
    func loadFlagImage() {
        let arrRightBarBtn = self.navigationItem.rightBarButtonItems!
        let barBtnFlag = arrRightBarBtn.last!
        let buttonFlag = barBtnFlag.customView as! UIButton
        
        
        if let url = URL(string: PYLHelper.helper.selectedCountryFlagURL) {
            let request = URLRequest(url: url)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: .main, completionHandler: { (response, data, error) in
                if data?.count > 0{
                    PYLHelper.helper.selectedCountryFlagImage = UIImage(data: data!)!
                    DispatchQueue.main.async(execute: {
                        buttonFlag.isHidden = false
                        buttonFlag.setImage(PYLHelper.helper.selectedCountryFlagImage, for: UIControlState())
                    })
                }
            })
        }
    }
    
    //MARK: Api Section
    
    func callTaxApi(_ countryID:String)
    {
        PYLAPIHandler.handler.getTax(countryID, success:{ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTasksGetTaxApi(response!)
            default :
                break
            }
        }) { (error) in
            
        }
    }
    
    func callCountryListApi(_ completion:@escaping (_ isSuccess:Bool)->()) {
        
        PYLAPIHandler.handler.getCountryList({ (response) in
            
            //            switch (response["ResponseCode"]) {
            //            case "200":
            //                if let getArray = response["country_list"].arrayObject {
            //                    if getArray.count > 0 {
            //                        
            //                        PYLHelper.helper.countryArrayDetails = getArray
            //                        for (index, _) in getArray.enumerate() {
            //                            PYLHelper.helper.countryNameArray.append(((getArray[index]["country_name"]! as? String)!).getAESDecryption())
            //                        }
            //                    }
            //                }
            //                completion(isSuccess: true)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //                completion(isSuccess: false)
            //                break
            //            }
            
            self.offlineOrSuccessResponseHandleCountryListApi(response!, completion: completion)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleCountryListApi(response!, completion: completion)
        }) { (error) in
            debugPrint("\(error)")
            //            self.view.showToastWithMessage(PROBLEM_OCCOURED)
            completion(false)
        }
    }
    
    func successTasksGetTaxApi(_ response: JSON) {
        //        {
        //            "tax_details" : [
        //            {
        //            "tax_name" : "hw8akfb15LvGQIY1eZJbgw==",
        //            "tax_percentage" : "KDjeKtaPsHkM14qyQ3m\/tQ=="
        //        },
        //        {
        //            "tax_name" : "PN0qceSq4pjIQogw9TD6fg==",
        //            "tax_percentage" : "a\/33viCjRrNpylX1jXZ5NQ=="
        //        }
        //        ],
        //        "ResponseCode" : "200",
        //        "Responsedetails" : "success"
        
        PYLHelper.helper.arrTax = [ModelTax]()
        for dict in response["tax_details"].arrayObject! {
            let dictTax = dict as! [String:String]
            let taxObj = ModelTax()
            taxObj.taxName = String.getSafeString(dictTax["tax_name"] as AnyObject?).getAESDecryption()
            taxObj.taxPercentage = String.getSafeString(dictTax["tax_percentage"] as AnyObject?).getAESDecryption()
            PYLHelper.helper.arrTax.append(taxObj)
        }
    }
    
    func offlineOrSuccessResponseHandleCountryListApi(_ response: JSON, completion:(_ isSuccess:Bool)->()) {
        switch (response["ResponseCode"]) {
        case "200":
            if let getArray = response["country_list"].arrayObject {
                if getArray.count > 0 {
                    
                    PYLHelper.helper.countryArrayDetails = getArray as [AnyObject]
                    for (index, _) in getArray.enumerated() {
                        PYLHelper.helper.countryNameArray.append((((getArray[index] as AnyObject)["country_name"]! as? String)!).getAESDecryption())
                    }
                }
            }
            completion(true)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
            completion(false)
            break
        }
    }
    
    func offlineOrSuccessResponseHandleGetBranchesByCountryApi(_ response: JSON, sender:UIButton) {
        sender.isEnabled = true
        self.branchNameArray = [String]()
        
        if let getArray = response["branch_details"].arrayObject {
            
            if getArray.count > 0 {
                
                for (index, _) in getArray.enumerated() {
                    self.branchNameArray.append((((getArray[index] as AnyObject)["branch_name"]! as? String)!).getAESDecryption())
                }
                
                PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: self.branchNameArray, position: .bottom, pickerTitle: "", preSelected: self.selectedBranchName, selected: { (value, index) in
                    
                    guard (value as! String).length > 0 else { return }
                    
                    self.selectedBranchName = "\(value)"
                    self.selectedBranchID = (((getArray[index!] as AnyObject)["branch_id"]! as? String)!).getAESDecryption()
                    self.buttonEnterLocation.setTitle("\(value!)", for: UIControlState())
                    self.buttonEnterLocation.setTitle("\(value!)", for: .highlighted)
                    self.buttonEnterLocation.setTitle("\(value!)", for: .selected)
                })
            }
        }
    }
    
}
