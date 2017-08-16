//
//  PYLMyOrderViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLMyOrderViewController: PYLBaseViewController,UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet Connections
    @IBOutlet weak var tableMyOrder: UITableView!

    var myOrderListArray = [AnyObject]()
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        tableMyOrder.defaultSetup()
        self.callMyOrderListApi()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(MY_ORDERS_SCREEN, isGoogle: true, isFB: true)
    }
    
    //MARK: - API Section
    func callMyOrderListApi() {
        PYLAPIHandler.handler.getMyOrderList({ (response) in
            //            switch (response["ResponseCode"].stringValue) {
            //            case "200":
            //                self.successTaskMyOrderList(response)
            //            case CODE_SESSION_TOKEN_MISMATCH:
            //                self.logOutForSessionTokenMismatch()
            //            case CODE_INACTIVE_USER:
            //                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //            }
            self.offlineOrSuccessResponseHandleMyOrderListApi(response!)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleMyOrderListApi(response!)
            }, failure: { (error) in
        })
    }
    
    //MARK: - Fetch Value From API
    func offlineOrSuccessResponseHandleMyOrderListApi(_ response: JSON) {
        switch (response["ResponseCode"].stringValue) {
        case "200":
            self.successTaskMyOrderList(response)
        case CODE_SESSION_TOKEN_MISMATCH:
            self.logOutForSessionTokenMismatch()
        case CODE_INACTIVE_USER:
            self.inactiveUserAction(withMessage: response["Responsedetails"].stringValue)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    func successTaskMyOrderList(_ response: JSON) {
        debugPrint(response)
        let responseDict =  response.dictionaryObject!
        self.myOrderListArray  = responseDict["order_details"] as! [AnyObject]
        PYLHelper.helper.userModelObj!.loyaltycash = response["loyalty_cash"].stringValue.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        self.myOrderListArray = self.myOrderListArray.reversed()
        if self.myOrderListArray.count > 0{
            self.tableMyOrder.reloadData()
        }else{
            self.view.showToastWithMessage(NO_RESULT_FOUND)
            self.tableMyOrder.showNodataLabelWithText(nil)
        }
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.title = "MY ORDERS"
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func reOrderSuccess() {
        //        self.pushToViewController(utilityStoryboard, viewController: String(PYLPaymentViewController))
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLMyCartViewController.self)) as! PYLMyCartViewController
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Table View DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myOrderListArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLMyOrderCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLMyOrderCell.self)) as! PYLMyOrderCell
        cell.datasource = myOrderListArray[indexPath.row] 
        cell.reorderCompletion = { (orderID) in
            //debugPrint(orderID.getAESDecryption())
            PYLAPIHandler.handler.reOrder(orderID.getAESDecryption(), success: { (response) in
                self.reOrderSuccess()
                }, failure: { (error) in
                    
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getViewFromNib("PYLMyOrderHeader", tag: 0, owner: self)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return IS_IPAD() ? 70.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    
    
    // MARK: - Table View Delegates Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderDetailsViewController.self)) as! PYLOrderDetailsViewController
        //viewController.orderDetails = myOrderListArray[indexPath.row] as! [String : AnyObject?]
        viewController.orderID = (myOrderListArray[indexPath.row]["order_id"] as! String).getAESDecryption()
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
    
    
}
