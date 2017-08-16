//
//  PYLMenuCell.swift
//  Peyala
//
//  Created by Pradip Paul on 17/08/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLMenuCell: PYLBaseTableViewCell {
  //MARK : Outlet connections
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle: UILabel!
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var datasource: AnyObject! {
        didSet{
            let cellData = datasource as! NSDictionary
            if let imageName = cellData.value(forKey: "image") as? String {
                menuIcon.image = UIImage (named: imageName)
            }
            if let title = cellData.value(forKey: "title") as? String{
                menuTitle.text = title
            }
//            menuIcon.transform = CGAffineTransformMakeTranslation(-200, 0)
//            menuTitle.transform = CGAffineTransformMakeTranslation(-200, 0)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
//                self.animateRandomMenu()
            }
        }
    }
    
    func animateRandomMenu() {
            UIView.animate(withDuration: 0.25, delay: (Double(index)/10), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.01, options: .curveLinear, animations: {
                self.menuTitle.transform = CGAffineTransform.identity
                self.menuIcon.transform = CGAffineTransform.identity
            }) { (complete) in
            }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let cellData = datasource as? NSDictionary
        
        if selected {
         
            if (cellData?.value(forKey: "image") as? String) != nil {
                //menuIcon.image = UIImage (named: "\(imageName)Select")
                let currentFont : UIFont = menuTitle.font;
                if #available(iOS 8.2, *) {
                    let newFont     : UIFont = UIFont.systemFont(ofSize: currentFont.pointSize, weight: UIFontWeightBold)
                     menuTitle.font = newFont
                    
                } else {
                    // Fallback on earlier versions
                }
               
             
        }        }
        else{
            if let imageName = cellData?.value(forKey: "image") as? String {
                menuIcon.image = UIImage (named: imageName)
                let currentFont : UIFont = menuTitle.font;
                if #available(iOS 8.2, *) {
                    let newFont     : UIFont = UIFont.systemFont(ofSize: currentFont.pointSize, weight: UIFontWeightRegular)
                    menuTitle.font = newFont
                    
                } else {
                    // Fallback on earlier versions
                }
            }
        }

        

        // Configure the view for the selected state
    }

}
