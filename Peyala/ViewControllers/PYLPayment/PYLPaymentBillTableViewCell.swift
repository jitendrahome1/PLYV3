//
//  PYLPaymentBillTableViewCell.swift
//  Peyala
//
//  Created by sweta on 09/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLPaymentBillTableViewCell: PYLBaseTableViewCell {

    @IBOutlet weak var btnPaymentType: UIButton!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!

    @IBOutlet weak var btnCheckBox: UIButton!
        override var datasource: AnyObject! {
            didSet{
                if self.datasource != nil{
                 self.lblPaymentType.text = datasource!["Name"] as? String
                    
                    if datasource["Name"] as? String == "Select Payment Option"{
                    self.btnCheckBox.isHidden = true
                    self.btnPaymentType.isHidden = true
                
                    }else{
                        self.btnCheckBox.isHidden = false
                        self.btnPaymentType.isHidden = false
                      self.btnCheckBox.isSelected = (datasource!["buttonStatus"] as? Bool)!
                    }
                    
                  
                }
            }
        }
    

 

}
