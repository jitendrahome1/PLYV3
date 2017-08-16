//
//  PYLOrderDetailsViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLOrderDetailsViewController: PYLBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK:- OutletConnections
    
    @IBOutlet weak var tableOrderDetail: UITableView!
    var dicPrice = ["Total Price" : "4500","Vat" : "100","Total Bill" : "4500","Peyala Cash Used" : "0","Grand Total" : "0","Order Type":""]
    var dicAddress = ["Delivery Date" : "not available","Address" : "not available","Location" : "not available","Landmark":"not available","Pincode" : "not available","Phone No" : "not available"]
    var dicDeliveryPersonInfo = [String:AnyObject]()//["Name":"","Phone No":"","Delivery Time":""]
    
    var arrPriceKeys = ["Total Price","Vat","Total Bill","Peyala Cash Used","Grand Total","Order Type"]
    var arrAdressKeys = ["Delivery Date","Address","Location","Landmark","Pincode","Phone No"]
    var arrDeliveryPersonInfoKeys = ["Name","Phone No","Delivery Time"]
    var orderDetails = [String : AnyObject!]()
    var orderID = ""
    
    var arrComboOrders = [AnyObject]()
    var arrNormalOrders = [Any]()
    var arrExpandedComboItems = [Any]()
    var arrTotalItems = [AnyObject]()
    var VATPERCENTAGE = "0.0"
    var CardType = ""
    
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        self.callMyOrderDetailsApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(ORDER_DETAILS_SCREEN, isGoogle: true, isFB: true)
    }
    
    //Mark: API Calling
    func callMyOrderDetailsApi() {
        
        PYLAPIHandler.handler.getOrderDetailsbyID(orderID, success: { (response) in
            
            self.offlineOrSuccessResponseHandleGetMyOrderDetailsApi(response: response!)
            
        }, offlineBlock: { (response) in
            self.offlineOrSuccessResponseHandleGetMyOrderDetailsApi(response: response!)
            
        }) { (error) in
            
        }
    }
    
    func offlineOrSuccessResponseHandleGetMyOrderDetailsApi(response: JSON) {
        
        switch (response["ResponseCode"].stringValue) {
        case "200":
            self.successTaskMyOrderDetails(response: response)
        case CODE_SESSION_TOKEN_MISMATCH:
            self.logOutForSessionTokenMismatch()
        case CODE_INACTIVE_USER:
            self.inactiveUserAction(withMessage: response["Responsedetails"].stringValue)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    func successTaskMyOrderDetails(response: JSON) {
        
        //debugPrint("response is \(response)")
        if ((response["order_details"]).arrayObject?.count)! > 0 {
            orderDetails = ((response["order_details"]).arrayObject![0] as? [String:AnyObject])!
            feedAllData()
        }
    }
    
    //FeedAllDataDictionaries
    func feedAllData() {
        dicPrice["Order Type"] = (orderDetails["order_type"] as! String).getAESDecryption().replacingOccurrences(of: "_", with: " ")
        
        arrComboOrders = (orderDetails["combo_details"]! as! NSArray) as [AnyObject]
        arrNormalOrders = (orderDetails["food_items"]! as! NSArray) as [AnyObject]
        arrTotalItems = (arrComboOrders as [AnyObject]) + (arrNormalOrders as [AnyObject])
        calculatePriceAndSummary()
        feedAddress()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.tableOrderDetail.reloadData()
        }
    }
    
    func calculatePriceAndSummary() {
        
        let totalTax = (orderDetails["total_tax"] as! String).getAESDecryption().isEmpty ? 0.0 : (orderDetails["total_tax"] as! String).getAESDecryption().toDouble()
        //let totalPrice = (orderDetails["total_price"] as! String).getAESDecryption().isEmpty ? 0.0 : (orderDetails["total_price"] as! String).getAESDecryption().toDouble()
        let totalPrice = (orderDetails["exact_order_price"] as! String).getAESDecryption().isEmpty ? 0.0 : (orderDetails["exact_order_price"] as! String).getAESDecryption().toDouble()
        
        let loyaltyCash = (orderDetails["order_redeem_loyalty_cash"] as! String).getAESDecryption().isEmpty ? 0.0 : (orderDetails["order_redeem_loyalty_cash"] as! String).getAESDecryption().toDouble()
        
        dicPrice["Total Price"] = "\(totalPrice!-totalTax!) Taka"
        dicPrice["Vat"] = "\(totalTax!) Taka"
        
        let priceWithRoundOffValue = (orderDetails["total_price"] as! String).getAESDecryption().isEmpty ? 0.0 : (orderDetails["total_price"] as! String).getAESDecryption().toDouble()
        //dicPrice["Total Bill"] = "\(totalPrice!)".toStringWithRoundOfUpToTwoDecimal()! + " Taka"
        dicPrice["Total Bill"] = "\(priceWithRoundOffValue!)".toStringWithRoundOfUpToTwoDecimal()! + " Taka"
        
        CardType = (orderDetails["card_type"] as! String).getAESDecryption()
        
        //dicPrice["Grand Total"] = "\(totalPrice!-loyaltyCash!)".toStringWithRoundOfUpToTwoDecimal()! + " Taka"
        dicPrice["Grand Total"] = "\(priceWithRoundOffValue!-loyaltyCash!)".toStringWithRoundOfUpToTwoDecimal()! + " Taka"
        dicPrice["Peyala Cash Used"] = "\(loyaltyCash!)".toStringWithRoundOfUpToTwoDecimal()! + " Taka"
        VATPERCENTAGE = "\((totalTax!/(totalPrice!-totalTax!))*100)".toStringWithRoundOfUpToTwoDecimal()!
    }
    
    func feedAddress() {
        
        if (orderDetails["order_type"] as! String).getAESDecryption() == DeliveryOption.Delivery.rawValue {
            
            if let address = orderDetails["delivery_address"]!["addressLine1"] as? String{
                dicAddress["Address"] = address.getAESDecryption()
            }
            if let Location = orderDetails["delivery_address"]!["addressLine2"] as? String{
                dicAddress["Location"] = Location.getAESDecryption()
            }
            if let LandMark = orderDetails["delivery_address"]!["landMark"] as? String{
                dicAddress["Landmark"] = LandMark.getAESDecryption()
            }
            if let Pincode = orderDetails["delivery_address"]!["pincode"] as? String{
                dicAddress["Pincode"] = Pincode.getAESDecryption()
            }
            if let PhoneNo = orderDetails["delivery_address"]!["phoneNo"] as? String{
                dicAddress["Phone No"] = PhoneNo.getAESDecryption()
            }
            if let description = orderDetails["order_date"] as? String {
                dicAddress["Delivery Date"] = description.getAESDecryption()
            } else {
                dicAddress["Delivery Date"] = "N/A"
            }
            
        } else {
            
            if let PhoneNo = orderDetails["phoneNo"] as? String{
                dicPrice["Phone No"] = PhoneNo.getAESDecryption()
                arrPriceKeys.append("Phone No")
            }
            arrAdressKeys.removeAll()
            arrDeliveryPersonInfoKeys.removeAll()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Defined Function
    
    func setupUI() {
        tableOrderDetail.estimatedRowHeight = 100
        tableOrderDetail.rowHeight = UITableViewAutomaticDimension
        //feedAllData()
    }
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        
        self.title = "ORDER DETAILS"
    }
    
    // MARK: - Table View DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        guard orderDetails.count > 0 else { return 0 }
        
        switch section {
        case 0:
            return arrTotalItems.count
        case 1:
            return arrPriceKeys.count
        case 2:
            return arrAdressKeys.count
        case 3:
            return arrDeliveryPersonInfoKeys.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard orderDetails.count > 0 else { return 0 }
        return 3;
        //MARK: Phase 2 return 4
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLOrderDetailsCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLOrderDetailsCell.self)) as! PYLOrderDetailsCell
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLOrderDetailsCell.self) + "KeyValue") as! PYLOrderDetailsCell
        }
         cell.configureCell()
        switch indexPath.section {
        case 0:
           
            cell.datasource = arrTotalItems[indexPath.row]
            cell.comboDetails = {combos in
                debugPrint(combos)
                PYLComboDetailsPopUp.showComboDetailsPopUp(self, comboItems:combos, dissmiss: {
                    
                })
            }
            break
            
        case 1:
            let key = arrPriceKeys[indexPath.row]
            if let value = dicPrice[key]{
                cell.vatPercentage = VATPERCENTAGE
                cell.cardType = CardType
                cell.datasource = ["\(key)":"\(value)"] as AnyObject
            }else{
                cell.datasource = ["\(key)":""] as AnyObject
            }
            break
            
        case 2:
            let key = arrAdressKeys[indexPath.row]
            if let value = dicAddress[key]{
                cell.datasource = ["\(key)":"\(value)"] as AnyObject
            }else{
                cell.datasource = ["\(key)":""] as AnyObject
            }
            break
            
        case 3:
            let key = arrDeliveryPersonInfoKeys[indexPath.row]
            if let value = dicDeliveryPersonInfo[key]{
                cell.datasource = ["\(key)":"\(value)"] as AnyObject
            }else{
                cell.datasource = ["\(key)":""] as AnyObject
            }
            break
            
        default:
            cell.datasource = nil
            break
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PYLOrderDetailsCell
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.2) { 
            cell.alpha = 1.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
     let vw = getViewFromNib("PYLMyOrderHeader", tag: section + 1, owner: self)
        let button = vw.viewWithTag(11) as? UIButton!
        let labelTitle = vw.viewWithTag(12) as? UILabel!
        if button != nil {
            if section == 0 {
                button!.addTarget(self, action: #selector(onReorderTapped), for: .touchUpInside)
                labelTitle!.text = labelTitle!.text! + ": " + "\((orderDetails["order_id"] as! String).getAESDecryption())"
                
            }else if section == 1 {
                button!.addTarget(self, action: #selector(onTrackOrderTapped), for: .touchUpInside)
            }
        }
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section ==  2 || section ==  3) && (orderDetails["order_type"] as! String).getAESDecryption() != DeliveryOption.Delivery.rawValue {
            return 0.0
        }
        return IS_IPAD() ? 70.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    
    //MARK:- Actions
    
    @IBAction func onReorderTapped(_ sender: AnyObject) {

        trackButtonTapEventsForAnalytics(actionName: REORDER_EVENT, tapsRequired: "1")
        PYLAPIHandler.handler.reOrder((orderDetails["order_id"] as! String).getAESDecryption(), success: { (response) in
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLMyCartViewController.self)) as! PYLMyCartViewController
            self.removeViewControllerFromNavigationStack(String(describing: viewController))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }) { (error) in
            
        }
    }
    
    @IBAction func onTrackOrderTapped(_ sender: AnyObject) {

        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLTrackOrderViewController.self)) as! PYLTrackOrderViewController
        viewController.orderID = (orderDetails["order_id"] as! String).getAESDecryption()
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
}
