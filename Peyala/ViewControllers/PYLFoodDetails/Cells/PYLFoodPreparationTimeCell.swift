//
//  PYLFoodPreparationTimeCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLFoodPreparationTimeCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelAttribute: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelMIN: UILabel!
    @IBOutlet weak var imageViewCircleOrange: UIImageView!
    @IBOutlet weak var imageViewCircleGreen: UIImageView!
    
    override var datasource: AnyObject! {
        didSet{
            labelAttribute.text = (datasource as! Dictionary<String,AnyObject>)["attribute"] as? String
            if let preparationTime = (datasource as! Dictionary<String,AnyObject>)["preparationTime"] as? String {
                labelTime.text = preparationTime
                imageViewCircleOrange.isHidden = false
                imageViewCircleGreen.isHidden = true
            }
            else {
                labelTime.text = (datasource as! Dictionary<String,AnyObject>)["deliveryTime"] as? String
                imageViewCircleOrange.isHidden = true
                imageViewCircleGreen.isHidden = false
            }
        }
    }
}
