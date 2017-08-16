//
//  PYLNearbyBranchPopupViewController.swift
//  Peyala
//
//  Created by Adarsh on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLNearbyBranchPopupViewController: PYLBasePopUpViewController {
    
    //    var arrBranches:[Dictionary<String,AnyObject>] = []
    var branchListWitCountryArray = [AnyObject]()
    var selectedBranch:[String:AnyObject]!
    var dismissPopupAction:(()->())!
    var chosenBranchAction:((_ selectedBranch:[String:AnyObject])->())!
    var sourceViewController: UIViewController?
    var orderType : OrderType!
    enum OrderType {
        case kDineIn
        case kTakeAway
        case kDelivery
    }
    
    @IBOutlet weak var tableViewBranchList: UITableView!
    @IBOutlet weak var buttonCross: UIButton!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var viewCenter: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //callBranchApi()
        if PYLHelper.helper.branchAsPerServiceType.count > 0 {
            branchListWitCountryArray = PYLHelper.helper.branchAsPerServiceType
            if self.branchListWitCountryArray.count > 0 {
                for i in 0..<branchListWitCountryArray.count {
                    var branchDict:[String: AnyObject] = self.branchListWitCountryArray[i] as! [String : AnyObject]
                    branchDict["checked"] = "0" as AnyObject?
                    self.branchListWitCountryArray[i] = branchDict as AnyObject
                }
                self.tableViewBranchList.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableViewBranchList.reloadData()
        buttonCross.center = CGPoint(x: viewCenter.frame.maxX, y: viewCenter.frame.minY)
        var frame: CGRect
        frame = buttonCross.frame
        frame.origin.x = frame.origin.x - popupRedCrossButtonPadding
        frame.origin.y = frame.origin.y + popupRedCrossButtonPadding
        buttonCross.frame = frame
    }
    
    func setupUI() {
        tableViewBranchList.estimatedRowHeight = IS_IPAD() ? 93 : 50
        tableViewBranchList.rowHeight = UITableViewAutomaticDimension
    }
    
    internal class func showNearbyBranchController(_ sourceViewController: UIViewController,orderType:OrderType, selected:@escaping ([String:AnyObject])->(), dismiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLNearbyBranchPopupViewController.self)) as! PYLNearbyBranchPopupViewController
        viewController.sourceViewController = sourceViewController
        viewController.chosenBranchAction = selected
        viewController.dismissPopupAction = dismiss
        viewController.orderType = orderType
        viewController.presentNearbyBranchControllerWith(sourceViewController)
    }
    
    func presentNearbyBranchControllerWith(_ sourceController: UIViewController)  {
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        switch orderType! {
        case .kDineIn:
            labelSubTitle.text = "and Dine-in"
        case .kDelivery:
            labelSubTitle.text = "and Delivery"
        case .kTakeAway:
            labelSubTitle.text = "and Takeaway"
        
        }
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimate(_ Closed:Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if Closed == true{
                if self.dismissPopupAction != nil {
                    self.dismissPopupAction()
                }
            }else{
                if self.chosenBranchAction != nil {
                    self.chosenBranchAction(self.selectedBranch)
                }
            }
        }) 
    }
    
    //MARK:  Button Actions
    @IBAction func chooseBranchButtonAction(_ sender: AnyObject) {
        
        let arrTempSelectedBranch = branchListWitCountryArray.filter({ (dict) -> Bool in
            let checked = dict["checked"] as! String
            if checked == "1" {
                return true
            } else{
                return false
            }
        })
        
        guard arrTempSelectedBranch.count > 0 else {
            self.view.showToastWithMessage(SELECT_ANY_BRANCH)
            return
        }
        
        PYLHelper.helper.placeOrderObj!.branchID = ((arrTempSelectedBranch[0] as! [String:AnyObject])["branch_id"] as! String).getAESDecryption()
        selectedBranch = arrTempSelectedBranch[0] as! [String:AnyObject]
        dismissAnimate(false)
        
    }
    
    @IBAction func bgButtonAction(_ sender: AnyObject) {
        dismissAnimate(true)
      
    }
    
    @IBAction func crossButtonAction(_ sender: AnyObject) {
        dismissAnimate(true)
    }
}

extension PYLNearbyBranchPopupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  branchListWitCountryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewBranchList.dequeueReusableCell(withIdentifier: String(describing: PYLNearbyBranchCollectionCell.self), for: indexPath) as! PYLNearbyBranchCollectionCell
        cell.datasource = branchListWitCountryArray[indexPath.row]
        cell.checkUncheckAction = {(checkStatus) in
            
            for i in 0..<self.branchListWitCountryArray.count {
                var branchDict:[String: AnyObject] = self.branchListWitCountryArray[i] as! [String : AnyObject]
                branchDict["checked"] = (i == indexPath.row) ? "1" as AnyObject? : "0" as AnyObject?
                self.branchListWitCountryArray[i] = branchDict as AnyObject
            }
            tableView.reloadData()
            //            var dict:[String: AnyObject] = self.branchListWitCountryArray[indexPath.row] as! [String : AnyObject] //self.arrBranches[indexPath.row]
            //            dict["checked"] = checkStatus
            //            self.branchListWitCountryArray[indexPath.row] = dict
        }
        return cell
    }
}
