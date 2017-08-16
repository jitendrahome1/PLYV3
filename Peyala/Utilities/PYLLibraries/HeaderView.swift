//
//  HeaderView.swift
//  Parallex Auto Layout Demo
//
//  Created by Rune Madsen on 2015-08-30.
//  Copyright © 2015 The App Boutique. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var heightLayoutConstraint : NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint : NSLayoutConstraint!
    @IBOutlet weak var leftLayoutConstraint : NSLayoutConstraint!
    @IBOutlet weak var rightLayoutConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var containerLayoutConstraint : NSLayoutConstraint!
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        // The container view is needed to extend the visible area for the image view
        // to include that below the navigation bar. If this container view isn't present
        // the image view would be clipped at the navigation bar's bottom and the parallax
        // effect would not work correctly
        
        containerView!.translatesAutoresizingMaskIntoConstraints = false
        containerView!.backgroundColor = UIColor.red
        self.addSubview(containerView!)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView" : containerView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView" : containerView!]))
        containerLayoutConstraint = NSLayoutConstraint(item: containerView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        self.addConstraint(containerLayoutConstraint!)
        
        let imageView: UIImageView = UIImageView.init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "DeliveryAddressBannerImage")
        containerView!.addSubview(imageView)
        containerView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView" : imageView]))
        bottomLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        containerView!.addConstraint(bottomLayoutConstraint!)
        heightLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1.0, constant: 0.0)
        containerView!.addConstraint(heightLayoutConstraint!)
    }
    
    func setImagePicWithURLString(_ urlString: String){
        let imageViewPic = self.viewWithTag(ImageViewBaseTag+1) as! UIImageView
        imageViewPic.layer.masksToBounds = true
        //imageViewPic.af_setImageWithURL(URL(string: urlString)!)
        
        imageViewPic.af_setImage(withURL: URL(string: urlString)!, placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder.png")!, filter: nil, progress: { (progress) in
            
        }, progressQueue:  DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true) { (image) in
            
        }
        
//        imageViewPic.af_setImageWithURL(
//            URL(string: urlString)!,
//            placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder.png")!,
//            filter:nil,
//            imageTransition: .CrossDissolve(0.5)
//        )
        
        //peyalaBanner, DashboardBannerNoImagePlaceholder.png
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        containerLayoutConstraint!.constant = scrollView.contentInset.top;
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
        containerView!.clipsToBounds = offsetY <= 0
        // bottomLayoutConstraint!.constant = offsetY >= 0 ? 0 : -offsetY / 2
        heightLayoutConstraint!.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        leftLayoutConstraint!.constant = offsetY >= 0 ? -offsetY : 0
        rightLayoutConstraint!.constant = offsetY >= 0 ? -offsetY : 0
    }
}
