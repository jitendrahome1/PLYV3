//
//  PYLBannerCollectionCell.swift
//  Peyala
//
//  Created by Adarsh on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import AlamofireImage

class PYLBannerCollectionCell: PYLBaseCollectionViewCell {

    @IBOutlet weak var imageViewBanner:   UIImageView!
    @IBOutlet weak var labelTitle:        UILabel!
    @IBOutlet weak var labelCost:         UILabel!

    override var datasource: AnyObject! {
        
        didSet {
//            imageViewBanner.af_setImageWithURL(NSURL(string: "https://httpbin.org/image/png")!)
            imageViewBanner.contentMode = IS_IPAD() ? .scaleAspectFill : .scaleToFill
            imageViewBanner.image = UIImage(named: "DashboardBannerNoImagePlaceholder.png")!
            let imageUrlStr = datasource["image"] as! String
            let imageUrl = URL(string: imageUrlStr.replaceSpaceFromURL())
            //imageViewBanner.af_setImageWithURL(imageUrl!)
            
            imageViewBanner.af_setImage(withURL: imageUrl!, placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder.png")!, filter: nil, progress: { (progress) in
                
            }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true) { (image) in
                
            }
            
//            imageViewBanner.af_setImageWithURL(
//                imageUrl!,
//                placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder.png")!,
//                filter:nil,
//                imageTransition: .CrossDissolve(0.5)
//            )
            
//            if String.isSafeString(datasource["title"]) {
//                labelTitle.text = datasource["title"] as? String
//            }
//            if String.isSafeString(datasource["price"]) {
//                labelCost.text = datasource["price"] as? String
//            }
        }
    }
}
