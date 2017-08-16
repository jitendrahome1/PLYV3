//
//  PYLForgotPasswordViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLForgotPasswordViewController: PYLBaseViewController,UITextFieldDelegate {
    
    //MARK:- Outlet connections
    
    @IBOutlet weak var buttonEmailID: UIButton!
 @IBOutlet weak var buttonSMS: UIButton!
    
    @IBOutlet weak var textfieldRetrieveSelection: UITextField!
    override func viewDidLoad() {
        self.backButtonEnabled = true
        self.menuButtonEnabled = false
        super.viewDidLoad()
        self.title = "FORGOT PASSWORD"
        self.view.layoutIfNeeded()
        buttonEmailID.imageEdgeInsets = UIEdgeInsetsMake(0, 2,0, buttonEmailID.frame.width - 28)
        buttonEmailID.isSelected = true
        buttonSMS.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, buttonSMS.frame.width - 28)
        //UIEdgeInsetsMake(<#T##top: CGFloat##CGFloat#>, <#T##left: CGFloat##CGFloat#>, <#T##bottom: CGFloat##CGFloat#>, <#T##right: CGFloat##CGFloat#>)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK:- TExtField delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
   //MARK:- Button Actions
    
    @IBAction func OnEmailSmsSelection(_ sender: UIButton!) {
        self.textfieldRetrieveSelection.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        buttonSMS.isSelected = false
        buttonEmailID.isSelected = false
        sender.isSelected = true
        textfieldRetrieveSelection.resignFirstResponder()
        if buttonEmailID.isSelected {
            textfieldRetrieveSelection.placeholder = "Enter your email id here"
            textfieldRetrieveSelection.text = ""
            textfieldRetrieveSelection.keyboardType = .emailAddress
            textfieldRetrieveSelection.hideToolBar()
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options:UIViewAnimationOptions.curveEaseIn, animations: {
                 self.textfieldRetrieveSelection.transform = CGAffineTransform.identity
                }, completion: { (true) in
                    
            })
          
        }
        else if buttonSMS.isSelected{
            textfieldRetrieveSelection.placeholder = "Enter your mobile number here"
            textfieldRetrieveSelection.text = ""
            textfieldRetrieveSelection.keyboardType = .phonePad
            textfieldRetrieveSelection.showToolBar()
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options:UIViewAnimationOptions.curveEaseIn, animations: {
                self.textfieldRetrieveSelection.transform = CGAffineTransform.identity
                }, completion: { (true) in
                    
            })
        }
        textfieldRetrieveSelection.becomeFirstResponder()
    }
    
    
    @IBAction func onOkSelection(_ sender: AnyObject) {
        
        var isSuccess = true
        
        if textfieldRetrieveSelection.text!.isBlank {
            self.view.showToastWithMessage(ENTER_CREDENTIAL)
            self.textfieldRetrieveSelection.becomeFirstResponder()
            isSuccess = false
        }
        else if buttonEmailID.isSelected {
            guard ((self.textfieldRetrieveSelection.text?.isValidEmail) == true) else {
                self.view.showToastWithMessage(ENTER_VALID_EMAILID)
                isSuccess = false
                return
            }
            isSuccess = true
        }
        
        if isSuccess == true {
            PYLAPIHandler.handler.resetPasswordwith(buttonSMS.isSelected ?"SMS" : "EMAIL", emailORphone: textfieldRetrieveSelection.text!, success: { (response) in
                
                    self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                
                }, failure: { (error) in
                    
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
