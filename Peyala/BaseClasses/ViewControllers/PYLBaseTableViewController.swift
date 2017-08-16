//
//  PYLBaseTableViewController.swift
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


class PYLBaseTableViewController: UITableViewController,UINavigationControllerDelegate {

    //MARK: - Varriable Decalration
    var menuButtonEnabled: Bool = true
    var backButtonEnabled: Bool = false
    var rightLogoEnabled: Bool = true
    var notificationButtonEnabled: Bool = false
    var notificationBadge = UILabel()
    var fadeAnimateNavController = false
    let barButtonHeight:CGFloat = IS_IPAD() ? 31.0 :22.0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        PYLNavigationHelper.helper.navigationController.navigationBar.isTranslucent = false
        if systemVersion() > 9.0 {
            PYLNavigationHelper.helper.navigationController.delegate = self
        }
        
        //MARK:  Notification observer settings
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        notificationBadgeNumber(GET_NOTIFICATION_BADGE() as String)
        if !backButtonEnabled {
            self.slideMenuController()?.addLeftGestures()
            self.slideMenuController()?.addRightGestures()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - *************** Navigation Bar Items Setup ***************
    func setNavigationBarItem() {
        
        var barItems  = [UIBarButtonItem]()
        
        if backButtonEnabled {
            self.slideMenuController()?.removeLeftGestures()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "HeaderBackIcon")!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.actionBack))
        } else if menuButtonEnabled {
            self.addLeftBarButtonWithImage(UIImage(named: "New")!)
            self.slideMenuController()?.addLeftGestures()
            self.slideMenuController()?.addRightGestures()
        }
        if rightLogoEnabled {
            
            barItems.append(self.setRightBarButtonItem())
            let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
            negativeSpace.width = -9
            barItems.append(negativeSpace)
        }
        if notificationButtonEnabled {
            barItems.append(self.setNotificationBarButtonItem())
        }
        self.navigationItem.rightBarButtonItems =  barItems
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
        return barButton
    }
    
    //MARK: Notification Badge Set Up
    func notificationBadgeNumber(_ badgenumber: String)  {
        
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
    
    //MARK: - NAvigation Controller Delegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == .push &&  fadeAnimateNavController == true){
            return PushAnimator()
        }
        if (operation == .pop &&  fadeAnimateNavController == true){
            return PopAnimator()
        }
        return nil
    }
    
    //MARK: - Nav Bar Button Action
    func actionBack() {
        
        fadeAnimateNavController = false
        if (PYLNavigationHelper.helper.navigationController != nil) {
            PYLNavigationHelper.helper.navigationController.popViewController(animated: true)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func gotoNotification() {
        
        let notificationViewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLNotificationViewController.self)) as! PYLNotificationViewController
        PYLNavigationHelper.helper.navigationController.pushViewController(notificationViewController, animated: true)
    }
    
    func actionSearch() {
    }
    
    func actionDone() {
    }
    
    //MARK: - User Defined Function
    func pushToViewController(_ storyboardName:UIStoryboard , viewController : String) {
        
        removeViewControllerFromNavigationStack(viewController)
        let viewControllerr = storyboardName.instantiateViewController(withIdentifier: viewController)
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewControllerr, animated: true)
    }
    
    func removeViewControllerFromNavigationStack(_ viewController : String) {
        
        for item in PYLNavigationHelper.helper.navigationController.viewControllers {
            if item.className == viewController {
                debugPrint("hasviewcontroller")
                PYLNavigationHelper.helper.navigationController.viewControllers.removeObject(item)
            }
        }
    }
    
    func goToLoginScreen(_ completion:@escaping (_ success: Bool)->()) {
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLLoginViewController.self)) as! PYLLoginViewController
        viewController.loginSuccess = {(_success) in
            self.fadeAnimateNavController = true
            viewController.navigationController?.delegate = self
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
            self.pushToViewController(servicesStoryboard, viewController: (String(describing: PYLDashBoardViewController.self)))
            let alert = UIAlertController(title: "PEYALA", message: SESSION_EXPIRED_ALERT, preferredStyle: .alert)
            alert.view.tintColor = DEFAULT_COLOR
            let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) { (action) in
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
        }
    }
}
