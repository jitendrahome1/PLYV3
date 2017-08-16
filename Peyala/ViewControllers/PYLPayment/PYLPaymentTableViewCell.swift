//
//  PYLPaymentTableViewCell.swift
//  Peyala
//
//  Created by sweta on 27/10/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PYLPaymentTableViewCell: PYLBaseTableViewCell , UITextFieldDelegate {
    
    @IBOutlet weak var constDeliverChargeLbl: NSLayoutConstraint!
    //jitu @IBOutlet weak var paymentLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentCashLabel: UILabel!
    @IBOutlet weak var payableAmountLabel: UILabel!
    @IBOutlet weak var radeemAmount: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var orderIdLabel: UILabel!
    var roundValue: Double?
    var finalPayableAmount = 0.0
    
    @IBOutlet weak var nsConstRoundOff: NSLayoutConstraint!
    
    @IBOutlet weak var deliveryChargeLabel: UILabel! //change
       //jitu@IBOutlet weak var secondHeightConstraint: NSLayoutConstraint!
       //jitu@IBOutlet weak var thirdHeightConstraint: NSLayoutConstraint!
       //jitu@IBOutlet weak var upperTopConstraint: NSLayoutConstraint!
       //jitu@IBOutlet weak var lowerTopConstraint: NSLayoutConstraint!
 @IBOutlet weak var constraintDescriptionTxtFieldTop: NSLayoutConstraint!
   
    @IBOutlet weak var lblRoundOffValue: UILabel!
      //jitu @IBOutlet var constraintUsedPointHeight: NSLayoutConstraint!
      //jitu @IBOutlet var constraintReceivedPointsHeight: NSLayoutConstraint!
    @IBOutlet var textfieldPeyalaCashSelected: UITextField!
    @IBOutlet var labelPeyalaCashAvailable: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var labelSeperator: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet var labelUsedPoints: UILabel!
    @IBOutlet var labelReceivedPoints: UILabel!
    @IBOutlet var labelAvailablePoints: UILabel!
    var peyalaCashSelected : ((_ amount:String)->())!
    var selectedAmout:String!
    var isDeliveryType:Bool = false //change
    var userDetails:[String:AnyObject]!
    var selectedpaymentOption : paymentOption = .NotSelected
    
    override var datasource: AnyObject! {
        didSet{
            roundValue = 0.0
            
            userDetails = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY) as? [String:AnyObject]
            let peyalaAvailableCash = (userDetails!["loyaltycash"] as! String).length > 0 ? (userDetails!["loyaltycash"] as! String).toDouble()!:0
            let str = NSAttributedString(string: "I want to use my Peyala Cash", attributes: [NSForegroundColorAttributeName:UIColor.darkGray])
            amountLabel?.text = "Total Bill : \((datasource["total_price"] as! String).getAESDecryption()) Taka" //change
            finalPayableAmount = (datasource["total_price"] as! String).getAESDecryption().toDouble()!
            let orginalValue = (datasource["total_price"] as! String).getAESDecryption()
            let decimalPart = orginalValue.components(separatedBy: ".")[1]
            let index = decimalPart.index (decimalPart.startIndex, offsetBy: 0)
            let signleDecimalValue = Int(String(decimalPart[index]))
            
            if signleDecimalValue  == 0 {
            self.lblRoundOffValue?.text = "Round Off Amount: 0.0"
            }
            
            else if signleDecimalValue! >= 5{
                let cellValue =    ceil(Double(orginalValue)!)
                roundValue =  cellValue - Double(orginalValue)!
                self.lblRoundOffValue.text = "Round Off Amount: +\(String(format: "%.2f", roundValue!))"
                
                if selectedpaymentOption != .Online {
                    finalPayableAmount = finalPayableAmount + roundValue!
                }
                
            } else  {
                let floorValue =    floor(Double(orginalValue)!)
                roundValue = Double(orginalValue)! -  floorValue
                self.lblRoundOffValue.text = "Round Off Amount: -\(String(format: "%.2f", roundValue!))"
                
                if selectedpaymentOption != .Online {
                    finalPayableAmount = finalPayableAmount - roundValue!
                }
            }
            
            //Price :
            //textfieldPeyalaCashSelected.text = "\(selectedAmout != "0" ? selectedAmout: Int(peyalaAvailableCash))"
            
            if isDeliveryType { //change
                deliveryChargeLabel?.isHidden = false
                   constDeliverChargeLbl.constant = 33.0
                deliveryChargeLabel?.text = "Delivery Charge : 100 Taka"
            }
            else {
                deliveryChargeLabel?.isHidden = true
                    constDeliverChargeLbl.constant = 0
                   //jitu constraintDescriptionTxtFieldTop.constant = 0;
                descriptionTextField.layoutIfNeeded()
            }
            
            if checkboxButton.isSelected == true {
                textfieldPeyalaCashSelected.text = "\(selectedAmout != "0" ? selectedAmout!: "0")"
                textfieldPeyalaCashSelected.isEnabled = true
                textfieldPeyalaCashSelected.backgroundColor = UIColor.white
            }else{
                textfieldPeyalaCashSelected.text = "0"
                textfieldPeyalaCashSelected.isEnabled = false
                textfieldPeyalaCashSelected.backgroundColor = UIColor.lightGray
            }
           
            descriptionTextField.attributedPlaceholder = str
            let availablePeyalaCash = peyalaAvailableCash - (textfieldPeyalaCashSelected.text)!.toDouble()!
            labelPeyalaCashAvailable.text = "My Peyala Cash Balance : \(availablePeyalaCash) Taka"
            checkboxButton.imageView?.tag = 0
            checkboxButton.addTarget(self, action: #selector(oncheckOutBtnAction(_:)), for: .touchUpInside)
            descriptionView.layer.cornerRadius = 4
            descriptionView.layer.masksToBounds = true
            descriptionView.layer.borderColor = UIColor.lightGray.cgColor
            descriptionView.layer.borderWidth = 0.5
            descriptionTextField.isEnabled = false
            descriptionTextField.isUserInteractionEnabled = false
            if ((Double(peyalaAvailableCash) == 0) && !isDeliveryType) {  //change
                self.contentView.alpha = 0.0
                self.isUserInteractionEnabled = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if checkboxButton.isSelected == true {
            textField.text = textField.text?.toInt() == 0 ? "" : textField.text
        }else{
           textField.text = "0"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if checkboxButton.isSelected == true {
            if peyalaCashSelected != nil {
                peyalaCashSelected(textField.text!)
            }
        }else{
            if peyalaCashSelected != nil {
                peyalaCashSelected("0")
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditing(true)
        if checkboxButton.isSelected == true {
            if peyalaCashSelected != nil {
                textField.text = textField.text!.isEmpty ? "0" :  textField.text! 
                peyalaCashSelected(textField.text!.isNumber ? textField.text! : "0" )
              
            }
        }else{
            if peyalaCashSelected != nil {
                peyalaCashSelected("0")
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        //prospectiveText.toDouble()! <= min((userDetails!["loyaltycash"] as! String).toDouble()!, ((datasource["total_price"] as! String).getAESDecryption()).toDouble()!)
        return prospectiveText.isNumber && prospectiveText.toDouble()! <= min((userDetails!["loyaltycash"] as! String).toDouble()!, finalPayableAmount)
        
    }
    func oncheckOutBtnAction(_ sender: UIButton!)
    {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected == false {
            sender.setBackgroundImage(UIImage(named: "AddOnCheckBoxDeselect"), for: UIControlState())
            textfieldPeyalaCashSelected.isEnabled = false
            textfieldPeyalaCashSelected.backgroundColor = UIColor.lightGray
            var userDetails = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY) as? [String:AnyObject]
            _ = (userDetails!["loyaltycash"] as! String).length > 0 ? (userDetails!["loyaltycash"] as! String).toDouble()!:0
            //textfieldPeyalaCashSelected.text = "\(Int(peyalaAvailableCash))"
             textfieldPeyalaCashSelected.text = "0"
            
            if peyalaCashSelected != nil {
                peyalaCashSelected("0")
            }
        }else{
            sender.setBackgroundImage(UIImage(named: "AddOnCheckBoxSelect"), for: UIControlState())
             textfieldPeyalaCashSelected.isEnabled = true
             textfieldPeyalaCashSelected.backgroundColor = UIColor.white
            
            if peyalaCashSelected != nil {
                peyalaCashSelected(textfieldPeyalaCashSelected.text!)
            }
        }
        
    }
   
}

class PeyalaCashDisclaimerTableViewCell: PYLBaseTableViewCell {
}

class PeyalaCashHistoryTableViewCell: PYLBaseTableViewCell {
    @IBOutlet weak var labelOrderId: UILabel!
    @IBOutlet weak var labelCashReceived: UILabel!
    @IBOutlet weak var labelCashUsed: UILabel!
    @IBOutlet weak var labelSeparator: UILabel!
    var viewDetailsButtonBlock : ((_ indexNo:Int)->())!
    @IBOutlet weak var buttonViewDetails: PYLButton!
    
    override var datasource: AnyObject! {
        didSet{
            
            labelOrderId.text = "Order ID: \((datasource["order_id"] as? String)!.getAESDecryption())"
            let usedCash = ((datasource["order_redeem_loyalty_cash"] as? String)!.getAESDecryption().toStringWithRoundOfUpToTwoDecimal())!
            
            let receivedCash = ((datasource["loyalty_cash"] as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
            
            if usedCash.toDouble()! > 0.0 {
                labelCashUsed.text = "PEYALA cash used : " + usedCash + " Taka"
            } else {
                labelCashUsed.text = ""
            }
            if receivedCash.toDouble()! > 0.0 {
                labelCashReceived.text = "PEYALA cash received : " + receivedCash + " Taka"
            } else {
                labelCashReceived.text = ""
            }

        }
    }
    @IBAction func viewOrderDetailsPressed(_ sender: PYLButton) {
        
        if viewDetailsButtonBlock != nil {
            viewDetailsButtonBlock(sender.tag)
        }
    }
}
