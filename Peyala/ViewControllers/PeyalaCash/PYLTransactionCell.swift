//
//  PYLTransactionCell.swift
//  Peyala
//
//  Created by Adarsh on 20/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLTransactionCell: PYLBaseTableViewCell {
    @IBOutlet weak var lblTransactionID: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTransactionType: UILabel!
    @IBOutlet weak var lblDebit: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var labelSeparator: UILabel!
    @IBOutlet weak var constraintCreditTop: NSLayoutConstraint!
    
    override var datasource: AnyObject! {
        didSet{
            let dictSource = datasource as! [String:String]
            //TODO: decrypt all the dictionary fetched things once you fetch the api data's.
            //            lblEmailID.text = String.getSafeString(dictSource["tax_name"]).getAESDecryption()
            
            //transactionId or orderId decision
            if let transactionID = dictSource["transaction_id"] {
                lblTransactionID.text = "Transaction ID: " + transactionID
            }
            else if let orderID = dictSource["order_id"] {
                lblTransactionID.text = "Order ID: " + orderID
            }
            
            lblDate.text = "Date: " + String.getSafeString(dictSource["date"] as AnyObject?)
            lblTransactionType.text = "Type: " + String.getSafeString(dictSource["type"] as AnyObject?)
            
            if let imageName = dictSource["imageName"] {
                imgViewIcon.image = UIImage(named: imageName)
            }
            
            //show/hide debit decision
            if let debit = dictSource["debit"] {
                lblDebit.text = "Debit: " + debit
                lblDebit.isHidden = false
                constraintCreditTop.constant = lblDebit.frame.height
            }
            else {
                lblDebit.isHidden = true
                constraintCreditTop.constant = 0
            }
            
            //show/hide credit decision
            if let credit = dictSource["credit"] {
                lblCredit.text = "Credit: " + credit
                lblCredit.isHidden = false
            }
            else {
                lblCredit.isHidden = true
            }
        }
    }
}
