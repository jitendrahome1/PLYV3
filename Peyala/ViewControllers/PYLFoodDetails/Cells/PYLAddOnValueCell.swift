//
//  PYLAddOnValueCell.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLAddOnValueCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var textFieldCount: UITextField!
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var constraintCurveViewBottom: NSLayoutConstraint!
    
    var addOnQuantityUpdateBlock:((_ quantity: Int)->())!
    var checkBoxTapped:((_ isChecked: Bool)->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["addOnName":"Add-On 1","addOnPrice":"50","addOnQuantity":"1","checked":"0"]
            labelName.text = (datasource as! Dictionary<String,AnyObject>)["addon_name"] as? String
            let price = ((datasource as! Dictionary<String,AnyObject>)["addon_price"] as? String )
            labelPrice.text = price! + " Taka"
            textFieldCount.text = (datasource as! Dictionary<String,AnyObject>)["addOnQuantity"] as? String
            //            textFieldCount.userInteractionEnabled = false
            buttonCheckbox.isSelected = ((datasource as! Dictionary<String,AnyObject>)["checked"] as? String) == "1" ? true : false
            buttonPlus.isUserInteractionEnabled = buttonCheckbox.isSelected
            buttonMinus.isUserInteractionEnabled = buttonCheckbox.isSelected
            textFieldCount.isUserInteractionEnabled = buttonCheckbox.isSelected
        }
    }
    
    override func draw(_ rect: CGRect) {
        viewTextField.layer.cornerRadius = 5.0
        viewTextField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        viewTextField.layer.borderWidth = 1
        
        //        buttonCheckbox.layer.borderColor = UIColor.grayColor().CGColor
        //        buttonCheckbox.layer.borderWidth = 1
    }
    
    //MARK: Actions
    @IBAction func minusButtonAction(_ sender: AnyObject) {
        guard !(textFieldCount.text!.isBlank) else { return }
        
        var count = Int(textFieldCount.text!)
        count = (count! > MIN_QTY) ? count! - 1 : MIN_QTY
        if addOnQuantityUpdateBlock != nil {
            addOnQuantityUpdateBlock(count!)
        }
        textFieldCount.text = "\(count!)"
    }
    
    @IBAction func plusButtonAction(_ sender: AnyObject) {
        guard !(textFieldCount.text!.isBlank) else { return }
        
        var count = Int(textFieldCount.text!)
        //        count = count! + 1
        count = (count! < MAX_QTY) ? count! + 1 : MAX_QTY
        if addOnQuantityUpdateBlock != nil {
            addOnQuantityUpdateBlock(count!)
        }
        textFieldCount.text = "\(count!)"
    }
    
    @IBAction func buttonCheckboxAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if checkBoxTapped != nil {
            checkBoxTapped(sender.isSelected)
        }
    }
}

extension PYLAddOnValueCell:  UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text!.isBlank || (Int(textField.text!)! == 0) {
            textField.text = "1"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText = ""
        if (range.length == 0){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.insert(string, at: range.location)
            searchText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.deleteCharacters(in: range)
            searchText = stringNew as String
        }
        
        if !searchText.isNumber {return false}
        
        if searchText.length > MAX_QTY.getNumberOfDigits() {
            return false
        }
        
        if addOnQuantityUpdateBlock != nil {
            let count = searchText.isBlank ? 1 : Int(searchText)
            addOnQuantityUpdateBlock(count!)
        }
        
        return true
    }
}
