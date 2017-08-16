//
//  PYLAllergicTextFieldCell.swift
//  Peyala
//
//  Created by Adarsh on 12/10/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLAllergicTextFieldCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var textFieldAllergicNotes: UITextField!
    @IBOutlet weak var viewAllergicNote: UIView!
    
    
    var textFieldEndedEditing:((_ fieldValue:String)->())!
    override var datasource: AnyObject! {
        didSet{
            //       ["note":"","cellId":String(PYLAllergicTextFieldCell)]
            textFieldAllergicNotes.text = (datasource as! Dictionary<String,AnyObject>)["note"] as? String
        }
    }
    
    override func draw(_ rect: CGRect) {
        viewAllergicNote!.layer.cornerRadius = 2.0
        viewAllergicNote!.layer.borderWidth = 1.0
        viewAllergicNote!.layer.borderColor = UIColor.gray.cgColor
    }
}

extension PYLAllergicTextFieldCell: UITextFieldDelegate
{
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
        
        if textFieldEndedEditing != nil {
            textFieldEndedEditing(strText)
        }
        
        return true
    }
}
