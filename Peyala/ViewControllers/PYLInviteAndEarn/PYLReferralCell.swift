//
//  PYLReferralCell.swift
//  Peyala
//
//  Created by Adarsh on 14/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLReferralCell: PYLBaseTableViewCell {

    @IBOutlet weak var lblEmailID: UILabel!
    @IBOutlet weak var lblRegistrationStatus: UILabel!
    @IBOutlet weak var lblReferredOn: UILabel!
    @IBOutlet weak var lblRewardAmount: UILabel!
    @IBOutlet weak var lblRewardCreditedOn: UILabel!
    @IBOutlet weak var lblSeparator: UILabel!
    
    override var datasource: AnyObject! {
        didSet{
            let dictSource = datasource as! [String:String]
            //TODO: decrypt all the dictionary fetched things once you fetch the api data's.
//            lblEmailID.text = String.getSafeString(dictSource["tax_name"]).getAESDecryption()
            
//            lblEmailID.text = "Email ID: " + String.getSafeString(dictSource["email_id"])
//            lblRegistrationStatus.text = "Registered: " + ((String.getSafeString(dictSource["is_registered"]) == "1") ? "Yes" : "No")
//            lblReferredOn.text = "Referred On: " + String.getSafeString(dictSource["referred_date"])
//            lblRewardAmount.text = "Reward Amount: " + String.getSafeString(dictSource["reward_amount"]) + " Taka"
//            lblRewardCreditedOn.text = "Reward Credited On: " + String.getSafeString(dictSource["reward_credited_date"])
            
            let fontSizeLbl = IS_IPAD() ? 19.0 : 14.0
            lblEmailID.attributedText = String.getAttributedString("Email ID: ", descriptionText: String.getSafeString(dictSource["email_id"] as AnyObject?), size: CGFloat(fontSizeLbl), titleColor: UIColor.black, descriptionColor: UIColor.darkGray)
            lblRegistrationStatus.attributedText = String.getAttributedString("Registered: ", descriptionText: ((String.getSafeString(dictSource["is_registered"] as AnyObject?) == "1") ? "Yes" : "No"), size: CGFloat(fontSizeLbl), titleColor: UIColor.black, descriptionColor: UIColor.darkGray)
            lblReferredOn.attributedText = String.getAttributedString("Referred On: ", descriptionText: String.getSafeString(dictSource["referred_date"] as AnyObject?), size: CGFloat(fontSizeLbl), titleColor: UIColor.black, descriptionColor: UIColor.darkGray)
            lblRewardCreditedOn.attributedText = String.getAttributedString("Reward Credited On: ", descriptionText: String.getSafeString(dictSource["reward_credited_date"] as AnyObject?), size: CGFloat(fontSizeLbl), titleColor: UIColor.black, descriptionColor: UIColor.darkGray)
            lblRewardAmount.text = "Reward Amount: " + String.getSafeString(dictSource["reward_amount"] as AnyObject?) + " Taka"
        }
    }
}
