//
//  PYLGotNearByBranchPopUpViewController.swift
//  Peyala
//
//  Created by Soumen Das on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLGotNearByBranchPopUpViewController: PYLBasePopUpViewController {

    //MARK: - Outlet Collections
    
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var viewCenter: UIView!
    
    @IBOutlet var labelServiceType: UILabel!
    var dissmissPopUpAction:(()->())!
    var chooseBranchAction:(()->())!
    var sourceViewController: UIViewController?
    var serviceType:DeliveryOption!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        //        buttonCross.center = CGPointMake(CGRectGetMaxX(viewCenter.frame), CGRectGetMinY(viewCenter.frame))
        buttonCross.center = CGPoint(x: viewCenter.frame.maxX, y: viewCenter.frame.minY)
        var frame: CGRect
        frame = buttonCross.frame
        frame.origin.x = frame.origin.x - popupRedCrossButtonPadding
        frame.origin.y = frame.origin.y + popupRedCrossButtonPadding
        buttonCross.frame = frame
    }

    
    // MARK: - User Defined Functiom
    
    internal class func showGotNearByBranchPopUp(_ sourceController: UIViewController,serviceType:DeliveryOption, selected:@escaping ()->(), dissmiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: "PYLGotNearByBranchPopUpViewController") as! PYLGotNearByBranchPopUpViewController
        viewController.sourceViewController = sourceController
        viewController.chooseBranchAction = selected
        viewController.dissmissPopUpAction = dissmiss
        viewController.serviceType = serviceType
        viewController.presentPopUP(sourceController)
    }
    
    func presentPopUP(_ sourceController: UIViewController) {
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        labelServiceType.text = (serviceType == .DineIn) ? "to Dine-in" : (serviceType == .TakeAway) ? "and Takeaway" : ""
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.viewCenter.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        imagevwBackground.alpha = 0.0
        buttonCross.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.imagevwBackground.alpha = 0.7
            self.buttonCross.isHidden = false
            self.viewCenter.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimate(_ Closed:Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.imagevwBackground.alpha = 0.0
            self.buttonCross.isHidden = true
            self.viewCenter.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if Closed == true{
                if self.dissmissPopUpAction != nil {
                    self.dissmissPopUpAction()
                }
            }else{
                if self.chooseBranchAction != nil {
                    self.chooseBranchAction()
                }
            }
        }) 
    }
    
    //MARK:  Button Actions
    @IBAction func chooseBranchButtonAction(_ sender: AnyObject) {
        dismissAnimate(false)
    }
    
    @IBAction func crossButtonAction(_ sender: AnyObject) {
        dismissAnimate(true)
    }
    
}
