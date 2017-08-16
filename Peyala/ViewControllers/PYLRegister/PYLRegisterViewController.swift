//
//  PYLRegisterViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLRegisterViewController: PYLBaseTableViewController , UITextFieldDelegate{
    
    //MARK:- Outlet Connections
    
    @IBOutlet weak var txtFirstName: TJTextField!
    @IBOutlet weak var txtLastName: TJTextField!
    @IBOutlet weak var txtGender: TJTextField!
    @IBOutlet weak var txtDateOfBirth: TJTextField!
    @IBOutlet weak var txtEmailID: TJTextField!
    @IBOutlet weak var txtMobileNo: TJTextField!
    @IBOutlet weak var txtZipcode: TJTextField!
    @IBOutlet weak var txtPassword: TJTextField!
    @IBOutlet weak var txtConfirmPass: TJTextField!
    @IBOutlet weak var txtReferralCode: TJTextField!
    @IBOutlet weak var buttonSignUp: UIButton!
    var registrationSuccess:((_ success: Bool)->())!
    
    override func viewDidLoad() {
        self.backButtonEnabled = true
        self.menuButtonEnabled = false
        self.rightLogoEnabled = true
        super.viewDidLoad()
        self.title = "CREATE ACCOUNT"
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return IS_IPAD() ? 60.0 :50.0
        }
        else if(indexPath.section == 1)
        {
            return IS_IPAD() ? 70.0 :60.0
        }else if indexPath.section == 0 && indexPath.row == 9{
            //MARK: Phase 2 remove this else
            return 0
        }
        return IS_IPAD() ? 60.0 :50.0
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    //MARK: - API section
    
    func callRegisterApi()
    {
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        PYLAPIHandler.handler.registerAccount(txtFirstName.text!, lastname: txtLastName.text!, gender: txtGender.text!, dob: txtDateOfBirth.text!, email: txtEmailID.text!, phone_no: txtMobileNo.text!, password: txtPassword.text!, zipcode: txtZipcode.text!,referralCode: txtReferralCode.text!, success: { (response) in
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
           
                self.view.showToastWithMessage(REGISTRATION_SUCCESSFULLY)
                
                self.successTaskRegisterApi(response!)
                
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.view.showToastWithMessage((error?.description)!)
        }
    }
    
    func successTaskRegisterApi(_ response: JSON) {
        
        //        "Responsedetails" : "Registration Successful",
        //        "userid" : "LCpisgeRXFiMmA9NOC9OQQ==",
        //        "lastname" : "HnAQ9xQhWnUGUeNGsVY7Jg==",
        //        "phone_no" : "mZYV5Ch0s0UNFWQ69FiZUw==",
        //        "firstname" : "DUbNKhmt2c9ks\/DeVI4RIQ==",
        //        "profile_image_url" : "aVc7tuSFH6iHNKiJ5Dd4Sw==",
        //        "zipcode" : "osOpuauGdFJ0wu5mMZciYg==",
        //        "address" : "aVc7tuSFH6iHNKiJ5Dd4Sw==",
        //        "dob" : "0Dr8zT7vdc5IXWBM6PMi7g==",
        //        "session_id" : "XefNHAFmVU0NC8SNKxYtQkIbyvz2NGgVWrksCq1lwROMJ4FE9uJSK3yAVSNULUWs",
        //        "email" : "0FdD1jHYsw9YjGqcAV9SaA==",
        //        "gender" : "lPOX\/Hvn25NdjduH6UZ0\/Q==",
        //        "ResponseCode" : "200"
        
        PYLHelper.helper.userModelObj = ModelUser(userID:"\(response["userid"].stringValue.getAESDecryption())", firstName: "\(response["firstname"].stringValue.getAESDecryption())", lastName: "\(response["lastname"].stringValue.getAESDecryption())", email: "\(response["email"].stringValue.getAESDecryption())", address: "\(response["address"].stringValue.getAESDecryption())", profileImageUrl: "\(response["profile_image_url"].stringValue.getAESDecryption())",phone:"\(response["phone_no"].stringValue.getAESDecryption())",zipCode:"\(response["zipcode"].stringValue.getAESDecryption())",gender:"\(response["gender"].stringValue.getAESDecryption())",dob:"\(response["dob"].stringValue.getAESDecryption())",loyaltypoint : (response["loyalty_point"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),loyaltypercentage : response["loyalty_percentage"].stringValue.getAESDecryption(), loyaltycash: (response["loyalty_cash"].stringValue.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal(),loyaltyunitvalue: response["loyalty_unit_value"].stringValue.getAESDecryption())
        
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        PYLHelper.helper.sessionID = response["session_id"].stringValue
        SET_USERDEFAULT_VALUE(PYLHelper.helper.sessionID as AnyObject, forKey: USER_DEFAULT_SESSION_ID_KEY)
        SET_CART_BADGE("\((String(describing: response["addtocart_count"])).getAESDecryption())")
        //SET_NOTIFICATION_BADGE(String.getSafeString(String(describing: response["notification_count"]) as AnyObject?).getAESDecryption())
        SET_NOTIFICATION_STATUS("\((String(describing: response["notification_status"])).getAESDecryption())")
        PYLAPIManager.sharedManager.header += ["session_id": (PYLHelper.helper.sessionID)]
        debugPrint(response["userid"].stringValue.getAESDecryption())
        
        if registrationSuccess != nil {
            registrationSuccess(true)
            debugPrint("registration Done")
        }
        self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLDashBoardViewController.self))
    }
    
    //MARK:- TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName {
            txtLastName.becomeFirstResponder()
        }else if textField == txtLastName {
            txtGender.becomeFirstResponder()
        }else if textField == txtGender {
            txtDateOfBirth.becomeFirstResponder()
        }else if textField == txtEmailID {
            txtMobileNo.becomeFirstResponder()
        }else if textField == txtMobileNo {
            txtPassword.becomeFirstResponder()
        }else if textField == txtPassword {
            txtConfirmPass.becomeFirstResponder()
        }else if textField == txtConfirmPass {
            txtZipcode.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if ((textField.keyboardType == .numberPad) || (textField.keyboardType == .phonePad)){
            textField.showToolBar()
        }else{
            textField.hideToolBar()
        }
        
        if textField == txtDateOfBirth {
            self.view.endEditing(true)
            PYLPickerViewController.showPickerController(self, isDatePicker: true, pickerArray: [], position: .bottom, pickerTitle: "", preSelected: textField.text!, selected: { (value, index) in
                
                if value != nil {
                    guard (value as! String).length > 0 else { return }
                    textField.text = value as? String
                }
            })
            
        } else if textField == txtGender {
            self.view.endEditing(true)
            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: ["Male","Female"], position: .bottom, pickerTitle: "", preSelected: textField.text!, selected: { (value, index) in
                
                guard (value as! String).length > 0 else { return }
                textField.text = value as? String
            })
        }
        return true;
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField == txtDateOfBirth || textField == txtGender{
            self.view.endEditing(true)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard !string.containsEmoji() else { return false }
        
        var strText = String()
        if (range.length == 0){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.insert(string, at: range.location)
            strText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.deleteCharacters(in: range)
            strText = stringNew as String
        }
        if ((textField == txtMobileNo || textField == txtZipcode) && !strText.isNumber) { return false }
        if (textField == txtMobileNo &&  strText.length > MAX_PHONE_NO_LIMIT) { return false }
        return true
    }
    
    
    //MARK:- Button Actions
    @IBAction func onCreateAccount(_ sender: AnyObject) {
        if txtFirstName.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_FIRST_NAME)
            self.txtFirstName.becomeFirstResponder()
            
        } else if txtFirstName.text!.hasSpecialCharacter() {
            
            self.view.showToastWithMessage(SPECIAL_CHARACTER_NOT_ALLOWED)
            self.txtFirstName.becomeFirstResponder()
            
        } else if txtLastName.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_LAST_NAME)
            self.txtLastName.becomeFirstResponder()
            
        } else if txtLastName.text!.hasSpecialCharacter() {
            
            self.view.showToastWithMessage(SPECIAL_CHARACTER_NOT_ALLOWED)
            self.txtLastName.becomeFirstResponder()
            
        } else if txtGender.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_GENDER)
            self.txtGender.becomeFirstResponder()
            
        } else if txtDateOfBirth.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_DOB)
            self.txtDateOfBirth.becomeFirstResponder()
            
        } else if txtEmailID.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_EMAIL)
            self.txtEmailID.becomeFirstResponder()
            
        } else if txtEmailID.text!.isValidEmail == false {
            
            self.view.showToastWithMessage(VALID_EMAIL)
            self.txtEmailID.becomeFirstResponder()
            
        } else if txtMobileNo.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_MOBILE_NO)
            self.txtMobileNo.becomeFirstResponder()
            
        } else if txtMobileNo.text!.isPhoneNumber == false {
            
            self.view.showToastWithMessage(NOT_VALID_MOBILE)
            self.txtMobileNo.becomeFirstResponder()
            
        } else if txtPassword.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_PASSWORD)
            self.txtPassword.becomeFirstResponder()
            
        } else if txtConfirmPass.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_CONFIRM_PASSWORD)
            self.txtConfirmPass.becomeFirstResponder()
            
        } else if txtPassword.text! != txtConfirmPass.text! {
            
            self.view.showToastWithMessage(PASSWORD_MISSMATCH)
            self.txtPassword.becomeFirstResponder()
            
        } else if txtZipcode.text!.isBlank {
            
            self.view.showToastWithMessage(BLANK_ZIP_CODE)
            self.txtZipcode.becomeFirstResponder()
        }
        else {
            
            callRegisterApi()
            /*
             PYLAPIHandler.handler.registerAccount(txtFirstName.text!, lastname: txtLastName.text!, gender: txtGender.text!, dob: txtDateOfBirth.text!, email: txtEmailID.text!, phone_no: txtMobileNo.text!, password: txtPassword.text!, zipcode: txtZipcode.text!, success: { (response) in
             
             }) { (error) in
             
             }
             */
        }
    }
    @IBAction func onConnectFacebook(_ sender: AnyObject) {
        initiateFacebookLoginProtocol { (succeed) in
            if succeed {
                debugPrint("Logged In via FB")
                //self.pushToDashboard()
            }
        }
    }
    
    @IBAction func onAlreadyRegister(_ sender: AnyObject) {
        PYLNavigationHelper.helper.navigationController.popViewController(animated: true)
    }
    
    func callIsUserLoginApi(_ userID: String)
    {
        PYLAPIHandler.handler.isUserlogin(userID, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskRegisterApi(response!)
                
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            self.view.showToastWithMessage((error?.description)!)
        }
    }
    
}
