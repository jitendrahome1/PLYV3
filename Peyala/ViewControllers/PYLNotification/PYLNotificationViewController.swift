//
//  PYLNotificationViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLNotificationViewController: PYLBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlet Collection
    
    @IBOutlet weak var notificationTable: UITableView!
    
    var arrData:[Dictionary<String,String>] = []
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        notificationTable.defaultSetup()
        notificationTable.estimatedRowHeight = 100
        
        notificationTable.dataSource = nil
        notificationTable.delegate = nil
        self.callNotificationListApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //notificationTable.dataSource = nil
        //notificationTable.delegate = nil
        SET_NOTIFICATION_BADGE("\(0)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        //self.callNotificationListApi()
        trackScreenForAnalyticsWithName(NOTIFICATIONS_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        notificationTable.dataSource = self
        notificationTable.delegate = self
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.searchButtonEnabled = false
        self.menuButtonEnabled = false
        self.notificationButtonEnabled = false
        self.backButtonEnabled = true
        self.cartButtonEnabled = true
        self.title = "NOTIFICATION"
    }
    
    func setupNoData() {
        arrData = []
        notificationTable.reloadData()
        notificationTable.showNodataLabelWithText(NO_ITEMS_CART)
    }
    
    //MARK: - API section
    
    func callNotificationListApi()
    {
        PYLAPIHandler.handler.getNotificationList({ (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskNotificationListApi(response!)
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            
        }
    }
    
    func callReadNotificationApi(_ notificationID: String, success:@escaping ()->())
    {
        PYLAPIHandler.handler.notificationRead(notificationID: notificationID, success: { (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                let title = response?["Responsedetails"].stringValue
                if title != "success" {
                    self.view.showToastWithMessage((response?["Responsedetails"].stringValue)!)
                }
                SET_NOTIFICATION_BADGE(response!["notification_unread_count"].stringValue)
                success()
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            
        }
    }
    
    func successTaskNotificationListApi(_ response: JSON) {
        let tempArr = response["notification_details"].array
        notificationTable.hideNoDataLabel()
        guard (tempArr?.count)! > 0 else {
            notificationTable.showNodataLabelWithText("No notification available")
            return
        }
        for i in 0..<tempArr!.count {
            var dict = Dictionary<String,String>()
            dict["notification_desc"] = tempArr![i]["notification_desc"].stringValue.getAESDecryption()
            dict["notification_id"] = tempArr![i]["notification_id"].stringValue.getAESDecryption()
            dict["notification_read_status"] = tempArr![i]["notification_read_status"].stringValue.getAESDecryption()
            dict["notification_time"] = tempArr![i]["notification_date"].stringValue.getAESDecryption()
            //dict["notification_title"] = tempArr![i]["notification_title"].stringValue.getAESDecryption()
            dict["OrderId"] = tempArr![i]["OrderId"].stringValue.getAESDecryption()
            arrData.append(dict)
        }
        arrData.sort { ($0["notification_time"])!.stringToDateWithCustomFormat("dd-MM-yyyy").compare(($1["notification_time"])!.stringToDateWithCustomFormat("dd-MM-yyyy")) == .orderedDescending
        }
        
        notificationTable.dataSource = self
        notificationTable.delegate = self
        notificationTable.reloadData()
    }
    // MARK: - Table View DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLNotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLNotificationTableViewCell.self)) as! PYLNotificationTableViewCell
        cell.datasource = arrData[indexPath.row] as AnyObject!
        cell.labelSeparator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
        if (indexPath.row == lastRowIndex - 1) {
            cell.labelSeparator.isHidden = true
        }
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let orderID = arrData[indexPath.row]["OrderId"]!
        if orderID.characters.count > 0 {
            let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderDetailsViewController.self)) as! PYLOrderDetailsViewController
            viewController.orderID = orderID
            PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
        }
    }
}


public func ==(lhs: Date, rhs: Date) -> Bool {
    if lhs.dayOfTheWeek() == rhs.dayOfTheWeek(){
        return true
    }
    return false
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}
