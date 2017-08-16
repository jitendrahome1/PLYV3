//
//  PYLNoNearByBranchPopUpViewController.swift
//  Peyala
//
//  Created by Soumen Das on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLNoNearByBranchPopUpViewController: PYLBasePopUpViewController {

    //MARK: - Outlet Collections
    
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var viewCenter: UIView!
    @IBOutlet weak var labelTitleTwo: UILabel!
    @IBOutlet weak var labelTitileOne: UILabel!
    
    
    var dissmissPopUpAction:(()->())!
    var sourceViewController: UIViewController?
    
    
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
        
        if sourceViewController!.isKind(of: PYLLocationViewController.self) {
            labelTitleTwo.text = NO_NEAR_BRANCH_ENTER_MANUALLY
        }
    }


    // MARK: - User Defined Functiom
    
    internal class func showNoNearByBranchPopUp(_ sourceController: UIViewController, dissmiss:@escaping ()->()) {

        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: "PYLNoNearByBranchPopUpViewController") as! PYLNoNearByBranchPopUpViewController
        viewController.sourceViewController = sourceController
        viewController.dissmissPopUpAction = dissmiss
        viewController.presentPopUP(sourceController)
    }
    
    func presentPopUP(_ sourceController: UIViewController) {
//        self.view.frame = sourceController.view.bounds
//        sourceController.view.addSubview(self.view)
//        sourceController.addChildViewController(self)
//        sourceController.view.bringSubviewToFront(self.view)
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)

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
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.viewCenter.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
             self.imagevwBackground.alpha = 0.0
            self.buttonCross.isHidden = true
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
        }) 
    }
    
    //MARK:  Button Actions
    @IBAction func crossButtonAction(_ sender: AnyObject) {
        dismissAnimate()
        if dissmissPopUpAction != nil {
            dissmissPopUpAction()
        }
    }
}
