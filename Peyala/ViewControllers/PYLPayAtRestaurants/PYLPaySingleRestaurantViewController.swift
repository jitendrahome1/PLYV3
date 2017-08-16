//
//  PYLPaySingleRestaurantViewController.swift
//  Peyala
//
//  Created by Adarsh on 27/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLPaySingleRestaurantViewController: PYLBaseTableViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtFieldRestaurantName: UITextField!
    @IBOutlet weak var txtFieldDescription: UITextField!
    @IBOutlet weak var txtFieldAmount: UITextField!
    
    var selectedRestaurantDict:[String:String]?
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    func setUpperNavigationItems() {
        self.title = "Pay at Restaurants"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
    }
    
    func setupUI() {
        txtFieldAmount.showToolBar()
        txtFieldRestaurantName.text = selectedRestaurantDict!["rest_name"]
    }
    
    func validateFields() -> Bool {
        var validate = true
        if txtFieldAmount.text!.isBlank  {
            validate = false
            self.view.showToastWithMessage("Amount"+LEFT_BLANK)
        }
        
        return validate
    }
    
    //MARK: - Actions
    
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

extension PYLPaySingleRestaurantViewController: UITextFieldDelegate {
    
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
        if(txtFieldAmount.isFirstResponder && (strText.length > MAX_PHONE_NO_LIMIT || !strText.isNumber)) {return false}
        return true
    }
    
}
