//
//  PYLInvitePopUpViewController.swift
//  Peyala
//
//  Created by Adarsh on 15/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

import ContactsUI

class PYLInvitePopUpViewController: PYLBaseViewController, CNContactPickerDelegate {

    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnMobile: UIButton!
    @IBOutlet weak var txtFieldInvite: UITextField!
    @IBOutlet weak var btnAddressBook: UIButton!
    @IBOutlet weak var constraintTxtFieldTrail: NSLayoutConstraint!
    
    var dissmissPopUpAction:(()->())!
    var sourceViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        //by default, 'email' will be selected.
        emailEnableSettings()
    }
    
    // MARK: - User Defined Functiom\ns
    internal class func showInvitePopUp(_ sourceController: UIViewController, dissmiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLInvitePopUpViewController.self)) as! PYLInvitePopUpViewController
        viewController.sourceViewController = sourceController
        viewController.dissmissPopUpAction = dissmiss
        viewController.presentPopUP()
    }
    
    func presentPopUP() {
        
        self.view.frame = sourceViewController!.navigationController!.view.bounds
        sourceViewController!.navigationController!.view.addSubview(self.view)
        sourceViewController!.navigationController!.addChildViewController(self)
        sourceViewController!.navigationController!.view.bringSubview(toFront: self.view)
        
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if self.dissmissPopUpAction != nil {
                self.dissmissPopUpAction()
            }
        }) 
    }
    
    func emailEnableSettings() {
        //radio buttons
        btnEmail.isSelected = true
        btnEmail.isUserInteractionEnabled = false
        
        btnMobile.isSelected = false
        btnMobile.isUserInteractionEnabled = true
        
        //addressbook task
        btnAddressBook.isHidden = true
        constraintTxtFieldTrail.constant = 0
        txtFieldInvite.layoutIfNeeded()
        
        //textfield keyboard
        txtFieldInvite.text = ""
        txtFieldInvite.keyboardType = UIKeyboardType.emailAddress
        txtFieldInvite.hideToolBar()
    }
    
    func mobileEnableSettings() {
        //radio buttons
        btnMobile.isSelected = true
        btnMobile.isUserInteractionEnabled = false
        
        btnEmail.isSelected = false
        btnEmail.isUserInteractionEnabled = true
        
        //addressbook task
        btnAddressBook.isHidden = false
        constraintTxtFieldTrail.constant = -btnAddressBook.frame.width
        txtFieldInvite.layoutIfNeeded()
        
        //textfield keyboard
        txtFieldInvite.text = ""
        txtFieldInvite.keyboardType = UIKeyboardType.numberPad
        txtFieldInvite.showToolBar()
    }
    
    func validateFields() -> Bool {
        guard !txtFieldInvite.text!.isBlank else {
            return false
        }
        
        var validate = true
        if btnEmail.isSelected {
            if !txtFieldInvite.text!.isValidEmail {
                validate = false
            }
        }
        
        return validate
    }
    
    //MARK: - Actions
    @IBAction func emailMobileRadioBtnActions(_ sender: UIButton) {
        if (sender == btnEmail) {
            emailEnableSettings()
        }
        else {
            mobileEnableSettings()
        }
        
        //first close the previous keyboard having one keyboard type, then after delay open the keyboard again for another keyboard type.
        if txtFieldInvite.isFirstResponder {
            txtFieldInvite.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.txtFieldInvite.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func submitInviteBtnAction(_ sender: UIButton) {
        txtFieldInvite.resignFirstResponder()
        if validateFields() {
            //submit task
            callInviteFriendApi({ 
                self.dismissAnimate()
            })
        }
    }
    
    @IBAction func crossBtnAction(_ sender: UIButton) {
        dismissAnimate()
    }
    
    @IBAction func phoneBookBtnAction(_ sender: UIButton) {
        if #available(iOS 9.0, *) {
            let contactPickerViewController = CNContactPickerViewController()
            contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.count > 0")
            contactPickerViewController.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            contactPickerViewController.delegate = self
            
            present(contactPickerViewController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // MARK: CNContactPickerDelegate function
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //        debugPrint("Phone no. : \(contact.phoneNumbers) ")
        guard contact.phoneNumbers.count > 0 else {
            return
        }
        debugPrint("Phone no. : \((contact.phoneNumbers.first!.value ).value(forKey: "digits") as! String) ")
        txtFieldInvite.text = (contact.phoneNumbers.first!.value ).value(forKey: "digits") as? String
    }
    
    //MARK: - API section
    func callInviteFriendApi(_ success:@escaping ()->())
    {
        let emailID: String? = btnEmail.isSelected ? txtFieldInvite.text! : nil
        let mobile: String? = !btnEmail.isSelected ? txtFieldInvite.text! : nil
        
        PYLAPIHandler.handler.inviteFriend(emailID, mobile: mobile, success:{ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.view.showToastWithMessage(INVITE_SUCCESS)
                success()
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            //            self.view.showToastWithMessage(error.description)
        }
    }
}

extension PYLInvitePopUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.center.y = self.view.center.y - 100
            }, completion: { (completed) in
                
        }) 
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.center.y = self.view.center.y + 100
        }, completion: { (completed) in
            
        }) 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        if(btnMobile.isSelected && (strText.length > MAX_PHONE_NO_LIMIT || !strText.isNumber)) {return false}
        return true
    }

}
