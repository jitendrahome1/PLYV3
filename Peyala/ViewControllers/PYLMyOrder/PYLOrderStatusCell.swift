//
//  PYLOrderStatusCell.swift
//  Peyala
//
//  Created by Pradip Paul on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLOrderStatusCell: PYLBaseTableViewCell {
    
    //MARK:- Outlet Connections
    @IBOutlet weak var labelOrderStatus: UILabel!
    @IBOutlet weak var labelImageTail: UILabel!
    @IBOutlet weak var imageOrderStatus: UIImageView!
    
    var dataSource: AnyObject!
    
    override var datasource: AnyObject!{
        didSet{
            self.dataSource = datasource
            labelOrderStatus.text = self.dataSource["OrderStatusText"] as? String
            if ((self.dataSource["OrderStatus"] as? Bool) == true) {
                labelOrderStatus.font = UIFont(name: FONT_BOLD, size: 15) // font is not reflecting here
                labelImageTail.backgroundColor = UIColorRGB(79, g: 172, b: 75)
                imageOrderStatus.image = UIImage(named:(datasource["StatusImageSelected"] as? String)!)
            }
            else {
                labelOrderStatus.font = UIFont.systemFont(ofSize: 15)
                labelImageTail.backgroundColor = UIColor.lightGray
                imageOrderStatus.image = UIImage(named:(datasource["StatusImage"] as? String)!)
            }
        }
    }
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
        imageOrderStatus.layer.cornerRadius = imageOrderStatus.frame.width/2.0
        imageOrderStatus.layer.masksToBounds = true
        
    }
}
