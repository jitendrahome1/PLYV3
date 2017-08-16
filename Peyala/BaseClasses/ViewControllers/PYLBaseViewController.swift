//
//  PYLBaseViewController.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let timeBarButtonDisable = 0.5

class PYLBaseViewController: UIViewController , UINavigationControllerDelegate {
    
    //MARK: - Varriable Declaration
    var menuButtonEnabled: Bool = true
    var notificationButtonEnabled: Bool = false
    var cartButtonEnabled: Bool = false
    var searchButtonEnabled: Bool = false
    var rightLogoEnabled: Bool = true
    var backButtonEnabled: Bool = false
    var notificationBadge = UILabel()
    var cartBadge = UILabel()
    var fadeAnimateNavController = false
    let barButtonHeight:CGFloat = IS_IPAD() ? 31.0 :22.0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.setNavigationBarItem()
        PYLNavigationHelper.helper.navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                                             NSFontAttributeName : UIFont(name: FONT_BOLD, size: IS_IPAD() ? 23 : 18)!]
        
        PYLNavigationHelper.helper.navigationController.navigationBar.isTranslucent = false
        if systemVersion() > 9.0 {
            PYLNavigationHelper.helper.navigationController.delegate = self
        }
        
        //MARK: Notification observer settings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkOnConnectAction),
            name: NSNotification.Name(rawValue: NETWORK_REACHABILITY),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNotificationBadgeCounter),
            name: NSNotification.Name(rawValue: NOTIFICATION_BADGE_UPDATE),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.setNavigationBarItem()
         notificationBadgeNumber(GET_NOTIFICATION_BADGE() as String)
         cartBadgeNumber(GET_CART_BADGE() as String)
        if !backButtonEnabled {
            self.slideMenuController()?.addLeftGestures()
            self.slideMenuController()?.addRightGestures()
        }
    }

    //MARK: - *************** Navigation Bar Items Setup ***************
    func setNavigationBarItem() {
        if backButtonEnabled {
            self.slideMenuController()?.removeLeftGestures()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "HeaderBackIcon")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.actionBack))
        }else if menuButtonEnabled {
            self.addLeftBarButtonWithImage(UIImage(named: "HeaderMenuIcon")!)
            self.slideMenuController()?.addLeftGestures()
            self.slideMenuController()?.addRightGestures()
        }
        
        var barItems  = [UIBarButtonItem]()
        
        if searchButtonEnabled {
            barItems.append(self.setSearchBarButtonItem())
        }
        if notificationButtonEnabled {
            
            barItems.append(self.setNotificationBarButtonItem())
        }
        if cartButtonEnabled && IS_USER_LOGIN() && (PYLGlobals.globals.NotificationBannerTapped == false ){
            
            barItems.append(self.setCartBarButtonItem())
        }
        if rightLogoEnabled {
            
            barItems.append(self.setRightBarButtonItem())
            let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            negativeSpace.width = -9
            barItems.append(negativeSpace)
        }
        self.navigationItem.rightBarButtonItems =  barItems.reversed()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    //MARK: Right Bar Button Setup
    func setRightBarButtonItem()->UIBarButtonItem {
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        let Button = UIButton()
        Button.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        Button.isUserInteractionEnabled = false
        Button.setBackgroundImage(PYLHelper.helper.selectedCountryFlagImage, for: UIControlState())
        barButton.customView = Button
        return barButton
    }
    
    //MARK: Navigation Title Setup
    func setNavigationBarTitle(_ title: String?)  {
        self.navigationItem.title = title!
    }
    
    //MARK: Search Bar Button Set Up
    func setSearchBarButtonItem()-> UIBarButtonItem {
        
        let barButton = UIBarButtonItem()
        let Button = UIButton()
        Button.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        Button.setBackgroundImage(UIImage(named: "HeaderSearchIcon"), for: UIControlState())
        barButton.customView = Button
        Button.addTarget(self, action: #selector(self.actionSearch), for: .touchUpInside)
        return barButton
    }
    
    //MARK: Notification Bar Button Set Up
    func setNotificationBarButtonItem()->UIBarButtonItem {
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        let View = UIView()
        View.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        
        barButton.customView = View
        
        let Button = UIButton()
        Button.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        Button.setBackgroundImage(UIImage(named: "HeaderNotificationIcon"), for: UIControlState())
        notificationBadge.frame = CGRect(x: 0, y: 0, width: 20, height: 13)
        notificationBadge.sizeToFit()
        notificationBadge.center = CGPoint(x: Button.frame.width/2.0, y: notificationBadge.center.y)
        Button.addTarget(self, action: #selector(gotoNotification), for: .touchUpInside)
        View.addSubview(Button)
        View.addSubview(notificationBadge)
        
        //offline crash solve
        if(!PYLHelper.helper.isNetworkOn) {
            Button.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeBarButtonDisable * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                Button.isEnabled = true
            }
        }
        return barButton
    }
    
    //MARK: Notification Badge Set Up
    func notificationBadgeNumber(_ badgenumber : String)  {
        
        notificationBadge.font = UIFont(name: FONT_REGULAR, size: IS_IPAD() ? 14 : 10)
        notificationBadge.text = (Int)(badgenumber) > 99 ? MAXIMUM_CART_COUNT : "\(badgenumber)"
        notificationBadge.textAlignment = .center
        notificationBadge.backgroundColor = UIColor.red
        notificationBadge.textColor = UIColor.white
        notificationBadge.sizeToFit()
        notificationBadge.roundedLabel()
        
        if (Int)(badgenumber) > 0 {
            notificationBadgeShow()
        } else {
            notificationBadgeisHidden()
        }
    }
    
    func notificationBadgeisHidden() {
        notificationBadge.isHidden = true
    }
    
    func notificationBadgeShow() {
        notificationBadge.isHidden = false
    }
    
    //MARK: Cart Bar Button Set Up
    func setCartBarButtonItem()->UIBarButtonItem {
        
        let barButton: UIBarButtonItem = UIBarButtonItem()
        let View = UIView()
        View.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        
        let Button = UIButton()
        Button.frame = CGRect(x: 0, y: 0, width: barButtonHeight, height: barButtonHeight)
        Button.setBackgroundImage(UIImage(named: "HeaderCartIcon"), for: UIControlState())
        cartBadge.frame = CGRect(x: 0, y: 0, width: 20, height: 13)
        cartBadge.textAlignment = .center
        cartBadge.backgroundColor = UIColor.white
        cartBadge.sizeToFit()
        cartBadge.center = CGPoint(x: Button.frame.width/2.0, y: cartBadge.center.y)
        
        Button.addTarget(self, action: #selector(gotoCart), for: .touchUpInside)
        View.addSubview(Button)
        View.addSubview(cartBadge)
        barButton.customView = View
        
        //offline crash solve
        if(!PYLHelper.helper.isNetworkOn) {
            Button.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeBarButtonDisable * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                Button.isEnabled = true
            }
        }
        return barButton
    }
    
    //MARK: Cart Badge Set Up
    func cartBadgeNumber(_ badgenumber : String)  {
        
        cartBadge.font = UIFont(name: FONT_REGULAR, size: IS_IPAD() ? 14 : 10)
        cartBadge.text = (Int)(badgenumber) > 99 ? MAXIMUM_CART_COUNT : "\(badgenumber)"
        cartBadge.textAlignment = .center
        cartBadge.backgroundColor = UIColor.red
        cartBadge.textColor = UIColor.white
        cartBadge.sizeToFit()
        cartBadge.roundedLabel()
        
        if (Int)(badgenumber) > 0 {
            cartBadgeShow()
        } else {
            cartBadgeisHidden()
        }
    }
    
    func cartBadgeisHidden() {
        cartBadge.isHidden = true
    }
    
    func cartBadgeShow() {
        cartBadge.isHidden = false
    }
    
    //MARK: - NAvigation Controller Delegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == .push && fadeAnimateNavController == true){
            return PushAnimator()
        }
        if (operation == .pop && fadeAnimateNavController == true){
            return PopAnimator()
        }
        return nil
    }
    
    //MARK: - Nav Bar Button Action
    func actionBack() {
        
        PYLSpinner.hide()
        fadeAnimateNavController = false
        PYLGlobals.globals.NotificationBannerTapped = false
        if  (PYLNavigationHelper.helper.navigationController != nil) {
            let previousViewController =  PYLNavigationHelper.helper.navigationController.viewControllers[PYLNavigationHelper.helper.navigationController.viewControllers.count - 2]
            if previousViewController.isKind(of: PYLNewDeliveryAddressViewController.self) {
             PYLNavigationHelper.helper.navigationController.popToViewController(PYLNavigationHelper.helper.navigationController.viewControllers[PYLNavigationHelper.helper.navigationController.viewControllers.count - 3], animated: false);
            }
            PYLNavigationHelper.helper.navigationController.popViewController(animated: true)
        }
    }
    
    func gotoCart() {
        self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyCartViewController.self))
    }
    
    func gotoNotification() {
        let notificationViewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLNotificationViewController.self)) as! PYLNotificationViewController
        PYLNavigationHelper.helper.navigationController.pushViewController(notificationViewController, animated: true)
        
    }
    
    func actionSearch(_ sender: UIButton!) {
        
        sender.isEnabled = false
        PYLSearchPopUpViewController.showSearchPopup(self, selectedOption: { SelectedData in
            sender.isEnabled = true
            if let foodId = SelectedData["food_id"] as? String{
                let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLFoodDetailsViewController.self)) as! PYLFoodDetailsViewController
                viewController.foodID = foodId.getAESDecryption()
                self.removeViewControllerFromNavigationStack(String(describing: viewController))
                PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
            }else if let keyword = SelectedData as? String{
                let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLFoodItemsViewController.self))  as! PYLFoodItemsViewController
                viewController.keywordSearch = keyword
                viewController.arrFoodSubCategory = [keyword]
                self.removeViewControllerFromNavigationStack(String(describing: viewController))
                PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
            }
        }) { 
            sender.isEnabled = true
        }
    }
    
    //MARK: - User Defined Function
    func pushToViewController(_ storyboardName:UIStoryboard , viewController : String)  {
        
        removeViewControllerFromNavigationStack(viewController)
        let viewControllerr = storyboardName.instantiateViewController(withIdentifier: viewController)
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewControllerr, animated: true)
    }
    
    func removeViewControllerFromNavigationStack(_ viewController : String) {
        
        for item in PYLNavigationHelper.helper.navigationController.viewControllers {
            if viewController.contains(item.className) {
                debugPrint("hasviewcontroller")
                PYLNavigationHelper.helper.navigationController.viewControllers.removeObject(item)
            }
        }
    }
    
    // LOGIN Navigation
    func goToLoginScreen(_ completion:@escaping (_ success: Bool)->()) {
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLLoginViewController.self)) as! PYLLoginViewController
        viewController.loginSuccess = {(_success) in
            self.fadeAnimateNavController = true
            //viewController.navigationController?.delegate = self
            _ = viewController.navigationController?.popViewController(animated: true)
            completion(_success)
        }
        PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
    }
    
    // LOGOUT
    func logOutForSessionTokenMismatch() {
        
        PYLAPIHandler.handler.logout({ (response) in
            REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
            REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY)
            SET_NOTIFICATION_BADGE("\(0)")
            UIApplication.shared.applicationIconBadgeNumber = 0
            PYLHelper.helper.userModelObj = nil
            PYLHelper.helper.LogginStatusChanged = true
            self.pushToViewController(servicesStoryboard, viewController: (String(describing: PYLDashBoardViewController.self)))
            let alert = UIAlertController(title: "PEYALA", message: SESSION_EXPIRED_ALERT, preferredStyle: .alert)
            alert.view.tintColor = DEFAULT_COLOR
            let cancelAction = UIAlertAction(title: OK, style: .cancel) { (action) in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            }, failure: { (error) in
        })
    }
    
    // USER INACTIVE
    func inactiveUserAction(withMessage msg: String) {
        
        PYLAPIHandler.handler.logout({ (response) in
            REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
            REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY)
            PYLHelper.helper.userModelObj = nil
            self.pushToViewController(servicesStoryboard, viewController: (String(describing: PYLDashBoardViewController.self)))
            let alert = UIAlertController(title: kAppTitle, message: msg, preferredStyle: .alert)
            alert.view.tintColor = DEFAULT_COLOR
            let okAction = UIAlertAction(title: OK, style: .cancel) { (action) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            }, failure: { (error) in
        })
    }
    
    //MARK: - Notification Action
    func networkOnConnectAction() {
        debugPrint("Network connected")
    }
    
    func updateNotificationBadgeCounter() {
        // this function getting called thrice
        debugPrint("Update badge accordingly")
        let notificationBadgeCount_str = (GET_NOTIFICATION_BADGE() as String)
        if (Int)(notificationBadgeCount_str) > 0 {
            notificationBadgeShow()
            notificationBadge.text = (Int)(notificationBadgeCount_str) > 99 ? MAXIMUM_CART_COUNT : notificationBadgeCount_str
            notificationBadge.sizeToFit()
            notificationBadge.roundedLabel()
            //notificationBadge.superview!.layoutIfNeeded()
        }
    }
}

//MARK:- Custom PUSH Animation
class PushAnimator: NSObject ,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        let toViewController: UIViewController   = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
         toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        transitionContext.containerView.addSubview(toViewController.view);
        toViewController.view.alpha = 0.0;
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { 
            toViewController.view.alpha = 1.0;
            }, completion: { (compelted) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}

//MARK:- Custom POP Animation
class PopAnimator : NSObject ,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
   
        let toViewController: UIViewController   = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromViewController : UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            fromViewController.view.alpha = 0.0;
        }, completion: { (compelted) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}
