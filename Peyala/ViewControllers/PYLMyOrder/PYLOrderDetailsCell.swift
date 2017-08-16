//
//  PYLOrderDetailsCell.swift
//  Peyala
//
//  Created by Pradip Paul on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PYLOrderDetailsCell: PYLBaseTableViewCell {
    //MARK:- Outlet Connections
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var labelOderId: UILabel!
    @IBOutlet weak var labelAddOns: UILabel!
    @IBOutlet weak var labelVariants: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelRightValue: UILabel!
    @IBOutlet weak var labelLeftKey: UILabel!
    @IBOutlet weak var buttonComboDetails: UIButton!
    @IBOutlet var labelPeyalaCashEarned: UILabel!
    @IBOutlet var constraintPeyalaCashViewHeight: NSLayoutConstraint!
    var comboDetails:((_ combo: AnyObject)->())!
    var dataSource = [String:Any]()
    var vatPercentage = ""
    var cardType = ""
    
    override func configureCell() {
        if self.reuseIdentifier == String(describing: PYLOrderDetailsCell.self) {
            constraintPeyalaCashViewHeight.constant = 0
        }
        super.configureCell()
    }
    override var datasource: AnyObject! {
        didSet {
            dataSource = datasource as! [String : Any]
            if self.reuseIdentifier == String(describing: PYLOrderDetailsCell.self) {
                //constraintPeyalaCashViewHeight.constant = 0
                var foodQuantity = 0.0
                if let _ = datasource["combo_id"] as? String{
                    buttonComboDetails.isHidden = false
                    //Image--------------------
                    if let imageUrl = datasource["combo_image_url"] as? String{
                        self.itemImage.af_setImage(withURL: URL(string: imageUrl.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        })
                    }
                    //Combo Price,Name,Quantity ------------------------
                    if let comboPrice = datasource["total_price"] as? String{
                        labelPrice.text = comboPrice.getAESDecryption()
                    }else{
                        labelPrice.text = "N/A"
                    }
                    if let comboName = datasource["combo_name"] as? String{
                        labelOderId.text = comboName.getAESDecryption()
                    }else{
                        labelOderId.text = "N/A"
                    }
                    if let comboQuantity = dataSource["combo_quantity"] as? String{
                        foodQuantity = comboQuantity.getAESDecryption().toDouble()!
                        labelAddOns.text = "Quantity: " + "\(comboQuantity.isEmpty ? "N/A" : comboQuantity.getAESDecryption())"
                    }
                    labelVariants.text = ""
                    
                    //Price and Discount -------------------
                    //Adons -------------------
                    var adonsString = ""
                    var extraAdonsString = ""
                    var i = 0
                    for fooditems in (dataSource["food_items"] as! [[String : AnyObject]]){
                        i = 0
                        for addons in (fooditems["default_addon_details"] as? [[String : AnyObject]])!{
                            i += 1
                            adonsString = adonsString + "\((addons["addon_name"] as! String).getAESDecryption()) \((addons["addon_quantity"] as! String).getAESDecryption())x"
                            if i != (fooditems["default_addon_details"] as? NSArray)!.count {
                                adonsString = adonsString + ", "
                            }
                        }
                    }
                    i = 0
                    var total = (datasource["combo_price"] as! String).getAESDecryption().isEmpty ? 0.0 : (datasource["combo_price"] as! String).getAESDecryption().toFloat()!
                    var adonTotalPrice = 0.00
                    
                    for fooditems in (dataSource["food_items"] as? [[String : AnyObject]])!{
                        i = 0
                        for adons in (fooditems["addon_details"] as? [[String : AnyObject]])!{
                            i += 1
                            extraAdonsString = extraAdonsString + "\((adons["addon_name"] as! String).getAESDecryption()) \((adons["addon_quantity"] as! String).getAESDecryption())x"
                            
                            if i != (fooditems["addon_details"] as? NSArray)!.count {
                                extraAdonsString = extraAdonsString + ", "
                            }
                            adonTotalPrice = adonTotalPrice + ((adons["addon_price"] as! String).getAESDecryption().toDouble()! * (adons["addon_quantity"] as! String).getAESDecryption().toDouble()!)
                        }
                    }
                    
                    let adonsPreparedString = self.attributedStringTitle("Default Add-Ons: ", description: (adonsString.length > 0 ? adonsString : "N/A") , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray)
                    if extraAdonsString.length > 0 {
                        adonsPreparedString.append(self.attributedStringTitle("\nExtra Add-Ons: ", description: extraAdonsString , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray))
                    }
                    labelAddOns.attributedText = adonsPreparedString
                    self.layoutIfNeeded()
                    total = total + Float(adonTotalPrice)
                    let myString = "Price: \(total) Taka X \((datasource["combo_quantity"] as! String).getAESDecryption()) = "
                    labelPrice.attributedText = self.attributedStringTitle(myString, description: ((datasource["combo_price"] ?? "") as! String).isEmpty ? "0.0" :"\(total*(datasource["combo_quantity"] as! String).getAESDecryption().toFloat()!) Taka", size: labelPrice.font.pointSize,titleColor: UIColor.darkGray,descriptionColor: DEFAULT_COLOR)
                
                } else {
                    self.itemImage.image = UIImage(named: "Placeholder")
                    buttonComboDetails.isHidden = true
                    //Food Price,Name,Varient ------------------------
                    if let foodPrice = datasource["food_size_price"] as? String{
                        labelPrice.text = foodPrice.getAESDecryption()
                    }else{
                        labelPrice.text = "N/A"
                    }
                    if let foodName = datasource["food_name"] as? String{
                        labelOderId.text = foodName.getAESDecryption()
                    }else{
                        labelOderId.text = "N/A"
                    }
                    foodQuantity = ((datasource["food_quantity"] as! String).isEmpty ? 0.0 : (datasource["food_quantity"] as! String).getAESDecryption().toDouble())!
                    
                    if let varient = datasource["food_size_name"] as? String{
                        labelVariants.text = "Size : \(varient.isEmpty ? "N/A" : varient.getAESDecryption())"
                    }
                    //Image--------------------
                    if let imageUrl = datasource["food_item_img_url"] as? String{
                        
                        self.itemImage.af_setImage(withURL: URL(string: imageUrl.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                            
                        }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        })
                    }
                    //Adons -------------------
                    var adonsString = ""
                    var extraAdonsString = ""
                    var adonTotalPrice = 0.00
                    var i = 0
                    for addons in (dataSource["default_addon_details"] as? [AnyObject])!{
                        i += 1
                        adonsString = adonsString + "\((addons["addon_name"] as! String).getAESDecryption()) \((addons["addon_quantity"] as! String).getAESDecryption())x"
                        if i != (dataSource["default_addon_details"] as? NSArray)!.count {
                            adonsString = adonsString + ", "
                        }
                        // adonTotalPrice = adonTotalPrice + (addons["addon_price"] as! String).getAESDecryption().toDouble()! ?? 0.0
                    }
                    i = 0
                    for addons in (dataSource["addon_details"] as? [AnyObject])!{
                        i += 1
                        extraAdonsString = extraAdonsString + "\((addons["addon_name"] as! String).getAESDecryption()) \((addons["addon_quantity"] as! String).getAESDecryption())x"
                        if i != (dataSource["addon_details"] as? NSArray)!.count {
                            extraAdonsString = extraAdonsString + ", "
                        }
                        adonTotalPrice = adonTotalPrice + (addons["addon_price"] as! String).getAESDecryption().toDouble()! * (addons["addon_quantity"] as! String).getAESDecryption().toDouble()!
                    }
                    let adonsPreparedString = self.attributedStringTitle("Default Add-Ons: ", description: (adonsString.length > 0 ? adonsString : "N/A") , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray)
                    if extraAdonsString.length > 0 {
                        adonsPreparedString.append(self.attributedStringTitle("\nExtra Add-Ons: ", description: extraAdonsString , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray))
                    }
                    labelAddOns.attributedText = adonsPreparedString
                    self.layoutIfNeeded()
                    //Price and Discount -------------------
                    let basePrice = (datasource["food_size_price"] as! String).getAESDecryption().isEmpty ? 0.0 : (datasource["food_size_price"] as! String).getAESDecryption().toDouble()!
                    
                    let attributedPrice = "Price: \((datasource["food_size_price"] as! String).getAESDecryption().toDouble()! + adonTotalPrice) Taka X \((datasource["food_quantity"] as! String).getAESDecryption()) = "
                    let total = (basePrice + adonTotalPrice) * foodQuantity
                    labelPrice.attributedText = self.attributedStringTitle(attributedPrice, description: (datasource["food_size_price"] as! String).isEmpty ? "0.0" :"\(total) Taka", size: labelPrice.font.pointSize,titleColor: UIColor.darkGray,descriptionColor: DEFAULT_COLOR)
                    //----
                    if let discountAmount = datasource["discount_amount"] as? String{
                        if discountAmount.getAESDecryption().toDouble() > 0 {
                            let Price = self.attributedStringTitle(attributedPrice, description: (datasource["food_size_price"] as! String).isEmpty ? "0.0" :"\(total) Taka", size: labelPrice.font.pointSize,titleColor: UIColor.darkGray,descriptionColor: DEFAULT_COLOR)
                            let discount = (basePrice*foodQuantity) * discountAmount.getAESDecryption().toDouble()!/100
                            Price.append(self.attributedStringTitle("\nDiscount: ", description: "\(discount) Taka (\(discountAmount.getAESDecryption().toDouble()!)% discount on base price)", size: labelPrice.font.pointSize,titleColor: UIColor.darkGray,descriptionColor: UIColor.lightGray))
                            labelPrice.attributedText = Price
                        }
                    }
                    //----------------------------------
                }
                
                if let peyalaCashGained = datasource["loyalty_cash"] as? String{
                    peyalaCashGained.getAESDecryption().isEmpty ? (constraintPeyalaCashViewHeight.constant = 0) : (constraintPeyalaCashViewHeight.constant = 24)
                    //labelPeyalaCashEarned.text = peyalaCashGained.getAESDecryption().isEmpty ? "" : "Earned \(peyalaCashGained.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!.toDouble()! * foodQuantity) Taka in Peyala Cash"
                     labelPeyalaCashEarned.text = peyalaCashGained.getAESDecryption().isEmpty ? "" : "Earned \(peyalaCashGained.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!.toDouble()!) Taka in Peyala Cash"
                    self.layoutSubviews()
                }
            }
            else if self.reuseIdentifier == String(describing: PYLOrderDetailsCell.self)+"Combo"{
                //MARK:- Combocell Configurations
                buttonComboDetails.isHidden = true
                labelPrice.text = ""
                //Food Name, size , discount ---------------
                if let foodname = dataSource["food_name"] as? String{
                    labelOderId.text = foodname.isEmpty ? "N/A" : foodname.getAESDecryption()
                }
                if let varient = datasource["food_size_name"] as? String{
                    labelVariants.text = "Size : \(varient.isEmpty ? "N/A" : varient.getAESDecryption())"
                }
                //Image -------------------
                if let imageUrl = datasource["food_item_img_url"] as? String{
                    self.itemImage.af_setImage(withURL: URL(string: imageUrl.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
                }
                //Adons -------------------
                var adonsString = ""
                var extraAdonsString = ""
                var i = 0
                for addons in (dataSource["default_addon_details"] as? [AnyObject])!{
                    i += 1
                    adonsString = adonsString + "\((addons["addon_name"] as! String).getAESDecryption()) \((addons["addon_quantity"] as! String).getAESDecryption())x"
                    if i != (dataSource["default_addon_details"] as? NSArray)!.count {
                        adonsString = adonsString + ", "
                    }
                }
                i = 0
                for addons in (dataSource["addon_details"] as? [AnyObject])!{
                    i += 1
                    extraAdonsString = extraAdonsString + "\((addons["addon_name"] as! String).getAESDecryption()) \((addons["addon_quantity"] as! String).getAESDecryption())x"
                    if i != (dataSource["addon_details"] as? NSArray)!.count {
                        extraAdonsString = extraAdonsString + ", "
                    }
                }
                let adonsPreparedString = self.attributedStringTitle("Default Add-Ons: ", description: (adonsString.length > 0 ? adonsString : "N/A") , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray)
                if extraAdonsString.length > 0 {
                    adonsPreparedString.append(self.attributedStringTitle("\nExtra Add-Ons: ", description: extraAdonsString , size: labelAddOns.font.pointSize, titleColor: UIColor.black, descriptionColor: UIColor.gray))
                }
                labelAddOns.attributedText = adonsPreparedString
                self.layoutIfNeeded()
            }
            else{
                let dic = datasource as! [String:AnyObject?]
                let Key = dic.keys.first
                let Value = dic[Key!] as! String
                labelLeftKey.text = Key
                labelRightValue.text = Value
                if Key!.contains("Bill") {
                    labelLeftKey.textColor = UIColor.gray
                    labelRightValue.textColor = UIColor.gray
                    labelLeftKey.font = UIFont(name: FONT_BOLD, size: (labelLeftKey?.font?.pointSize)!)
                    labelRightValue.font = UIFont(name: FONT_BOLD, size: (labelRightValue?.font?.pointSize)!)
                    
                    if cardType != "ONLINE" {
                        labelLeftKey.text = "Rounded " + labelLeftKey.text!
                    }
                }else if Key!.contains("Grand"){
                    labelLeftKey.textColor = DEFAULT_COLOR
                    labelRightValue.textColor = DEFAULT_COLOR
                    labelLeftKey.font = UIFont(name: FONT_BOLD, size: (labelLeftKey?.font?.pointSize)!)
                    labelRightValue.font = UIFont(name: FONT_BOLD, size: (labelRightValue?.font?.pointSize)!)
                }else if Key!.contains("Vat"){
                    labelLeftKey.text = labelLeftKey.text! + ": (\(vatPercentage)%)"
                
                }
                else{
                    labelLeftKey.textColor = UIColor.black
                    labelRightValue.textColor = UIColor.gray
                    labelLeftKey.font = UIFont(name: FONT_REGULAR, size: (labelLeftKey?.font?.pointSize)!)
                    labelRightValue.font = UIFont(name: FONT_REGULAR, size: (labelRightValue?.font?.pointSize)!)
                }
            }
        }
    }
    
    @IBAction func OnComboDetails(_ sender: AnyObject) {
        comboDetails(dataSource["food_items"] as! NSArray)
    }
    
    func attributedStringTitle(_ withTitle : String , description : String , size : CGFloat, titleColor: UIColor ,descriptionColor: UIColor ) -> NSMutableAttributedString {
        let title = withTitle
        let Attribute1 = [NSForegroundColorAttributeName: titleColor,NSFontAttributeName: UIFont(name: FONT_BOLD, size: size)!]
        let AttrTitle = NSMutableAttributedString(string: title, attributes: Attribute1)
        let attributedPrice2 = [NSForegroundColorAttributeName: descriptionColor,NSFontAttributeName: UIFont(name: FONT_REGULAR, size: size + 2)!]
        let descriptionText = description
        let attributedDescription = NSAttributedString(string: descriptionText, attributes: attributedPrice2)
        AttrTitle.append(attributedDescription)
        return AttrTitle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.reuseIdentifier == String(describing: PYLOrderDetailsCell.self) || self.reuseIdentifier == String(describing: PYLOrderDetailsCell.self)+"Combo" {
            itemImage.layer.cornerRadius = 4
            itemImage.layer.masksToBounds = true
        }
    }
}
