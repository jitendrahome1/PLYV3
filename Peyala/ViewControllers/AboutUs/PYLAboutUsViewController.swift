//
//  PYLAboutUsViewController.swift
//  Peyala
//
//  Created by Soumen Das on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLAboutUsViewController: PYLBaseViewController {

    //MARK: - Outlet Collections
    
    @IBOutlet weak var aboutUsTextView: UITextView!
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet var imageViewAboutUs: UIImageView!
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        innerView.layer.cornerRadius = 8
        innerView.clipsToBounds = true
        innerView.layer.borderWidth = 0.5
        innerView.layer.borderColor = UIColor.lightGray.cgColor
        self.aboutUsTextView.text = ""
        self.imageViewAboutUs.image = UIImage(named: "DashboardBannerNoImagePlaceholder")!
        var htmlString = ""
        imageViewAboutUs.layer.masksToBounds = true
        PYLAPIHandler.handler.getAboutUsDetails({ (response) in
            htmlString = (response?["about_description"].stringValue.getAESDecryption())!
            let theString = htmlString
            let theAttributedString = try! NSAttributedString(data: theString.data(using: String.Encoding.utf8, allowLossyConversion: false)!,options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],documentAttributes: nil)
            self.aboutUsTextView.attributedText = theAttributedString
            self.imageViewAboutUs.af_setImage(withURL: URL(string: (response?["display_image"].stringValue.getAESDecryption().replaceSpaceFromURL())!)!, placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder.png")!, filter: nil, progress: { (progress) in
                
            }, progressQueue:  DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true) { (image) in
                
            }
//            self.imageViewAboutUs.af_setImageWithURL(
//                NSURL(string: response["display_image"].stringValue.getAESDecryption().replaceSpaceFromURL())!,
//                placeholderImage: UIImage(named: "DashboardBannerNoImagePlaceholder")!,
//                filter:nil,
//                imageTransition: .CrossDissolve(0.5)
//            )
        }){ (error) in
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(ABOUT_US_SCREEN, isGoogle: true, isFB: true)
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = true
        self.title = "ABOUT PEYALA CAFE"
    }
}
