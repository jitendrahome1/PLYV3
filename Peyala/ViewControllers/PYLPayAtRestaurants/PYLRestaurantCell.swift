//
//  PYLRestaurantCell.swift
//  Peyala
//
//  Created by Adarsh on 27/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLRestaurantCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var lblRestaurantName: UILabel!
    @IBOutlet weak var lblRestaurantID: UILabel!
    @IBOutlet weak var lblMerchantID: UILabel!
    @IBOutlet weak var lblRestaurantAddress: UILabel!
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var labelSeparator: UILabel!
    
    override var datasource: AnyObject! {
        didSet{
            let dictSource = datasource as! [String:String]
            //TODO: decrypt all the dictionary fetched things once you fetch the api data's.
            //            lblEmailID.text = String.getSafeString(dictSource["tax_name"]).getAESDecryption()
            
            //["rest_name":"Peter Cat","rest_id":"111222","merchant_id":"999827","address":"243 C, Southcity Mall, Kolkata - 700541"]
            lblRestaurantName.text = "Restaurant Name: " + String.getSafeString(dictSource["rest_name"] as AnyObject?)
            lblRestaurantID.text = "Restaurant ID: " + String.getSafeString(dictSource["rest_id"] as AnyObject?)
            lblMerchantID.text = "Merchant ID: " + String.getSafeString(dictSource["merchant_id"] as AnyObject?)
            lblRestaurantAddress.text = "Address: " + String.getSafeString(dictSource["address"] as AnyObject?)
            
            if let imageName = dictSource["imageName"] {
                imgViewIcon.image = UIImage(named: imageName)
            }
        }
    }
}
