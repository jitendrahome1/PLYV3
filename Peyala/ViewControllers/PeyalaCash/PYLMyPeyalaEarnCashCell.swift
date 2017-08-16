//
//  PYLMyPeyalaEarnCashCell.swift
//  Peyala
//
//  Created by Jitendra on 7/25/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

import UIKit

class PYLMyPeyalaEarnCashCell: PYLBaseTableViewCell {

    @IBOutlet weak var lblTitleCash: UILabel!
    @IBOutlet weak var lblTakaAmount: UILabel!
    @IBOutlet weak var lblPurchase: UILabel!
    @IBOutlet weak var lblPeyalaCash: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    @IBOutlet weak var lblCashAmount: UILabel!
    @IBOutlet weak var lblPointBalAmount: UILabel!
    @IBOutlet weak var labelPeyalaCashValueAsPerPoint: UILabel!
    
    override func awakeFromNib() {
        self.lblEarn.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * Double.pi / 180.0))
        self.lblCashAmount.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * Double.pi / 180.0))
        self.lblPeyalaCash.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * Double.pi / 180.0))
        self.lblPurchase.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * Double.pi / 180.0))
        self.lblPointBalAmount.transform = CGAffineTransform(rotationAngle: CGFloat(-5 * Double.pi / 180.0))
//        self.lblTakaAmount.transform = CGAffineTransform(rotationAngle: CGFloat(3 * Double.pi / 180.0))
    }
    override var datasource: AnyObject! {
        didSet{
    
        }
    

    }

}
