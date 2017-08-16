//
//  PYLAddOrClearPopUp.swift
//  Peyala
//
//  Created by Adarsh on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLAddOrClearPopUp: UIViewController {
    
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var viewCenter: UIView!
    
    var dismissPopupAction:(()->())!
    var selectedOptionAction:((_ buttonIndex: Int)->())!
    var sourceViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {

        buttonCross.center = CGPoint(x:viewCenter.frame.maxX, y:viewCenter.frame.minY)
        var frame: CGRect
        frame = buttonCross.frame
        frame.origin.x = frame.origin.x - popupRedCrossButtonPadding
        frame.origin.y = frame.origin.y + popupRedCrossButtonPadding
        buttonCross.frame = frame
    }
    
    func setupUI() {
        
    }
    
    internal class func showAddOrClearPopUp(_ sourceViewController: UIViewController, selected:@escaping (_ buttonIndex: Int)->(), dismiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLAddOrClearPopUp.self)) as! PYLAddOrClearPopUp
        viewController.sourceViewController = sourceViewController
        viewController.selectedOptionAction = selected
        viewController.dismissPopupAction = dismiss
        viewController.presentAddOrClearPopUpWith(sourceViewController)
    }
    
    func presentAddOrClearPopUpWith(_ sourceController: UIViewController)  {
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
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25) {
            self.view.transform = .identity
        }
    }
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }) { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
        }
    }
    
    //MARK:  Button Actions
    @IBAction func selectOptionButtonAction(_ sender: UIButton) {
        dismissAnimate()
        if selectedOptionAction != nil {
            selectedOptionAction(sender.tag)
        }
    }
    
    @IBAction func bgButtonAction(_ sender: UIButton) {
        dismissAnimate()
        if dismissPopupAction != nil {
            dismissPopupAction()
        }
    }
    
    @IBAction func crossButtonAction(_ sender: UIButton) {
        dismissAnimate()
        if dismissPopupAction != nil {
            dismissPopupAction()
        }
    }
}
