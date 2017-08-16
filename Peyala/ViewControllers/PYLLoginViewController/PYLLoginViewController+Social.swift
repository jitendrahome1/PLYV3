//
//  CMLoginViewController+Social.swift
//  CiplaMed
//
//  Created by Priyam Dutta on 19/08/16.
//  Copyright © 2016 Indus Net Technologies. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit


struct constantIDs {

}

var socialLoginSucceed: ((_ succeed: Bool)->())!

extension PYLLoginViewController{
    
    //Login API
    func callLoginAPI(_ email: String, identifier: String, provider: String, success:(_ suceed: Bool)->()) {
        /*
        PYLAPIHandler.handler.loginSocial(email, identifier: identifier, provider: provider, success: { (response) in
            
            SET_OBJ_FOR_KEY(response["sessid"].string!, key: kSessionID)
            SET_OBJ_FOR_KEY(response["session_name"].string!, key: kSessionName)
            SET_OBJ_FOR_KEY(response["token"].string!, key: kToken)
            SET_BOOL_FOR_KEY(true, key: kIsLoggedIn)
            
            HTTPManager.sharedManager.header += ["Cookie" : "\(OBJ_FOR_KEY(kSessionName)!)=\(OBJ_FOR_KEY(kSessionID)!)" , "X-CSRF-Token" : "\(OBJ_FOR_KEY(kToken)!)"]
            SET_OBJ_FOR_KEY(response["user"]["uid"].string!, key: kUserID)
            CMHelper.helper.userID = response["user"]["uid"].string!
            CMHelper.helper.userName = response["user"]["name"].string!
            SET_OBJ_FOR_KEY(CMHelper.helper.userName! , key: kUserName)
            
            CMHelper.helper.userTitle = ""
            SET_OBJ_FOR_KEY(CMHelper.helper.userTitle! , key: kUserTitle)
            
            CMHelper.helper.userQualification = ""
            SET_OBJ_FOR_KEY(CMHelper.helper.userQualification! , key: kUserQualification)
            
            let tid =  response["user"]["field_spec"]["und"][0]["tid"].string!
            SET_OBJ_FOR_KEY(tid, key: kSpecialityID)
            SET_BOOL_FOR_KEY(false, key: kNightMode)
            SET_BOOL_FOR_KEY(true, key: kMobileDataDownloadMode)
            SET_BOOL_FOR_KEY(false, key: kMobileDataDownloadMode)
            if CMHelper.helper.deviceID != nil{
                CMAPIHandler.handler.registerDevice({ (response) in
                    debugPrint("Device Registration Successful")
                    }, failure: { (error) in
                        debugPrint("Error")
                        self.view.showToastWithMessage(error.description)
                })
            }
            
            success(suceed: true)
            }, failure: { (error) in
                success(suceed: false)
        })
 */
    }
    
