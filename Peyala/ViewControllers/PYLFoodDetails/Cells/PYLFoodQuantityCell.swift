//
//  PYLFoodQuantityCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let MAX_QTY = 99
let MIN_QTY = 1

class PYLFoodQuantityCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelAttribute: UILabel!
    @IBOutlet weak var textFieldCount: UITextField!
    @IBOutlet weak var viewTextField: UIView!
    var quantityUpdateBlock:((_ quantity: Int)->())!
    override var datasource: AnyObject! {
        didSet{
            let foodCategory = (datasource as! Dictionary<String,AnyObject>)["foodCategoryName"] as! String
            labelAttribute.text = "Number of \(foodCategory)"
            textFieldCount.text = (datasource as! Dictionary<String,AnyObject>)["quantity"] as? String
            //            textFieldCount.userInteractionEnabled = false
        }
    }
    
    override func draw(_ rect: CGRect) {
        if viewTextField != nil {
            viewTextField.layer.cornerRadius = 5.0
            viewTextField.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            viewTextField.layer.borderWidth = 1
        }
    }
    
    @IBAction func minusButtonAction(_ sender: AnyObject) {
        guard !(textFieldCount.text!.isBlank) else { return }
        
        var count = Int(textFieldCount.text!)
//        count = (count! > 1) ? count! - 1 : 1  //quantity cannot be '0' in this case.
        count = (count! > MIN_QTY) ? count! - 1 : MIN_QTY
        if quantityUpdateBlock != nil {
            quantityUpdateBlock(count!)
        }
        textFieldCount.text = "\(count!)"
    }
    
    @IBAction func plusButtonAction(_ sender: AnyObject) {
        guard !(textFieldCount.text!.isBlank) else { return }
        
        var count = Int(textFieldCount.text!)
//        count = count! + 1
        count = (count! < MAX_QTY) ? count! + 1 : MAX_QTY
        if quantityUpdateBlock != nil {
            quantityUpdateBlock(count!)
        }
        textFieldCount.text = "\(count!)"
    }
}

extension PYLFoodQuantityCell:  UITextFieldDelegate {
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
        
        if quantityUpdateBlock != nil {
            let count = searchText.isBlank ? 1 : Int(searchText)
            quantityUpdateBlock(count!)
        }
        
        return true
    }
}
