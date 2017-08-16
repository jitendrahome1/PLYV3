//
//  PYLCreateGiftVoucher.swift
//  Peyala
//
//  Created by Adarsh on 23/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

import ContactsUI

class PYLCreateGiftVoucherViewController: PYLBaseTableViewController, CNContactPickerDelegate {
    
    @IBOutlet weak var btnPhonebook: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtFieldMobileNo: UITextField!
    @IBOutlet weak var txtFieldDescription: UITextField!
    @IBOutlet weak var txtFieldAmount: UITextField!
    
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    func setUpperNavigationItems() {
        self.title = "Create Gift Voucher"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
    }
    
    func setupUI() {
        txtFieldMobileNo.showToolBar()
        txtFieldAmount.showToolBar()
    }
    
    func validateFields() -> Bool {
        var validate = true
        if txtFieldMobileNo.text!.isBlank  {
            validate = false
            self.view.showToastWithMessage("Mobile number"+LEFT_BLANK)
        }
        else if txtFieldAmount.text!.isBlank  {
            validate = false
            self.view.showToastWithMessage("Amount"+LEFT_BLANK)
        }
        
        return validate
    }
    
    //MARK: - Actions
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
        txtFieldMobileNo.text = (contact.phoneNumbers.first!.value ).value(forKey: "digits") as? String
    }
    
    @IBAction func submitBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if validateFields() {
            //submit task
            let userPylCashBalance = PYLHelper.helper.userModelObj!.loyaltycash.toDouble()
            let requiredCash = txtFieldAmount.text!.toDouble()
            if userPylCashBalance! < requiredCash! {
                self.present(UIAlertController.showStandardAlertWith(kAppDetailedTitle, alertText: LOW_CASH, cancelTitle: OK, doneTitle: CANCEL, selected_: { (index) in
                    
                    if index == 0 {
                        
                        let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLAddPeyalaCashViewController.self)) as! PYLAddPeyalaCashViewController
                        self.removeViewControllerFromNavigationStack(String(describing: viewController))
                        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
                    } else {
                        // stay on this page
                    }
                }), animated: true, completion: nil)
            }
            else {
                self.view.showToastWithMessage("Successful !!")
            }
        }
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = IS_IPAD() ? 80 : 65
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension PYLCreateGiftVoucherViewController: UITextFieldDelegate {
    
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
        if((txtFieldMobileNo.isFirstResponder||txtFieldAmount.isFirstResponder) && (strText.length > MAX_PHONE_NO_LIMIT || !strText.isNumber)) {return false}
        return true
    }
    
}
