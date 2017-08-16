//
//  PYLMenuViewController.swift
//  Peyala
//
//  Created by Chinmay Das on 01/08/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
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

var animateMenu = false

class PYLMenuViewController: PYLBaseViewController,SlideMenuControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    //MARK : Outlet Connections
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var myProfileHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonLoginLogout: UIButton!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var imageLabelName: UILabel!
    @IBOutlet var labelVersion: UILabel!
    var arrMenuItems: NSArray?
    var arrSubMenuItems = NSMutableArray()
    var selectedSection = 999
    var isExpanded : Bool = false
    var ExpandedMenuIndex  = 999
    var viewControllerClass: AnyClass!
    var viewControllerTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Get Menu Items
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Menu", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        arrMenuItems = (myDict!.value(forKey: "MenuItems") as! NSArray)
        labelVersion.text = "Version : \(UIApplication.versionBuild())"
        /////////////////////////////////////////////////////////////
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            if animateMenu {
                self.animateMenuItems()
            }
        }
        if IS_USER_LOGIN() {
            labelUsername.text = "\(PYLHelper.helper.userModelObj!.firstName)"
            if labelUsername.text?.length > 0 {
                labelUsername.text = labelUsername.text!.capitalized
                labelUsername.text!.replaceSubrange(labelUsername.text!.startIndex...labelUsername.text!.startIndex, with: String(labelUsername.text![labelUsername.text!.startIndex]).capitalized)
                labelUsername.text = "Hi, \(labelUsername.text!)"
            }
            myProfileButton.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.myProfileHeightConstraint.constant = 00
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
                self.view.updateConstraintsIfNeeded()
            }) 
            buttonLoginLogout.setTitle("Logout", for: UIControlState())
            if let profileURL = PYLHelper.helper.userModelObj?.profileImageUrl{
                userImageView.contentMode = .scaleAspectFill
                if profileURL.isValidURL {
                    activityIndicator.startAnimating()
                    userImageView.image = nil
                    userImageView.isHidden = false
                    imageLabelName.isHidden = true
                    userImageView.af_setImage(withURL: URL(string: profileURL)!, placeholderImage: nil, filter: nil, progress: { (Progress) in
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: true, completion: { (Response) in
                        self.activityIndicator.stopAnimating()
                    })
                    
//                    userImageView.af_setImageWithURL(URL(string: profileURL)!, placeholderImage: nil, filter: nil, progress: { (bytesRead, totalBytesRead, totalExpectedBytesToRead) in
//                        }, progressQueue: DispatchQueue.main, imageTransition:.CrossDissolve(0.3), runImageTransitionIfCached: true, completion: { (Response) in
//                            
//                    })
                }else{
                    userImageView.isHidden = true
                    imageLabelName.isHidden = false
                    if let firstName = PYLHelper.helper.userModelObj?.firstName {
                        imageLabelName.text =  String(firstName.characters.prefix(1)).uppercased()
                        imageLabelName.font = UIFont(name: FONT_REGULAR, size: imageLabelName.frame.width*0.7)
                    }
                }
            }
        }
        else{
            userImageView.isHidden = true
            imageLabelName.isHidden = false
            myProfileButton.isHidden = true
//          labelUsername.text = "Hi,Guest User"
            labelUsername.text = "Guest User"
            buttonLoginLogout.setTitle("Login", for: UIControlState())
            imageLabelName.text =  "G"
            imageLabelName.font = UIFont(name: FONT_REGULAR, size: imageLabelName.frame.width*0.7)
            UIView.animate(withDuration: 0.4, animations: {
                self.myProfileHeightConstraint.constant = 0
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
                self.view.updateConstraintsIfNeeded()
            }) 
            let LoggedInItems = arrMenuItems!.filter({
                if let type = ($0 as! [String:AnyObject])["loginRequired"] as? Bool{
                    return type == true
                }
                return false
            })
            
            let mutableArray = arrMenuItems?.mutableCopy()
            for items in LoggedInItems {
                (mutableArray as AnyObject).remove(items)
            }
            arrMenuItems = mutableArray as? NSArray
            debugPrint(LoggedInItems);
            
        }
        if(PYLHelper.helper.LogginStatusChanged == true){
            arrSubMenuItems.removeAllObjects()
            selectedSection = 1000
            PYLHelper.helper.LogginStatusChanged = false
        }
        menuTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        userImageView.layoutIfNeeded()
        userImageView.layer.cornerRadius = userImageView.frame.width/2.0
        userImageView.layer.masksToBounds = true
        imageLabelName.layoutIfNeeded()
        imageLabelName.layer.cornerRadius = imageLabelName.frame.width/2.0
        imageLabelName.layer.masksToBounds = true
        imageLabelName.textAlignment = .center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return arrMenuItems!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return IS_IPAD() ? 90.0 : 50.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (arrMenuItems?.count)! - 1{
        return IS_IPAD() ? 90.0 : 50.0
        }
        return 0
    }
    
    var arrayIcons = [UIImageView]()
    var arrayTitle = [UILabel]()
    
    func animateMenuItems() {
        for (index, item) in arrayTitle.enumerated() {
            UIView.animate(withDuration: 0.25, delay: (Double(index)/10), usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                item.alpha = 1.0
                item.transform = CGAffineTransform.identity
            }) { (complete) in
            }
        }
        for (index, item) in arrayIcons.enumerated() {
            UIView.animate(withDuration: 0.25, delay: (Double(index)/10), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.01, options: .curveEaseOut, animations: {
                item.alpha = 1.0
                item.transform = CGAffineTransform.identity
            }) { (complete) in
            }
        }
        animateMenu = false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = arrMenuItems?.object(at: section) as! NSDictionary
        let vw = Bundle.main.loadNibNamed("MenuSectionHeader", owner: self, options: nil)?[0] as! UIControl
        vw.tag = section
        vw.addTarget(self, action: #selector(self.MenuAction(_:)), for: .touchUpInside)
        let icon = vw.viewWithTag(11) as? UIImageView
        let title = vw.viewWithTag(12) as? UILabel
        let arrow = vw.viewWithTag(13) as? UIImageView
        if animateMenu {
            icon?.alpha = 0.5
            icon?.transform = CGAffineTransform(translationX: -500, y: 0)
            title?.alpha = 0.5
            title?.transform = CGAffineTransform(translationX: -500, y: 0)
            arrayIcons.append(icon!)
            arrayTitle.append(title!)
        }
        if icon != nil {
            icon!.image = UIImage (named: (data.value(forKey: "image") as? String)!)
        }
        if title != nil {
            title?.text = (data.value(forKey: "title") as? String)!
            ((selectedSection == 999 && section == 0)||(selectedSection == section)) && ((data["subMenu"] as? NSArray) != nil) ? (title?.textColor = DEFAULT_COLOR) : (title?.textColor = UIColor.black)
            (selectedSection == section) || (selectedSection == 999 && section == 0)  ? (title?.font = UIFont(name: FONT_BOLD, size: IS_IPAD() ? 21 : 17)) : (title?.font = UIFont(name: FONT_REGULAR, size: IS_IPAD() ? 20 : 16))
        }
        if arrow != nil{
            (data["subMenu"] as? NSArray) != nil ? (arrow!.isHidden = false) : (arrow!.isHidden = true)
        }
        return vw
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == arrMenuItems!.count - 1 {
            let vw = Bundle.main.loadNibNamed("MenuSectionHeader", owner: self, options: nil)?[2] as! UIControl
            _ = vw.viewWithTag(12) as? UILabel
            //title?.text = "Version : \(UIApplication.versionBuild())"
            return vw
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == ExpandedMenuIndex && arrSubMenuItems.count > 0) ? arrSubMenuItems.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLMenuCell.self), for: indexPath) as! PYLMenuCell
        cell.index = indexPath.row
        cell.datasource = arrSubMenuItems.object(at: indexPath.row) as AnyObject!
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewControllerClass = NSClassFromString(SWIFT_CLASS_STRING((arrSubMenuItems[indexPath.row] as! [String:Any])["class"]! as! String)!)
        
        ExpandedMenuIndex = indexPath.section
        selectedSection = indexPath.section
        //        if (viewControllerClass != nil) {
        //            openStoryboard(arrSubMenuItems[indexPath.row]["storyboard"] as! String)
        //        }
        
        if (viewControllerClass != nil) {
            
            let VC = NSStringFromClass(viewControllerClass)
            if VC == NSStringFromClass(PYLSocialPagesViewController.self)  {
                
                self.slideMenuController()?.closeLeft()
                let storyBoardName = ((arrSubMenuItems[indexPath.row] as! [String:Any])["storyboard"] as! String)
                let viewControllerObj = loadStoryBoardWithName(storyBoardName).instantiateViewController(withIdentifier: String(describing: PYLSocialPagesViewController.self)) as? PYLSocialPagesViewController
                
                if indexPath.row == 0 {
                    // go to Facebook page
                    viewControllerObj!.socialKey = PYLSocialPagesViewController.socialKeyType.kFacebook
                }
                else {
                    //go to instagram
                    viewControllerObj!.socialKey = PYLSocialPagesViewController.socialKeyType.kTwitter
                }
                
                PYLNavigationHelper.helper.navigationController.pushViewController(viewControllerObj!, animated: true)
                
            } else {
                openStoryboard((arrSubMenuItems[indexPath.row] as! [String:Any])["storyboard"] as! String)
            }
        }
        
    }
    
    
    func openStoryboard(_ storyBoard: String!) {
        self.slideMenuController()?.closeLeft()
        if !currentViewController().isKind(of: viewControllerClass) {
            let viewControllerName = String(describing: viewControllerClass!.self)
            self.navigateToViewController(loadStoryBoardWithName(storyBoard).instantiateViewController(withIdentifier: viewControllerName))
            
        }
    }
    
    func navigateToViewController(_ viewController: UIViewController) {
        
        //viewController.title = viewControllerTitle
        var _viewController = viewController
        
        if _viewController.isKind(of: PYLBranchListViewController.self) {
            let vc =  _viewController as! PYLBranchListViewController
            vc.fetchAllBranchList = true
            _viewController = vc
        }
        PYLNavigationHelper.helper.navigationController.pushViewController(_viewController, animated: true)
    }
    
    //MARK: - SlideMenuControllerDelegate methods
    
    func leftWillOpen() {
        debugPrint("left-open")
        removeNoNetworkView()
    }
    
    func leftDidClose() {
        debugPrint("left-close")
        if !PYLHelper.helper.isNetworkOn {
            showNoNetworkView()
        }
    }
    
    //MARK:- Button Actions
    
    @IBAction func MenuAction(_ sender: UIButton) {
        //arrSubMenuItems.removeAllObjects()
        var hasSubMenu = false
        selectedSection = 999
        menuTable.reloadData()
        self.selectedSection = sender.tag
        let data = arrMenuItems?.object(at: sender.tag) as! NSDictionary
        if let subMenus = data["subMenu"] as? NSArray{
            arrSubMenuItems.addObjects(from: subMenus as [AnyObject])
            hasSubMenu = true
        }
        if arrSubMenuItems.count > 0 && isExpanded == false{
            isExpanded = true
            ExpandedMenuIndex = sender.tag
            menuTable.reloadSections(IndexSet(integer: sender.tag), with: .fade)
        }else if arrSubMenuItems.count > 0 && isExpanded == true && hasSubMenu == true{
            
            if ExpandedMenuIndex == sender.tag {
                isExpanded = false
                arrSubMenuItems.removeAllObjects()
                ExpandedMenuIndex = 999
                menuTable.reloadSections(IndexSet(integer: sender.tag), with: .fade)
            }else{
                isExpanded = true
                arrSubMenuItems.removeAllObjects()
                menuTable.reloadSections(IndexSet(integer: ExpandedMenuIndex), with: .fade)
                if let subMenus = data["subMenu"] as? NSArray{
                    arrSubMenuItems.addObjects(from: subMenus as [AnyObject])
                }
                ExpandedMenuIndex = sender.tag
                menuTable.reloadSections(IndexSet(integer: sender.tag), with: .fade)
            }
            
        }else{
            if (((data["loginRequired"] as AnyObject).boolValue) == true) && IS_USER_LOGIN() == false {
                self.slideMenuController()?.closeLeft()
                selectedSection = 999
                self.goToLoginScreen({ (success) in
                    self.menuTable.reloadData()
                    self.viewControllerClass = NSClassFromString(SWIFT_CLASS_STRING((self.arrMenuItems![sender.tag] as! [String : Any])["class"]! as! String)!)
                    if (self.viewControllerClass != nil) {
                        self.openStoryboard((self.arrMenuItems![sender.tag] as! [String : Any])["storyboard"] as! String)
                    }
                })
            }else{
                viewControllerClass = NSClassFromString(SWIFT_CLASS_STRING((arrMenuItems![sender.tag] as! [String:Any])["class"]! as! String)!)
                if (viewControllerClass != nil) {
                    openStoryboard((arrMenuItems![sender.tag] as! [String:Any])["storyboard"] as! String)
                }
            }
        }
    }
    
    @IBAction func onMenu(_ sender: AnyObject) {
        self.slideMenuController()?.closeLeft()
    }
    @IBAction func onMyProfileTapped(_ sender: UIButton!) {
        self.slideMenuController()?.closeLeft()
        //        if !IS_USER_LOGIN() {
        //            self.goToLoginScreen({ (success) in
        //                self.viewControllerClass = NSClassFromString(SWIFT_CLASS_STRING(String(PYLMyProfileViewController) )!)
        //                self.navigateToViewController(mainStoryboard.instantiateViewControllerWithIdentifier(String(self.viewControllerClass)))
        //            })
        
        // }
        //    else{
        //        viewControllerClass = NSClassFromString(SWIFT_CLASS_STRING(String(PYLMyProfileViewController) )!)
        //        if !currentViewController().isKindOfClass(viewControllerClass) {
        //        self.navigateToViewController(mainStoryboard.instantiateViewControllerWithIdentifier(String(viewControllerClass)))
        // }
        // }
    }
    
    @IBAction func onLogoutLogin(_ sender: UIButton) {
        self.slideMenuController()?.closeLeft()
        if !IS_USER_LOGIN() {
            self.goToLoginScreen({ (success) in
                self.arrSubMenuItems.removeAllObjects()
                self.menuTable.reloadData()
            })
        }else{
            let alertController = UIAlertController.showStandardAlertWith("PEYALA", alertText: WANT_TO_LOGOUT, cancelTitle: "NO", doneTitle: "YES", selected_: { (index) in
                if (index == 1) {
                    PYLAPIHandler.handler.logout({ (response) in
                    
                        switch (response?["ResponseCode"].stringValue)! {
                        case "200":
                                self.selectedSection = 999
                                //self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                                REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
                                REMOVE_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY)
                                PYLHelper.helper.userModelObj = nil
                                SET_NOTIFICATION_BADGE("\(0)")
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                self.arrSubMenuItems.removeAllObjects()
                                self.menuTable.reloadData()
                                
                                if PYLNavigationHelper.helper.navigationController!.topViewController!.className.contains(String(describing: PYLDashBoardViewController.self)) {
                                    let viewControllerr = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLDashBoardViewController.self))
                                    PYLNavigationHelper.helper.navigationController?.pushViewController(viewControllerr, animated: true)
                                    return
                                }
                                //end change
                                self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLDashBoardViewController.self))
                 
                        case "201":
                            self.logOutForSessionTokenMismatch()
                        // MARK: Navigation flow is not perfect during log out in that case. this condition should be under Case "202":
                            
                        default :
                            self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                            
                        }

                        
                        }, failure: { (error) in
                            
                    })
                }
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

//extension String {
//    func capitalizingFirstLetter() -> String {
//        let first = String(characters.prefix(1)).capitalized
//        let other = String(characters.dropFirst())
//        return first + other
//    }
//    
//    mutating func capitalizeFirstLetter() {
//        self = self.capitalizingFirstLetter()
//    }
//}
//extension PYLMenuViewController : String {
//    func capitalizingFirstLetter() -> String {
//                let first = String(characters.prefix(1)).capitalized
//                let other = String(characters.dropFirst())
//                return first + other
//            }
//        
//            mutating func capitalizeFirstLetter() {
//                self = self.capitalizingFirstLetter()
//            }
//    
//}

