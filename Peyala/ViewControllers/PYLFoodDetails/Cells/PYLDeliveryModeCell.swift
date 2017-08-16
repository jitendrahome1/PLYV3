//
//  PYLDeliveryModeCell.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLDeliveryModeCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var viewDeliveryType1: UIView!
    @IBOutlet weak var viewDeliveryType2: UIView!
    @IBOutlet weak var labelDeliveryType1: UILabel!
    @IBOutlet weak var labelDeliveryType2: UILabel!
    @IBOutlet weak var buttonDineIn: UIButton!
    @IBOutlet weak var buttonTakeAway: UIButton!
    @IBOutlet weak var buttonDelivery: UIButton!
    
    override var datasource: AnyObject! {
        didSet{
            debugPrint(datasource)
            let deliveryMode:[AnyObject] = datasource["deliveryMode"] as! [AnyObject]
            for index in 0..<deliveryMode.count{
                let dict = deliveryMode[index]
                if (dict["deliveryType"] as! String) == "Dine in" {
                    if (dict["deliveryStatus"] as! String) == "0" {
                        buttonDineIn.isSelected = false
                    }else{
                        buttonDineIn.isSelected = true
                    }
                }
                if (dict["deliveryType"] as! String) == "Take Away" {
                    if (dict["deliveryStatus"] as! String) == "0" {
                        buttonTakeAway.isSelected = false
                    }else{
                        buttonTakeAway.isSelected = true
                    }
                }
                if (dict["deliveryType"] as! String) == "Delivery" {
                    if (dict["deliveryStatus"] as! String) == "0" {
                        buttonDelivery.isSelected = false
                    }else{
                        buttonDelivery.isSelected = true
                    }
                }
            }
        }
    }
    
    @IBAction func checkboxOneBtnAction(_ sender: UIButton) {
        //        sender.selected = !sender.selected
    }
    
    @IBAction func checkboxTwoBtnAction(_ sender: UIButton) {
        //        sender.selected = !sender.selected
    }
    
    @IBAction func checkboxThreeBtnAction(_ sender: UIButton) {
        //        sender.selected = !sender.selected
    }
}
