//
//  PYLMyPeyalaCashViewController.swift
//  Peyala
//
//  Created by sweta on 01/11/16.
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


class PYLMyPeyalaCashViewController: PYLBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableMyCash: UITableView!
   // @IBOutlet weak var upperView: UIView!
   // @IBOutlet weak var conversionLabel: UILabel!
    //@IBOutlet weak var peyalaCashLabel: UILabel!
    
    var orderDetailsArray = [AnyObject]()
    var loyalty_point: String = ""
    var loyalty_cash: String = ""
    var purchase_amount: String = ""
    var selectedOrderId: String = ""
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        self.tableMyCash.dataSource = nil
        self.tableMyCash.delegate = nil
        self.tableMyCash.tag = peyalaCashTableViewTag
       // upperView.layer.cornerRadius = 5.0
       // upperView.layer.borderColor = UIColor.lightGray.cgColor
       // upperView.layer.borderWidth = 0.5
       // upperView.layer.masksToBounds = true
        getPeyalaCashHistory()
        
         self.tableMyCash.estimatedRowHeight = 110
        self.tableMyCash.rowHeight = UITableViewAutomaticDimension
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(MY_PEYALA_CASH_SCREEN, isGoogle: true, isFB: true)
    }
    
    func setUpperNavigationItems() {
        
        self.title = "MY PEYALA CASH"
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    //MARK: - User Defined Function
  
    // Jitu Close
    
//    func updateUI() {
//        conversionLabel.text = "Earn 100 PEYALA Cash on every \(purchase_amount) taka purchase of Redeem on the next or after & Enjoy!"
//        
//        let loyaltyPoint = Double(loyalty_point)
////        if loyalty_point.length > 0 {
//        if loyaltyPoint > 0.0 {
//            peyalaCashLabel.text = "You have \(loyalty_point) points i.e. \(loyalty_cash) Peyala Cash"
//        } else {
//            peyalaCashLabel.text = "You don't have any PEYALA Cash right now."
//        }
//    }
    
    // Jitu end
    
    func goToOrderDetails(_ indexNo: Int) {

        selectedOrderId = (((orderDetailsArray[indexNo] as? [String:AnyObject])!["order_id"]) as? String)!.getAESDecryption()
        self.navigateToOrderDetailsWithOrder(selectedOrderId)
    }
    
    func navigateToOrderDetailsWithOrder(_ orderID:String) {
        
        let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderDetailsViewController.self)) as! PYLOrderDetailsViewController
        viewController.orderID = orderID
        PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
    }
    
    //MARK: - API Call
    func getPeyalaCashHistory() {
        
        PYLAPIHandler.handler.requestMyPeyalaCash({ (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                
                self.loyalty_point = (((response?.dictionaryObject!["loyalty_point"] as? String)!).getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
                self.loyalty_cash = (((response?.dictionaryObject!["loyalty_cash"] as? String)!).getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
                self.purchase_amount = ((response?.dictionaryObject!["purchase_amount"] as? String)!).getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!
                
                //set user-peyalaCash in app global var for user.
                PYLHelper.helper.userModelObj!.loyaltycash = self.loyalty_cash
                SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
                
                //self.updateUI()
                
                self.orderDetailsArray = (response!.dictionaryObject!["order_details"] as? [[String:AnyObject]])! as [AnyObject]
                self.orderDetailsArray = self.orderDetailsArray.filter { (($0["order_redeem_loyalty_cash"] as? String)!.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!.toDouble() > 0) || (($0["loyalty_cash"] as? String)!.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!.toDouble() > 0) }
                
//                self.tableMyCash.hideNoDataLabel()
//                guard self.orderDetailsArray.count > 0 else {
//                    self.tableMyCash.showNodataLabelWithText("No history found")
//                    return
//                }
//                if self.orderDetailsArray.count == 0 {
//                    self.tableMyCash.showNodataLabelWithText("No history found")
//                }
                
                self.tableMyCash.dataSource = self
                self.tableMyCash.delegate = self
                self.tableMyCash.reloadData()
                
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
    
    //MARK: - Table View DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int{
        if orderDetailsArray.count > 0 {
            return 3
        }
        else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }else {
           return orderDetailsArray.count;
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellReuseIdentifier = "PYLMyPeyalaEarnCashCell"
        var cell: PYLBaseTableViewCell?
        if indexPath.section == 0 {
            cell  = tableMyCash.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLMyPeyalaEarnCashCell
            (cell as! PYLMyPeyalaEarnCashCell).lblTakaAmount.text = purchase_amount
            let _loyaltyPoint = Double(loyalty_point)
            if _loyaltyPoint > 0.0 {
                (cell as! PYLMyPeyalaEarnCashCell).lblPointBalAmount.text = loyalty_point
                (cell as! PYLMyPeyalaEarnCashCell).labelPeyalaCashValueAsPerPoint.text = loyalty_cash
            } else {
                (cell as! PYLMyPeyalaEarnCashCell).lblPointBalAmount.text = "0"
                (cell as! PYLMyPeyalaEarnCashCell).labelPeyalaCashValueAsPerPoint.text = "0"
                //peyalaCashLabel.text = "You don't have any PEYALA Cash right now."
            }
        }
        else if indexPath.section == 1 {
            cell  = tableMyCash.dequeueReusableCell(withIdentifier: "disclaimerCell")! as? PeyalaCashDisclaimerTableViewCell
        }
        else {
            cellReuseIdentifier = "PYLCashHistory"
            cell  = tableMyCash.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PeyalaCashHistoryTableViewCell
            cell?.datasource = orderDetailsArray[indexPath.row] as? [String:AnyObject] as AnyObject
            (cell as! PeyalaCashHistoryTableViewCell).buttonViewDetails.tag = indexPath.row
            (cell as! PeyalaCashHistoryTableViewCell).viewDetailsButtonBlock = { [weak self] (index) in
                self?.goToOrderDetails(index)
            }
            (cell as! PeyalaCashHistoryTableViewCell).labelSeparator.isHidden = false
            let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
            if (indexPath.row == lastRowIndex - 1) {
                (cell as! PeyalaCashHistoryTableViewCell).labelSeparator.isHidden = true
            }
        }
        
       
        
//        let cellReuseIdentifier = "PYLCashCell"
//        
//         let cell:PYLPaymentTableViewCell  = tableMyCash.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentTableViewCell
        
        
        /*
        
        let orderDetails = orderDetailsArray[indexPath.row] as? [String:AnyObject]
        let cell:PYLPaymentTableViewCell  = tableMyCash.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentTableViewCell
           //jitucell.constraintReceivedPointsHeight.constant = 0
          //jitu cell.constraintUsedPointHeight.constant = 0
        cell.layoutIfNeeded()
        cell.orderIdLabel.text = "Order ID: \((((orderDetails)!["order_id"]) as? String)!.getAESDecryption())"
        //cell.rewardLabel.text = "i.e. \(((((orderDetailsArray[indexPath.row] as? [String:AnyObject])!["loyalty_cash"]) as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!) Taka"
        //cell.radeemAmount.text = "Peyala Cash: \(((((orderDetailsArray[indexPath.row] as? [String:AnyObject])!["loyalty_point"]) as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!) points"
        cell.viewDetailsButton.tag = indexPath.row
        cell.viewDetailsButton.addTarget(self, action: #selector(PYLMyPeyalaCashViewController.goToOrderDetails(_:)), for: .touchUpInside)
        let usedCash = ((((orderDetails)!["order_redeem_loyalty_cash"]) as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
        let receivedCash = ((((orderDetails)!["loyalty_cash"]) as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
        if usedCash.toDouble() > 0{
             //jitu  cell.constraintUsedPointHeight.constant = 30
            cell.labelUsedPoints.text = "PEYALA cash used : " + usedCash + " Taka"
        }
        if receivedCash.toDouble() > 0{
              //jitu cell.constraintReceivedPointsHeight.constant = 30
            cell.labelReceivedPoints.text = "PEYALA cash received : " + receivedCash + " Taka"
        }
        
        
         //cell.labelAvailablePoints.text = "Available: " + ((((orderDetailsArray[indexPath.row] as? [String:AnyObject])!["loyalty_cash"]) as? String)!.getAESDecryption()).toStringWithRoundOfUpToTwoDecimal()!
        
        cell.labelSeperator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
        if (indexPath.row == lastRowIndex - 1) {
            cell.labelSeperator.isHidden = true
        }
        
 */
        return cell!
    }
    
    //MARK: - Table View Delegate Methods
    //@nonobjc
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = Bundle.main.loadNibNamed("PYLMyOrderHeader", owner: self, options: nil)?[0] as! UIView
        let labelTitle = vw.viewWithTag(12) as? UILabel!
        labelTitle!.text = "PEYALA Cash History"
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 1 {
            return 0.0
        }
        else  {
            guard (orderDetailsArray.count > 0 )else{
                return 0
            }
            return IS_IPAD() ? 70.0 : 50.0
        }
     
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0{
        return IS_IPAD() ? 420 :  SCREEN_WIDTH * 0.69
    }
    else{
         return UITableViewAutomaticDimension
    }
    }
    
}
