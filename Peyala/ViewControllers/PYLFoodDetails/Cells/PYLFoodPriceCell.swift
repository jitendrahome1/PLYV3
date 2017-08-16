//
//  PYLFoodPriceCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLFoodPriceCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelAttribute: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    
    override var datasource: AnyObject! {
        didSet{
            labelAttribute.text = (datasource as! Dictionary<String,AnyObject>)["attribute"] as? String
            if  let price = datasource["price"]  as? String {
                labelValue.text = price + " Taka"
            }
        }
    }
    
}
