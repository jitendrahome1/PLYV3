//
//  PYLCouponInfoCell.swift
//  Peyala
//
//  Created by Adarsh on 30/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLCouponInfoCell: PYLBaseTableViewCell {

    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var imgViewPic: UIImageView!
    @IBOutlet weak var btnItemName: UIButton!
    @IBOutlet weak var btnViewMore: UIButton!
    @IBOutlet weak var btnOfferValid: UIButton!
    @IBOutlet weak var lblCode: UILabel!
    
    override var datasource: AnyObject! {
        didSet{
            viewHolder.layer.borderColor = UIColor.gray.cgColor
            self.backgroundColor = UIColor.clear
            
            //            ["title":"Smoked Turkey","coupon_code":"12223YQRT","offer_valid":"5th May, 2017","image":"ServiceOptionBanner"]
            imgViewPic.image = UIImage(named: datasource["image"] as! String)
            btnItemName.setTitle(datasource["title"] as? String, for: UIControlState.normal)
            let txtOfferValid = "Offer valid till " + "\(datasource["offer_valid"] as! String)"
            btnOfferValid.setTitle(txtOfferValid, for: UIControlState.normal)
            lblCode.text = datasource["coupon_code"] as? String
        }
    }
    
    //MARK: - Actions
    @IBAction func viewMoreBtnAction(_ sender: UIButton) {
    }
}