    //Facebook
    func initiateFacebookLoginProtocol(_ success:@escaping (_ succeed: Bool)->()) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.view.isUserInteractionEnabled = false
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if (error != nil) {
                self.view.isUserInteractionEnabled = true
                success(false)
            }else if (result?.isCancelled)! {
                self.view.isUserInteractionEnabled = true
                success(false)
            }else {
                self.view.isUserInteractionEnabled = true
                PYLSpinner.show()
                let graphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,email,first_name,last_name,birthday,picture,gender", parameters: nil)
                _ = graphRequest?.start(completionHandler: { (connection, result, eror) in
                 PYLSpinner.hide()
                    if (eror != nil) {
                        success(false)
                    }else{
                        let result = result as! [String : Any]
                        if let _ = result["email"]  {
                            let firstname = result["first_name"] as? String ?? ""
                            let lastname = result["last_name"] as? String ?? ""
                            let dob = result["birthday"] as? String ?? ""
                            let profilePicURL = ((result["picture"] as? [String:AnyObject])!["data"] as? [String :AnyObject])!["url"] as? String ?? ""
                            let gender = result["gender"] as? String ?? ""
                            let id = result["id"] as? String ?? ""
                            let email = result["email"] as? String ?? ""
                            
                           PYLAPIHandler.handler.socialLogin(id, email: email, firstName: firstname, lastName:lastname, gender: gender, dob: dob, fbImageURL: profilePicURL, success: { (response) in
                            switch (response?["ResponseCode"])! {
                            case "200":
                                self.successTaskLoginApi(response!)
                                 success(true)
                            case "204":
                                let alertController = UIAlertController.showStandardAlertWith(response!["Responsedetails"].stringValue, alertText: STILL_WANT_TO_LOGIN, cancelTitle: "", doneTitle: "", selected_: { (index) in
                                    if (index == 1) {
                                        self.callIsUserLoginApi(response!["userid"].stringValue)
                                         success(true)
                                    }
                                })
                                self.present(alertController, animated: true, completion: nil)
                            default :
                                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                                
                            }
                            }, failure: { (error) in
                                
                           })
                        }else{
                            self.present( UIAlertController.showStandardAlertWithTextField(kAppTitle, alertText: ENTER_EMAIL) { (index, email) in
                                if index == 1 {
                                    if email.isValidEmail {
                                        let firstname = result["first_name"] as? String ?? ""
                                        let lastname = result["last_name"] as? String ?? ""
                                        let dob = result["birthday"] as? String ?? ""
                                        let profilePicURL = ((result["picture"] as? [String:AnyObject])!["data"] as? [String :AnyObject])!["url"] as? String ?? ""
                                        let gender = result["gender"] as? String ?? ""
                                        let id = result["id"] as? String ?? ""
                                        let email = email
                                        
                                        PYLAPIHandler.handler.socialLogin(id, email: email, firstName: firstname, lastName:lastname, gender: gender, dob: dob, fbImageURL: profilePicURL, success: { (response) in
                                            switch (response?["ResponseCode"])! {
                                            case "200":
                                                self.successTaskLoginApi(response!)
                                                success(true)
                                            case "204":
                                                let alertController = UIAlertController.showStandardAlertWith(response!["Responsedetails"].stringValue, alertText: STILL_WANT_TO_LOGIN, cancelTitle: "", doneTitle: "", selected_: { (index) in
                                                    if (index == 1) {
                                                        self.callIsUserLoginApi(response!["userid"].stringValue)
                                                        success(true)
                                                    }
                                                })
                                                self.present(alertController, animated: true, completion: nil)
                                            default :
                                                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                                                
                                            }
                                            }, failure: { (error) in
                                                
                                        })
                                   }else{
                                        self.view.showToastWithMessage(ENTER_VALID_EMAILID)
                                    }
                                }
                                }, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }

}
extension PYLRegisterViewController{
    func initiateFacebookLoginProtocol(_ success:@escaping (_ succeed: Bool)->()) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.view.isUserInteractionEnabled = false
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (results, error) in
            if (error != nil) {
                self.view.isUserInteractionEnabled = true
                success(false)
            }else if (results?.isCancelled)! {
                self.view.isUserInteractionEnabled = true
                success(false)
            }else {
                self.view.isUserInteractionEnabled = true
                PYLSpinner.show()
                
        
                let graphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,email,first_name,last_name,birthday,picture,gender", parameters: nil)
                _ = graphRequest?.start(completionHandler: { (connection, result, eror) in
                    PYLSpinner.hide()
                    if (eror != nil) {
                        success(false)
                    }else{
                       
                        let result = result as! [String:AnyObject]
                        if let _ = result["email"] {
                            let firstname = result["first_name"] as? String ?? ""
                            let lastname = result["last_name"] as? String ?? ""
                            let dob = result["birthday"] as? String ?? ""
                            let profilePicURL = ((result["picture"] as? [String:AnyObject])!["data"] as? [String :AnyObject])!["url"] as? String ?? ""
                            let gender = result["gender"] as? String ?? ""
                            let id = result["id"] as? String ?? ""
                            let email = result["email"] as? String ?? ""
                            
                            PYLAPIHandler.handler.socialLogin(id, email: email, firstName: firstname, lastName:lastname, gender: gender, dob: dob, fbImageURL: profilePicURL, success: { (response) in
                                switch (response?["ResponseCode"].stringValue)! {
                                case "200":
                                    self.successTaskRegisterApi(response!)
                                    success(true)
                                case "204":
                                    let alertController = UIAlertController.showStandardAlertWith(response!["Responsedetails"].stringValue, alertText: STILL_WANT_TO_LOGIN, cancelTitle: "", doneTitle: "", selected_: { (index) in
                                        if (index == 1) {
                                            self.callIsUserLoginApi(response!["userid"].stringValue)
                                            success(true)
                                        }
                                    })
                                    self.present(alertController, animated: true, completion: nil)
                                default :
                                    self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                                    
                                }
                                }, failure: { (error) in
                            })
                        }else{
                            self.present( UIAlertController.showStandardAlertWithTextField(kAppTitle, alertText: ENTER_EMAIL) { (index, email) in
                                if index == 1 {
                                    if email.isValidEmail {
                                        let firstname = result["first_name"] as? String ?? ""
                                        let lastname = result["last_name"] as? String ?? ""
                                        let dob = result["birthday"] as? String ?? ""
                                        let profilePicURL = ((result["picture"] as? [String:AnyObject])!["data"] as? [String :AnyObject])!["url"] as? String ?? ""
                                        let gender = result["gender"] as? String ?? ""
                                        let id = result["id"] as? String ?? ""
                                        let email = email
                                        
                                        PYLAPIHandler.handler.socialLogin(id, email: email, firstName: firstname, lastName:lastname, gender: gender, dob: dob, fbImageURL: profilePicURL, success: { (response) in
                                            switch (response?["ResponseCode"].stringValue)! {
                                            case "200":
                                                self.successTaskRegisterApi(response!)
                                                success(true)
                                            case "204":
                                                let alertController = UIAlertController.showStandardAlertWith(response!["Responsedetails"].stringValue, alertText: STILL_WANT_TO_LOGIN, cancelTitle: "", doneTitle: "", selected_: { (index) in
                                                    if (index == 1) {
                                                        self.callIsUserLoginApi(response!["userid"].stringValue)
                                                        success(true)
                                                    }
                                                })
                                                self.present(alertController, animated: true, completion: nil)
                                            default :
                                                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                                                
                                            }
                                            }, failure: { (error) in
                                                
                                        })
                                    }else{
                                        self.view.showToastWithMessage(ENTER_VALID_EMAILID)
                                    }
                                }
                                }, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
}
































