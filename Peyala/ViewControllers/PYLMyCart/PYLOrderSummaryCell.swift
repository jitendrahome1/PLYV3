//
//  PYLOrderSummaryCell.swift
//  Peyala
//
//  Created by Adarsh on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLOrderSummaryCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var labelTax: UILabel!
    @IBOutlet weak var labelGrandTotal: UILabel!
    @IBOutlet weak var buttonPlaceHolder: UIButton!
    @IBOutlet weak var labelPeyalaCash: UILabel!
    @IBOutlet weak var labelTaxAttribute: UILabel!
    
    var placeOrderCompletion : (()->())!
    var clearCartCompletion : (()->())!
    
    override var datasource: AnyObject! {
        didSet{
            //            ["totalPrice":"4500","tax":"100","grandTotal":"4600","checked":"0","cellId":String(PYLOrderSummaryCell)]
            let totalPrice = Double(((datasource as! Dictionary<String,AnyObject>)["totalPrice"] as? String)!)
//            labelTotalPrice.text = "\(totalPrice!) Taka"
            labelTotalPrice.text = "\("\(totalPrice!)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka"
            let taxValue = Double(((datasource as! Dictionary<String,AnyObject>)["taxValue"] as? String)!)
//            labelTaxAttribute.text = "VAT : (\(taxValue!))%"
            labelTaxAttribute.text = "VAT : (\("\(taxValue!)".toDoubleWithRoundOfUpToTwoDecimal()!)%)"
            let taxableAmount = Double(((datasource as! Dictionary<String,AnyObject>)["taxableAmount"] as? String)!)
//            labelTax.text = "\(taxableAmount!) Taka"
            labelTax.text = "\("\(taxableAmount!)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka"
            let grandTotal = Double(((datasource as! Dictionary<String,AnyObject>)["grandTotal"] as? String)!)
//            labelGrandTotal.text = "\(grandTotal!) Taka"
            labelGrandTotal.text = "\("\(grandTotal!)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka"
            let myPeyalaCash = Double(((datasource as! Dictionary<String,AnyObject>)["myPeyalaCash"] as? String)!)
//            labelPeyalaCash.text = "\(myPeyalaCash!) Taka"
            labelPeyalaCash.text = "\("\(myPeyalaCash!)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka"
        }
    }
    
    @IBAction func placeOrderBtnAction(_ sender: AnyObject) {
        if placeOrderCompletion != nil{
            placeOrderCompletion()
        }
    }
    @IBAction func clearCartBtnAction(_ sender: AnyObject) {
        if clearCartCompletion != nil{
            clearCartCompletion()
        }
    }
}
