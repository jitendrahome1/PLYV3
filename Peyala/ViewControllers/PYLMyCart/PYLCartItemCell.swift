//
//  PYLCartItemCell.swift
//  Peyala
//
//  Created by Adarsh on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLCartItemCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var imageViewItem: UIImageView!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var labelItemDesc: UILabel!
    @IBOutlet weak var labelAddOnsValue: UILabel!
    @IBOutlet weak var labelBasicPrice: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var buttonAddQuantity: UIButton!
    @IBOutlet weak var buttonSubtractQuantity: UIButton!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var viewQuantityUpdater: UIView!
    @IBOutlet weak var constraintCurveViewBottom: NSLayoutConstraint!
    @IBOutlet var constraintPeyalaCashHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewItemTag: UIImageView!
    @IBOutlet weak var viewLineGray: UIView!
    @IBOutlet weak var buttonComboDetails: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var labelLoyaltyCash: UILabel!
    
    var basicPrice = 0.0
    var quantity = 0
    var totalPrice = 0.0
    
    var productQuantityUpdateBlock:((_ quantity: Int, _ totalPrice:Double)->())!
    var deleteButtonTapped:(()->())!
    var editButtonTapped:(()->())!
    var comboDetailsTapped:(()->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["itemImage":"splash_04","itemName":"Chittaginian beef bhuna","itemDesc":"dsjuhygdqeyd ygydgweygd uuyye","addOnsValue":"Meat2x","basicPrice":"750","quantity":"3","total":"2250","cellId":String(PYLCartItemCell)]
            //            imageViewItem.image = UIImage(named: ((datasource as! Dictionary<String,AnyObject>)["itemImage"] as? String)!)
            let imageUrlStr = datasource["itemImage"] as! String
            let imageUrl = NSURL(string: imageUrlStr.replaceSpaceFromURL())
            imageViewItem.image = UIImage(named: "Placeholder")!
            self.imageViewItem.af_setImage(withURL: imageUrl! as URL, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                
            })
            labelItemName.text = (datasource as! Dictionary<String,AnyObject>)["itemName"] as? String
            labelItemDesc.text = (datasource as! Dictionary<String,AnyObject>)["itemDesc"] as? String
            let loyaltyCash = (datasource as! Dictionary<String,AnyObject>)["loyaltyCash"] as! String
            labelLoyaltyCash.text = "Earn \(loyaltyCash) Peyala Cash"
            //            labelAddOnsValue.text = (datasource as! Dictionary<String,AnyObject>)["addOnsValue"] as? String
            let adonsString = (datasource as! Dictionary<String,AnyObject>)["addOnsValue"] as? String
            let adonsPreparedString = self.attributedStringTitle("Add-ons: ", description: (adonsString!.length > 0 ? adonsString! : "N/A") , descFont: labelAddOnsValue.font, titleColor: UIColor.black, descriptionColor: UIColor.darkGray)
            labelAddOnsValue.attributedText = adonsPreparedString
            
            //            basicPrice = Double(((datasource as! Dictionary<String,AnyObject>)["basicPrice"] as? String)!)!
            basicPrice = Double(((datasource as! Dictionary<String,AnyObject>)["singlePrice"] as? String)!)!
            labelBasicPrice.text = "Price: \("\(basicPrice)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka  X "
            quantity = Int(((datasource as! Dictionary<String,AnyObject>)["quantity"] as? String)!)!
            labelQuantity.text = "\(quantity)"
            totalPrice = Double(((datasource as! Dictionary<String,AnyObject>)["total"] as? String)!)!
