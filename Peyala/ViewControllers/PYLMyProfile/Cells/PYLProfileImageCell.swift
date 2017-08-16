//
//  PYLProfileImageCell.swift
//  Peyala
//
//  Created by Adarsh on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLProfileImageCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var buttonChange: UIButton!
    @IBOutlet weak var labelUsername: UILabel!
    
    var changeImageBtnTapped:(()->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["name":"Nafees khan","image":"MenuAboutUs","cellId":String(PYLProfileImageCell)]
            let imageUrl = (datasource as! Dictionary<String,AnyObject>)["imageURL"] as! String
            if imageUrl.length > 0 {
//                imageViewProfile.image = UIImage(named: imageUrl)
                imageViewProfile.af_setImage(withURL: NSURL(string: imageUrl)! as URL)
            }
            else {
                imageViewProfile.image = (datasource as! Dictionary<String,AnyObject>)["image"] as? UIImage
            }
            
            labelUsername.text = (datasource as! Dictionary<String,AnyObject>)["name"] as? String
        }
    }
    
    @IBAction func changeBtnAction(_ sender: AnyObject) {
        if changeImageBtnTapped != nil {
            changeImageBtnTapped()
        }
    }
    
}
