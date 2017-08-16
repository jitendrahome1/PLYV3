//
//  PYLFoodItemTableViewCell.swift
//  Peyala
//
//  Created by Soumen Das on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLFoodItemTableViewCell: PYLBaseTableViewCell {

    @IBOutlet weak var imageFoodItem: UIImageView!
    @IBOutlet weak var imageNew: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imageVegNonVeg: UIImageView!
    
    @IBOutlet var constraintNewButtonWidth: NSLayoutConstraint!
    @IBOutlet var constraintCashAvailableHeight: NSLayoutConstraint!
    
    override func configureCell() {
          constraintCashAvailableHeight.constant = 0
          self.imageFoodItem.image = UIImage(named: "Placeholder")!
          super.configureCell()
    }
    override var datasource: AnyObject! {
        
        didSet {
          
            if let title = datasource["food_name"] as? String {
                labelTitle.text = title.getAESDecryption()
            }else{
                labelTitle.text = "N/A"
            }
            if let details = datasource["food_description"] as? String {
                labelDescription.text = details.getAESDecryption()
            }else{
                labelDescription.text = "N/A"
            }
            if let image = datasource["food_item_img_url"] as? String {
            self.imageFoodItem.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                    
                })
                
//                
//                self.imageFoodItem.af_setImageWithURL(
//                    URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                    placeholderImage: UIImage(named: "Placeholder")!,
//                    filter:nil,
//                    imageTransition: .CrossDissolve(0.5)
//                )
            }
            if let price = datasource["food_size_prices"] as? String {
                labelPrice.text = "Cost: " + price.getAESDecryption() + " taka"
            }else{
                labelPrice.text = "Cost: N/A" //Cost: 180 taka
            }
            
            if let loyaltyAvailable = datasource["is_loyalty_available"] as? String{
                if loyaltyAvailable.getAESDecryption() == "1" {
                    constraintCashAvailableHeight.constant = 30
                }else{
                     constraintCashAvailableHeight.constant = 0
                }
                self.layoutSubviews()
            }
            if let isNew = datasource["food_item_is_new"] as? String {
                if isNew.getAESDecryption() == "0" {
                    imageNew.isHidden = true
                    constraintNewButtonWidth.constant = 0
                }else{
                    imageNew.isHidden = false
                    constraintNewButtonWidth.constant = 50
                }
                self.layoutSubviews()
            }
            if let isVeg = datasource["is_veg"] as? String {
                if isVeg.getAESDecryption() == "0"{
                    imageVegNonVeg.backgroundColor = .green
                }else{
                    imageVegNonVeg.backgroundColor = .red
                }
            }
        }
    }
    
    
    override func layoutSubviews() {
        imageFoodItem.layer.cornerRadius = 4.0
        imageFoodItem.layer.masksToBounds = true
    }
}
