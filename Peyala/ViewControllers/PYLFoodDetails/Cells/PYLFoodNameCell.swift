//
//  PYLFoodNameCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLFoodNameCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var imageViewNew: UIImageView!
    @IBOutlet weak var labelFoodName: UILabel!
    
    @IBOutlet weak var newImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLeadingConstraint: NSLayoutConstraint!
    
    override var datasource: AnyObject! {
        didSet{
            if imageViewNew != nil {
                imageViewNew.isHidden = (((datasource as! Dictionary<String,AnyObject>)["isNew"] as? String) == "0") ? true : false
                if imageViewNew.isHidden {
                    //                    nameLeadingConstraint.constant = IS_IPAD() ? 95 : 62 - newImageWidthConstraint.constant
                    nameLeadingConstraint.constant = imageViewNew.frame.origin.x
                }
            }
            if labelFoodName != nil {
                labelFoodName.text = (datasource as! Dictionary<String,AnyObject>)["foodName"] as? String
            }
        }
    }
}
