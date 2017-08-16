//
//  PYLFoodDescriptionCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLFoodDescriptionCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var labelDescription: UILabel!
    override var datasource: AnyObject! {
        didSet{
            labelDescription.text = (datasource as! Dictionary<String,AnyObject>)["foodDesc"] as? String
        }
    }
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
}
