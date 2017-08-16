//
//  PYLAddressCell.swift
//  Peyala
//
//  Created by Adarsh on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLAddressCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var viewLineGray: UIView!
    @IBOutlet weak var labelAttribute: UILabel!
    @IBOutlet weak var textFieldValue: UITextField!
    @IBOutlet weak var textViewValue: UITextView!
    @IBOutlet weak var constraintCurveViewTxtFldBottom: NSLayoutConstraint!
    
    var isAddress = false
    var isNumber = false
    var attributeType = -1
    var textFieldEndedEditing:((_ fieldValue:String)->())!
    var textFieldBeginEditing:((_ fieldValue:String, _ attributeTypeValue: Int)->())!
    var textViewEndedEditing:((_ fieldValue:String)->())!
    
    override var datasource: AnyObject! {
        didSet{
            attributeType =   (((datasource as! Dictionary<String,AnyObject>)["attributeType"] as? NSNumber)?.intValue)!
            isAddress = ((datasource as! Dictionary<String,AnyObject>)["isAddress"] as? String) == "1"
            labelAttribute.text = (datasource as! Dictionary<String,AnyObject>)["attribute"] as? String
            let isEnabled: Bool = ((datasource as! Dictionary<String,AnyObject>)["isEnabled"] as? String) == "1"
            isNumber = (((datasource as! Dictionary<String,AnyObject>)["isNumber"] as? String) == nil) ? false : true
            let value = (datasource as! Dictionary<String,AnyObject>)["value"] as? String
            if isAddress {
                //settings
                textViewValue.layer.cornerRadius = 5.0
                textViewValue.layer.borderWidth = 1.0
                textViewValue.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                textViewValue.textContainerInset.left = 8
                textViewValue.isUserInteractionEnabled = isEnabled
                textViewValue.backgroundColor = isEnabled ? UIColor.groupTableViewBackground : UIColor.clear
                
                textViewValue.text = value
            }
            else {
                //settings
                textFieldValue.leftView = UIView(frame: CGRect(x : 0,y: 0,width: 8,height: 0))
                textFieldValue.leftViewMode = .always
                textFieldValue.layer.cornerRadius = 5.0
                textFieldValue.layer.borderWidth = 1.0
                textFieldValue.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                textFieldValue.isUserInteractionEnabled = isEnabled
                textFieldValue.backgroundColor = isEnabled ? UIColor.groupTableViewBackground : UIColor.clear
                textFieldValue.keyboardType = isNumber ? .phonePad : .default
                isNumber ? textFieldValue.showToolBar() : textFieldValue.hideToolBar()
                textFieldValue.text = value
            }
        }
    }
}

extension PYLAddressCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if attributeType == PYLMyProfileViewController.attributeType.kDob.rawValue {
            (appdelegate().window?.rootViewController)!.view.endEditing(true)
            textField.resignFirstResponder()
            
            PYLPickerViewController.showPickerController((appdelegate().window?.rootViewController)!, isDatePicker: true, pickerArray: [], position: .bottom, pickerTitle: "", preSelected: "", selected: { (value, index) in
                
                if value != nil {
                    guard (value as! String).length > 0 else { return }
                    textField.text = value as? String
                    if self.textFieldBeginEditing != nil {
                        self.textFieldBeginEditing(String.getSafeString(value),self.attributeType)
                    }
                }
            })
            return false
            
        } else if attributeType == PYLMyProfileViewController.attributeType.kGender.rawValue {
            
            (appdelegate().window?.rootViewController)!.view.endEditing(true)
            let genderVal = (datasource as! Dictionary<String,AnyObject>)["value"] as! String
            PYLPickerViewController.showPickerController((appdelegate().window?.rootViewController)!, isDatePicker: false, pickerArray: ["Male","Female"], position: .bottom, pickerTitle: "", preSelected: genderVal, selected: { (value, index) in
                
                guard (value as! String).length > 0 else { return }
                textField.text = value as? String
                if self.textFieldBeginEditing != nil {
                    self.textFieldBeginEditing(String.getSafeString(value),self.attributeType)
                }
            })
            return false
        }
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textFieldEndedEditing != nil {
            textFieldEndedEditing(textField.text!)
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
        
        if(isNumber && !strText.isNumber) {return false}
        if(isNumber && strText.length > MAX_PHONE_NO_LIMIT) {return false} //though it will apply to Postal-code also alongwith phone.
        
        if textFieldEndedEditing != nil {
            textFieldEndedEditing(strText)
        }
        
        return true
    }
}

extension PYLAddressCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewEndedEditing != nil {
            textViewEndedEditing(textView.text!)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !text.containsEmoji() else { return false }
        var strText = String()
        if (range.length == 0){
            let stringNew = NSMutableString(string: textView.text!)
            stringNew.insert(text, at: range.location)
            strText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textView.text!)
            stringNew.deleteCharacters(in: range)
            strText = stringNew as String
        }
        
        if textViewEndedEditing != nil {
            textViewEndedEditing(strText)
        }
        return true
    }
}


