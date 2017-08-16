//
//  PYLPaymentRoundOffCell.swift
//  Peyala
//
//  Created by Jitendra on 7/27/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

import UIKit

class PYLPaymentRoundOffCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var lblBillAmount: UILabel!
    @IBOutlet weak var lblPlybleAmount: UILabel!
    @IBOutlet weak var lblRoundOff: UILabel!
    var roundValue: Double?
    var amountPayable : String?
    
    override var datasource: AnyObject! {
        didSet{
            if self.datasource != nil{
                let orginalValue = (datasource["total_price"] as! String).getAESDecryption()
                let decimalPart = orginalValue.components(separatedBy: ".")[1]
                
                let index = decimalPart.index (decimalPart.startIndex, offsetBy: 0)
                let signleDecimalValue = Int(String(decimalPart[index]))
                if signleDecimalValue  == 0 {
                    
                    lblRoundOff.text = ""
                    lblBillAmount.text = ""
                    lblRoundOff.isHidden = true
                    self.lblPlybleAmount?.text = "Amount Payable: " +  "\(orginalValue)" + " Taka"
                }
                else if signleDecimalValue! >= 5{
                    
                    
                    let cellValue =    ceil(Double(orginalValue)!)
                    roundValue =  cellValue - Double(orginalValue)!
                    lblBillAmount.text = "Total Bill: " + " \(orginalValue)" + " Taka"
                   self.lblRoundOff.text = "Round Off: +\(String(format: "%.2f", roundValue!))"
                   
                    self.amountPayable = String(Double(orginalValue)! + roundValue!)
                    let amountPayable = (self.amountPayable?.toDouble()!)!
                    self.lblPlybleAmount?.text = "Amount Payable: " +  "\(amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                    
                }
                else {
                    
                    
                    let floorValue =    floor(Double(orginalValue)!)
                    roundValue = Double(orginalValue)! -  floorValue
                    lblBillAmount.text = "Total Bill: " + " \(orginalValue)" + " Taka"
                    self.lblRoundOff.text = "Round Off: -\(String(format: "%.2f", roundValue!))"
                    self.amountPayable = String(Double(orginalValue)! - roundValue!)
                  
                    let amountPayable = (self.amountPayable?.toDouble()!)!
                    
                    self.lblPlybleAmount?.text = "Amount Payable: " +  "\(amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                    
                    
                }
            }
        }
    }
}
