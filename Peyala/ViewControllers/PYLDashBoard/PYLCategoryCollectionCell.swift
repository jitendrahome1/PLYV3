//
//  PYLCategoryCollectionCell.swift
//  Peyala
//
//  Created by Adarsh on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLCategoryCollectionCell: PYLBaseCollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override var datasource: AnyObject! {
        didSet{
            //            ["image":"splash_04","title":"wraps"]
            imageViewPhoto.image = UIImage(named: (datasource as! Dictionary<String,AnyObject>)["image"] as! String)
            labelTitle.text = (datasource as! Dictionary<String,AnyObject>)["title"] as? String
//            if let image = datasource["food_category_image_url"] as? String{
//                imageViewPhoto.af_setImageWithURL(
//                    NSURL(string: image.getAESDecryption())!,
//                    placeholderImage: UIImage(named: "DashboardColdBeverage")!,
//                    filter:nil,
//                    imageTransition: .CrossDissolve(0.5)
//                )
//            }
//
//            
//            if let name =  datasource["food_category_name"] as? String{
//                 labelTitle.text = name.getAESDecryption()
//            }
            
        }
    }
      /* {
    "food_category_image_url" : "oE8K2177giaLextmqNkDkBwl0wZUHzXVoNfMwx\/GJWOLFKsP8Dok7mWaLRmLtul9fyk3DSgT9B+LvEoPkHwkN+OzFHMD15Q8I7VqDGRQdwrFunIHMHE\/4KXEDd3lBfyzh6z73llEuZCJ6PAchHU1+Ql\/8G4nczjgbrItPXHERg6iPdFlzXkD3EMb3FuLlqzu",
    "food_category_name" : "Euorvq4lqAHnJpwdoLJwqA==",
    "food_category_id" : "dLF1Vyed36j5y\/jvXF\/QHg==",
    "food_category_haschild" : "b1Hbq4Uf5d5JLEb2ijZSmA=="
}*/
    override func draw(_ rect: CGRect) {
        viewBG.layer.borderWidth = 1.0
        viewBG.layer.borderColor = UIColor.lightGray.cgColor
        viewBG.layer.cornerRadius = IS_IPAD() ? 10 : 5
    }

}
