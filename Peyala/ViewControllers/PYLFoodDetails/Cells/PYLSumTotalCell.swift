//
//  PYLSumTotalCell.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLSumTotalCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var textFieldNote: UITextField!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var viewNote: UIView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonAddToCart: UIButton!
    @IBOutlet weak var labelLoyalityValue: UILabel!
    
    @IBOutlet weak var constraintPrevBtnLeading: NSLayoutConstraint!  //(17(iPad),8(iPhone))
    var addTocart:(()->())!
    var previousTappedBlock:(()->())!
    var textFieldEndedEditing:((_ fieldValue:String)->())!
    override var datasource: AnyObject! {
        didSet{
            //       ["note":"","totalPrice":"250"]
            let totalPrice = (datasource as! Dictionary<String,AnyObject>)["totalPrice"] as? String
            labelTotalPrice.text = totalPrice! + " Taka"
            
            let titleAddToCart = (datasource as! Dictionary<String,AnyObject>)["addToCartText"] as! String
            buttonAddToCart.setTitle(titleAddToCart, for: .normal)
//            buttonAddToCart.setTitle("", forState: .Highlighted)
//            buttonAddToCart.setTitle("", forState: .Selected)
            
            
            let noteText = (datasource as! Dictionary<String,AnyObject>)["note"] as! String
            textFieldNote.text = noteText
            
            
            // calculate loyality here
            
            //loyalty part
            let isLoyaltyAvailable = Int(datasource["isLoyaltyAvailable"] as! String)
            if isLoyaltyAvailable != 0 {
                let loyaltyPoints = datasource["loyaltyPoints"] as! String
                let loyaltyCash = datasource["loyaltyCash"] as! String
                labelLoyalityValue.text = "\(loyaltyPoints) Points = \(loyaltyCash) Taka" //i.e.
            }
            
            //edit cart part
            if buttonPrevious != nil {
                buttonPrevious.isHidden = ((datasource as! Dictionary<String,AnyObject>)["isPrevisHidden"] as! String) == "1"
                let staticPrevBtnLeading:CGFloat = IS_IPAD() ? 17.0 : 8.0
                if buttonPrevious.isHidden {
                    constraintPrevBtnLeading.constant = -(self.frame.width - (staticPrevBtnLeading * 2))
                }
                else {
                    constraintPrevBtnLeading.constant =  staticPrevBtnLeading
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        viewNote.layer.cornerRadius = 5.0
        viewNote.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        viewNote.layer.borderWidth = 1
    }
    
    //MARK: Actions
    @IBAction func addToCartBtnAction(_ sender: AnyObject) {
        if addTocart != nil{
            addTocart()
        }
    }
    
    @IBAction func previousBtnAction(_ sender: AnyObject) {
        if previousTappedBlock != nil{
            previousTappedBlock()
        }
        
    }
}


extension PYLSumTotalCell: UITextFieldDelegate
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
