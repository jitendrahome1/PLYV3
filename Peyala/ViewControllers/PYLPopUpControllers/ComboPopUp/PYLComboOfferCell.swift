//
//  PYLComboOfferCell.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLComboOfferCell: PYLBaseCollectionViewCell {
    @IBOutlet weak var ItemImage: UIImageView!
    @IBOutlet weak var labelOfferName: UILabel!
    @IBOutlet weak var labelOfferDesc: UILabel!
    @IBOutlet weak var labelOfferPrice: UILabel!
    
    override var datasource: AnyObject! {
        
        didSet {
            if let imageUrl = datasource["combo_image_url"] as? String{
                self.ItemImage.af_setImage(withURL: URL(string: imageUrl.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                    
                }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                })
            }
            labelOfferName.text = String.getSafeString(datasource["combo_name"] as AnyObject?).getAESDecryption()
            labelOfferDesc.text = String.getSafeString(datasource["combo_description"] as AnyObject?).getAESDecryption()
            labelOfferPrice.text = String.getSafeString(datasource["combo_price"] as AnyObject?).getAESDecryption() + " Taka"
        }
    }

}
