//
//  PYLLoginViewController.swift
//  Peyala
//
//  Created by Chinmay Das on 01/08/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLLoginViewController: PYLBaseViewController {
    
    //MARK:- Outlet Connections
    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    var loginSuccess:((_ success: Bool)->())!
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.menuButtonEnabled = false
        self.cartButtonEnabled = false
        self.notificationButtonEnabled = false
        self.searchButtonEnabled = false
        //self.rightLogoEnabled = false
        self.backButtonEnabled = true
        super.viewDidLoad()
        self.title = "SIGN IN"
        //#if DEBUG // TODO
        //            self.textEmail.text = "swapnasish.dutta@indusnet.co.in"
        //            self.textPassword.text = "123456"
        //#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textEmail.text = ""
        textPassword.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK: - API section
    func callLoginApi()
    {
        self.view.endEditing(true)
        PYLAPIHandler.handler.login(textEmail.text, password: textPassword.text, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskLoginApi(response!)
            case "204":
                let alertController = UIAlertController.showStandardAlertWith(response!["Responsedetails"].stringValue, alertText: STILL_WANT_TO_LOGIN, cancelTitle: "No", doneTitle: "Yes", selected_: { (index) in
                    if (index == 1) {
                        self.callIsUserLoginApi(response!["userid"].stringValue)
                    }
                })
                self.present(alertController, animated: true, completion: nil)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                
            }
        }) { (error) in
            self.view.showToastWithMessage((error?.description)!)
        }
    }
    
    func callIsUserLoginApi(_ userID: String)
    {
        PYLAPIHandler.handler.isUserlogin(userID, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskIsUserLoginApi(response!)
                
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            self.view.showToastWithMessage((error?.description)!)
        }
    }
    
    func successTaskIsUserLoginApi(_ response: JSON) {
        
        PYLHelper.helper.userModelObj = ModelUser(userID: response["userid"].stringValue.getAESDecryption(),
                                                  firstName: response["firstname"].stringValue.getAESDecryption(), lastName: response["lastname"].stringValue.getAESDecryption(), email: response["email"].stringValue.getAESDecryption(),
                                                    address: response["address"].stringValue.getAESDecryption(), profileImageUrl: response["profile_image_url"].stringValue.getAESDecryption(),
                                                    phone:response["phone_no"].stringValue.getAESDecryption(),
                                                    zipCode:response["zipcode"].stringValue.getAESDecryption(),
                                                    gender:response["gender"].stringValue.getAESDecryption(),
                                                    dob:response["dob"].stringValue.getAESDecryption(),
                                                    loyaltypoint : (response["loyalty_point"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),loyaltypercentage : response["loyalty_percentage"].stringValue.getAESDecryption(),
                                                    loyaltycash: (response["loyalty_cash"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),
                                                    loyaltyunitvalue: response["loyalty_unit_value"].stringValue.getAESDecryption())
        
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        SET_CART_BADGE("\((String(describing: response["addtocart_count"])).getAESDecryption())")
        //SET_NOTIFICATION_BADGE(String.getSafeString(String(describing: response["notification_count"]) as AnyObject?).getAESDecryption())
        if ((response["notification_count"]).exists()) {
            SET_NOTIFICATION_BADGE(String.getSafeString(String(describing: (response["notification_count"])).getAESDecryption() as AnyObject))
        }
        else {
            SET_NOTIFICATION_BADGE("")
        }
        SET_NOTIFICATION_STATUS("\((String(describing: response["notification_status"])).getAESDecryption())")
        PYLHelper.helper.sessionID = response["session_id"].stringValue
        SET_USERDEFAULT_VALUE(PYLHelper.helper.sessionID as AnyObject, forKey: USER_DEFAULT_SESSION_ID_KEY)
        PYLAPIManager.sharedManager.header += ["session_id": (PYLHelper.helper.sessionID)]
        debugPrint(response["userid"].stringValue.getAESDecryption())
        //self.pushToViewController(servicesStoryboard, viewController: String(PYLDashBoardViewController)) // navvvvvv
        //goToRespectiveScreen(PYLHelper.helper.nextViewControllerStoryBoard, viewController: PYLHelper.helper.nextViewControllerIdentifier)
        if loginSuccess != nil {
            PYLHelper.helper.LogginStatusChanged = true
            loginSuccess(true)
        }
        
        debugPrint("Logged In")
        
    }
    
    func successTaskLoginApi(_ response: JSON) {
        
        PYLHelper.helper.userModelObj = ModelUser(userID: response["userid"].stringValue.getAESDecryption(), firstName: response["firstname"].stringValue.getAESDecryption(), lastName: response["lastname"].stringValue.getAESDecryption(), email: response["email"].stringValue.getAESDecryption(), address: response["address"].stringValue.getAESDecryption(), profileImageUrl: response["profile_image_url"].stringValue.getAESDecryption(),phone:response["phone_no"].stringValue.getAESDecryption(),zipCode:response["zipcode"].stringValue.getAESDecryption(),gender:response["gender"].stringValue.getAESDecryption(),dob:response["dob"].stringValue.getAESDecryption(),loyaltypoint : (response["loyalty_point"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),loyaltypercentage : response["loyalty_percentage"].stringValue.getAESDecryption(), loyaltycash: (response["loyalty_cash"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),loyaltyunitvalue: response["loyalty_unit_value"].stringValue.getAESDecryption())
        
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        PYLHelper.helper.sessionID = response["session_id"].stringValue
        SET_USERDEFAULT_VALUE(PYLHelper.helper.sessionID as AnyObject, forKey: USER_DEFAULT_SESSION_ID_KEY)
        SET_NOTIFICATION_STATUS("\((String(describing: response["notification_status"])).getAESDecryption())")
        SET_CART_BADGE("\(response["addtocart_count"].stringValue.getAESDecryption())")
        //SET_NOTIFICATION_BADGE(String.getSafeString(String(describing: response["notification_count"]) as AnyObject?).getAESDecryption())
        if ((response["notification_count"]).exists()) {
            SET_NOTIFICATION_BADGE(String.getSafeString(String(describing: (response["notification_count"])).getAESDecryption() as AnyObject))
        }
        else {
            SET_NOTIFICATION_BADGE("")
        }
        PYLAPIManager.sharedManager.header += ["session_id": (PYLHelper.helper.sessionID)]
        debugPrint(response["userid"].stringValue.getAESDecryption())
        //self.navigationController?.popViewControllerAnimated(true) // navvvvvv
        //goToRespectiveScreen(PYLHelper.helper.nextViewControllerStoryBoard, viewController: PYLHelper.helper.nextViewControllerIdentifier)
        if loginSuccess != nil {
            PYLHelper.helper.LogginStatusChanged = true
            loginSuccess(true)
            debugPrint("Logged In")
        }
    }
    
    //MARK: - User Defined Function
    func goToRespectiveScreen(_ storyboardName:UIStoryboard , viewController : String) {
        let viewController = storyboardName.instantiateViewController(withIdentifier: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK:- Button Actions
    @IBAction func actionLogin(_ sender: AnyObject) {
        
        if textEmail.text!.isBlank {
            self.view.showToastWithMessage(BLANK_EMAIL_OR_MOBILE_NUMBER)
            self.textEmail.becomeFirstResponder()
        }else if !textEmail.text!.isValidEmail && !textEmail.text!.isPhoneNumber {
            self.textEmail.becomeFirstResponder()
            self.view.showToastWithMessage(MOBILE_NUMBER_OR_EMAIL_NOT_VALID)
        }else if textPassword.text!.isBlank {
            self.textPassword.becomeFirstResponder()
            self.view.showToastWithMessage(BLANK_PASSWORD)
        }else{
            //API Calling
            callLoginApi()
        }
    }
    
    //MARK: Social login
    
    @IBAction func facebookLoginAction(_ sender: AnyObject) {
        initiateFacebookLoginProtocol { (succeed) in
            if succeed {
                debugPrint("Logged In via FB")
                //self.pushToDashboard()
            }
        }
    }
}
