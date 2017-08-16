//
//  PYLDeliveryEnterTextCell.swift
//  Peyala
//
//  Created by Adarsh on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let MAX_PHONE_NO_LIMIT = 15

class PYLDeliveryEnterTextCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelAttribute: UILabel!
    @IBOutlet weak var textFieldValue: UITextField!
    @IBOutlet weak var textViewValue: UITextView!
    
    var textFieldEndedEditing:((_ fieldValue:String)->())!
    var textViewEndedEditing:((_ fieldValue:String)->())!
    var isAddress = false
    var isNumber = false
    var isPhone = false
    override var datasource: AnyObject! {
        didSet{
            //            ["attribute":"Enter Address","value":"","isAddress":"1","cellId":"PYLDeliveryEnterTextCellAddress"]
            isAddress = ((datasource as! Dictionary<String,AnyObject>)["isAddress"] as? String) == "1"
            let attributeText = ((datasource as! Dictionary<String,AnyObject>)["attributeText"] as? String)!
            labelAttribute.text = attributeText
            let attribute = ((datasource as! Dictionary<String,AnyObject>)["attribute"] as? String)!
            isNumber = (attribute == "Postal Code") || (attribute == "Phone No.")
            isPhone = (attribute == "Phone No.")
            let value = (datasource as! Dictionary<String,AnyObject>)["value"] as? String
            if isAddress {
                //settings
                textViewValue.layer.cornerRadius = 5.0
                textViewValue.layer.borderWidth = 1.0
                textViewValue.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                textViewValue.textContainerInset.left = 8
                textViewValue.text = value
            }
            else {
                //settings
                textFieldValue.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
                textFieldValue.leftViewMode = .always
                textFieldValue.layer.cornerRadius = 5.0
                textFieldValue.layer.borderWidth = 1.0
                textFieldValue.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                textFieldValue.delegate = self
                textFieldValue.text = value
                textFieldValue.placeholder = "Enter \(attributeText)"
                textFieldValue.keyboardType = isNumber ? .phonePad : .default
                isNumber ? textFieldValue.showToolBar() : textFieldValue.hideToolBar()
            }
            
        }
    }
}

extension PYLDeliveryEnterTextCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textFieldEndedEditing != nil {
            textFieldEndedEditing(textField.text!)
        }
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
        if(isNumber && !strText.isNumber) {return false}
        if(isPhone && strText.length > MAX_PHONE_NO_LIMIT) {return false}
        return true
    }
}

extension PYLDeliveryEnterTextCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewEndedEditing != nil {
            textViewEndedEditing(textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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