//            labelTotalPrice.text = "= \(totalPrice) Taka"
            labelTotalPrice.text = "= \("\(totalPrice)".toDoubleWithRoundOfUpToTwoDecimal()!) Taka"
            let isCombo = ((datasource as! Dictionary<String,AnyObject>)["isCombo"] as! String) == "1"
            buttonComboDetails.isHidden = !isCombo
            let isDeleted = ((datasource as! Dictionary<String,AnyObject>)["isDeleted"] as! String) == "1"
            let isChanged = ((datasource as! Dictionary<String,AnyObject>)["isChanged"] as! String) == "1"
            if isDeleted {
                imageViewItemTag.isHidden = false
                imageViewItemTag.image = UIImage(named: "notAvailableTag")
                disableSettingsForDeletedItem(shouldDisable: true)
            }
            else if isChanged {
                imageViewItemTag.isHidden = false
                imageViewItemTag.image = UIImage(named: "changedTag")
                disableSettingsForDeletedItem(shouldDisable: true)
                buttonEdit.isEnabled = true // additional settings for changed item.
            }
            else {
                imageViewItemTag.isHidden = true
                disableSettingsForDeletedItem(shouldDisable: false)
            }
            
            //            if let loyaltyAvailable = datasource["is_loyalty_available"] as? String{
            //                if loyaltyAvailable.getAESDecryption() == "1" {
            //                    constraintPeyalaCashHeight.constant = 30
            //                }else{
            //                    constraintPeyalaCashHeight.constant = 0
            //                }
            //                self.layoutIfNeeded()
            //            }
            let isLoyaltyAvailable = Int(datasource["isLoyaltyAvailable"] as! String)!
            constraintPeyalaCashHeight.constant = isLoyaltyAvailable == 0 ? 0 : 30
            
            viewQuantityUpdater.layer.borderWidth = 1.0
            viewQuantityUpdater.layer.borderColor = UIColor.lightGray.cgColor
            viewQuantityUpdater.layer.cornerRadius = 2.0
        }
    }
    
    //MARK: User defined functions
    func disableSettingsForDeletedItem(shouldDisable:Bool) {
        buttonAddQuantity.isEnabled = !shouldDisable
        buttonSubtractQuantity.isEnabled = !shouldDisable
        buttonSubtractQuantity.isEnabled = !shouldDisable
        buttonEdit.isEnabled = !shouldDisable
        if !buttonComboDetails.isHidden {
            buttonComboDetails.isEnabled = !shouldDisable
            buttonComboDetails.alpha = shouldDisable ? 0.6 : 1.0
        }
    }
    
    func attributedStringTitle(_ withTitle : String , description : String , descFont : UIFont, titleColor: UIColor ,descriptionColor: UIColor ) -> NSMutableAttributedString {
        let title = withTitle
        let Attribute1 = [NSForegroundColorAttributeName: titleColor,NSFontAttributeName: descFont]
        let AttrTitle = NSMutableAttributedString(string: title, attributes: Attribute1)
        let attributedPrice2 = [NSForegroundColorAttributeName: descriptionColor,NSFontAttributeName: descFont]
        let descriptionText = description
        let attributedDescription = NSAttributedString(string: descriptionText, attributes: attributedPrice2)
        AttrTitle.append(attributedDescription)
        return AttrTitle
    }
    
    //MARK: Button actions
    
    @IBAction func addOrSubtractQuantityBtnAction(_ sender: UIButton) {
        var arrNumber = [String]()
        for i in 1...MAX_QTY {
            arrNumber.append("\(i)")
        }
        
        let preselectedVal = "\(quantity)"
        PYLPickerViewController.showPickerController((appdelegate().window?.rootViewController)!, isDatePicker: false, pickerArray: arrNumber, position: .bottom, pickerTitle: "", preSelected: preselectedVal, selected: { (value, index) in
            
            guard (value as! String).length > 0 else { return }
            guard (value as! String) != preselectedVal else { return }
            self.quantity = Int((value as! String))!
            self.totalPrice = self.basicPrice * Double(self.quantity)
            if self.productQuantityUpdateBlock != nil {
                self.productQuantityUpdateBlock(self.quantity, self.totalPrice)
            }
        })
    }
    
    @IBAction func editItemBtnAction(_ sender: UIButton) {
        if editButtonTapped != nil {
            editButtonTapped()
        }
    }
    
    @IBAction func deleteItemBtnAction(_ sender: UIButton) {
        if deleteButtonTapped != nil {
            deleteButtonTapped()
        }
    }
    
    @IBAction func comboDetailsBtnAction(_ sender: UIButton) {
        if comboDetailsTapped != nil {
            comboDetailsTapped()
        }
    }
}
