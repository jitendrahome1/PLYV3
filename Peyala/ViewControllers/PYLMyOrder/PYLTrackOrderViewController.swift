//
//  PYLTrackOrderViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLTrackOrderViewController: PYLBaseViewController, UITableViewDelegate,UITableViewDataSource {
    
    enum orderType {
        case kDineIn
        case kTakeAway
        case kDelivery
    }
    
    enum paymentType {
        case kCOD
        case kOnline
        case kWallet
    }
    //ORDER_RECEIVED,PAYMENT_RECEIVED,ORDER_READY,SERVED,DELIVERED
    let OUT_FOR_DELIVERY    = "OUT_FOR_DELIVERY"
    let DELIVERED           = "DELIVERED"
    let SERVED              = "SERVED"
    let PAYMENT_AWAITING    = "PAYMENT_AWAITING"
    let ORDER_READY         = "ORDER_READY"
    let ORDER_RECIEVED      = "ORDER_RECEIVED"
    let PAYMENT_RECEIVED    = "PAYMENT_RECEIVED"
    
    //MARK:- Outlet Connections
    
    @IBOutlet weak var tableTrackOrder: UITableView!
    var orderID : String!
    var arrOrderItems = [AnyObject]()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        self.setUpperNavigationItems()
        super.viewDidLoad()
        tableTrackOrder.defaultSetup()
        
        var statusDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "OrderStatus", ofType: "plist") {
            statusDictionary = NSDictionary(contentsOfFile: path)
        }
        
        let OrderItems = (statusDictionary!.value(forKey: "OrderStatus") as! NSArray)
        arrOrderItems.append(contentsOf: OrderItems as [AnyObject])
        debugPrint(arrOrderItems)
        callGetOrderStatusApi(orderID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(TRACK_ORDER_SCREEN, isGoogle: true, isFB: true)
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.title = "TRACK YOUR ORDER"
    }
    
    func getOrderedTrackingArray(_ orderType: PYLTrackOrderViewController.orderType, paymentType: PYLTrackOrderViewController.paymentType) -> [String] {
        //ORDER_RECEIVED,PAYMENT_RECEIVED,ORDER_READY,SERVED,DELIVERED
        var tempArr = [String]()
        switch paymentType {
        case .kCOD:
            switch orderType {
            case .kDineIn,.kTakeAway:
                tempArr = [ORDER_RECIEVED,ORDER_READY,OUT_FOR_DELIVERY,SERVED,PAYMENT_RECEIVED]
                break
            case .kDelivery:
                tempArr = [ORDER_RECIEVED,ORDER_READY,OUT_FOR_DELIVERY,DELIVERED,PAYMENT_RECEIVED]

                break
            }
            break
        case .kOnline:
            switch orderType {
            case .kDineIn,.kTakeAway:
                tempArr = [ORDER_RECIEVED,PAYMENT_RECEIVED,ORDER_READY,OUT_FOR_DELIVERY,SERVED]
                break
            case .kDelivery:
                tempArr = [ORDER_RECIEVED,PAYMENT_RECEIVED,ORDER_READY,OUT_FOR_DELIVERY,DELIVERED]
                break
            }
            break
            
        default:
            switch orderType {
            case .kDineIn,.kTakeAway:
                tempArr = [ORDER_RECIEVED,PAYMENT_RECEIVED,ORDER_READY,OUT_FOR_DELIVERY,SERVED]
                break
            case .kDelivery:
                tempArr = [ORDER_RECIEVED,PAYMENT_RECEIVED,ORDER_READY,OUT_FOR_DELIVERY,DELIVERED]
                break
            }
            break
        }
        return tempArr
    }
    
    // MARK: - Table View DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrderItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
         let cell = cell as! PYLOrderStatusCell
         cell.imageOrderStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
         cell.labelImageTail.alpha = 0.0
         cell.labelOrderStatus.alpha = 0.0
        UIView.animate(withDuration: 0.25, delay: (Double(indexPath.row)/10), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.01, options: .curveLinear, animations: {
            cell.imageOrderStatus.transform = CGAffineTransform.identity
            cell.labelImageTail.alpha = 1.0
            cell.labelOrderStatus.alpha = 1.0
        }) { (complete) in
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLOrderStatusCell
        cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLOrderStatusCell.self) + "Demo") as! PYLOrderStatusCell
        cell.datasource = arrOrderItems[indexPath.row] as AnyObject!
        
        if indexPath.row == 0 {
            cell.labelImageTail.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = Bundle.main.loadNibNamed("PYLMyOrderHeader", owner: self, options: nil)?[4] as! UIView
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return IS_IPAD() ? 70.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    //MARK: Api Section
    
    func callGetOrderStatusApi(_ orderId:String) {
        tableTrackOrder.isHidden = true
        PYLAPIHandler.handler.checkOrderStatus(orderId, success: { (response) in
            debugPrint(response ?? "")
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                 self.tableTrackOrder.isHidden = false
                self.successTaskOrderStatus(response!)
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
//                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                break
            }
            
        }) { (error) in
        }
    }
    
    func successTaskOrderStatus(_ response: JSON)
    {
        //            {
        //                "ORDER_RECEIVED": "b1Hbq4Uf5d5JLEb2ijZSmA==",
        //                "ResponseCode": "200",
        //                "OrderStatus": "RCrGRkfVTymDraiDebiA+yzvIRdNcw8IJbYZB8P1amo=",
        //                "transaction_type":"String",
        //                "order_type":"String",
        //                "Responsedetails": "success",
        //                "OUT_FOR_DELIVERY": "b1Hbq4Uf5d5JLEb2ijZSmA==",
        //                "DELIVERED": "b1Hbq4Uf5d5JLEb2ijZSmA==",
        //                "PAYMENT_AWAITING": "b1Hbq4Uf5d5JLEb2ijZSmA==",
        //                "ORDER_READY": "b1Hbq4Uf5d5JLEb2ijZSmA=="
        //            }
        
        if response["ResponseCode"] == "200"{
            let arrTemp  = NSMutableArray()
            arrTemp.addObjects(from: self.arrOrderItems as [AnyObject])
            //            for (index, element) in self.arrOrderItems.enumerate() {
            //                print("Item \(index): \(element)")
            //                if (element["OrderStatusText"] as! String) == PAYMENT_AWAITING{
            //                    if var mutableElement = element as? [String:AnyObject]{
            //                        mutableElement["OrderStatus"] = (response.dictionaryObject!["PAYMENT_AWAITING"] as! String).getAESDecryption()
            //                        arrTemp[index] = mutableElement
            //                    }
            //                }
            //                if (element["OrderStatusText"] as! String) == ORDER_RECIEVED{
            //                    
            //                    if var mutableElement = element as? [String:AnyObject]{
            //                        mutableElement["OrderStatus"] = (response.dictionaryObject!["ORDER_RECEIVED"] as! String).getAESDecryption()
            //                        arrTemp[index] = mutableElement
            //                    }
            //                }
            //                if (element["OrderStatusText"] as! String) == ORDER_READY{
            //                    if var mutableElement = element as? [String:AnyObject]{
            //                        mutableElement["OrderStatus"] = (response.dictionaryObject!["ORDER_READY"] as! String).getAESDecryption()
            //                        arrTemp[index] = mutableElement
            //                    }
            //                }
            //                if (element["OrderStatusText"] as! String) == OUT_FOR_DELIVERY{
            //                    if var mutableElement = element as? [String:AnyObject]{
            //                        mutableElement["OrderStatus"] = (response.dictionaryObject!["PAYMENT_AWAITING"] as! String).getAESDecryption()
            //                        arrTemp[index] = mutableElement
            //                    }
            //                }
            //                if (element["OrderStatusText"] as! String) == DELIVERED{
            //                    if var mutableElement = element as? [String:AnyObject]{
            //                        mutableElement["OrderStatus"] = (response.dictionaryObject!["DELIVERED"] as! String).getAESDecryption()
            //                        arrTemp[index] = mutableElement
            //                    }
            //                }
            //            }
            
            var tempPaymentType = PYLTrackOrderViewController.paymentType.kCOD
            switch response["transaction_type"].stringValue.getAESDecryption() {
            case "COD":
                tempPaymentType = PYLTrackOrderViewController.paymentType.kCOD
            case "ONLINE":
                tempPaymentType = PYLTrackOrderViewController.paymentType.kOnline
            default:
                tempPaymentType = PYLTrackOrderViewController.paymentType.kOnline
            }
            var tempOrderType = PYLTrackOrderViewController.orderType.kDineIn
            switch response["order_type"].stringValue.getAESDecryption() {
            case "DINE_IN":
                tempOrderType = PYLTrackOrderViewController.orderType.kDineIn
            case "TAKE_AWAY":
                tempOrderType = PYLTrackOrderViewController.orderType.kTakeAway
            case "DELIVERY":
                tempOrderType = PYLTrackOrderViewController.orderType.kDelivery
            default:
                break
            }
            let arrOrdering = getOrderedTrackingArray(tempOrderType, paymentType: tempPaymentType)
            let statusOfOrder = response["order_status"].stringValue.getAESDecryption()
            let statusOfOrderIndex = arrOrdering.index(of: statusOfOrder)
       
            for (index, element) in self.arrOrderItems.enumerated() {
                debugPrint("Item \(index): \(element)")
                if (element["OrderStatusKey"] as! String) == PAYMENT_AWAITING{
                    if var mutableElement = element as? [String:AnyObject]{
                        if let orderingIndex = arrOrdering.index(of: PAYMENT_RECEIVED) {
                            mutableElement["OrderStatus"] = orderingIndex <= statusOfOrderIndex! ? true as AnyObject? : false as AnyObject?
                            mutableElement["OrderStatusText"] = orderingIndex <= statusOfOrderIndex! ? "Payment Received" as AnyObject? :"Payment Awaiting" as AnyObject?
                            arrTemp[orderingIndex] = mutableElement
                        }
                    }
                }
                if (element["OrderStatusKey"] as! String) == ORDER_RECIEVED{
                    
                    if var mutableElement = element as? [String:AnyObject]{
                        if let orderingIndex = arrOrdering.index(of: ORDER_RECIEVED) {
                            mutableElement["OrderStatus"] = orderingIndex <= statusOfOrderIndex! ? true as AnyObject : false as AnyObject
                            arrTemp[orderingIndex] = mutableElement
                        }
                    }
                }
                if (element["OrderStatusKey"] as! String) == ORDER_READY{
                    if var mutableElement = element as? [String:AnyObject]{
                        if let orderingIndex = arrOrdering.index(of: ORDER_READY) {
                            mutableElement["OrderStatus"] = orderingIndex <= statusOfOrderIndex! ? true as AnyObject? : false as AnyObject?
                            arrTemp[orderingIndex] = mutableElement
                        }
                        
                    }
                }
                if (element["OrderStatusKey"] as! String) == OUT_FOR_DELIVERY{
                    if var mutableElement = element as? [String:AnyObject]{
                        if let orderingIndex = arrOrdering.index(of: OUT_FOR_DELIVERY) {
                            mutableElement["OrderStatus"] = statusOfOrderIndex! >= arrOrdering.index(of: ORDER_READY)! ? true as AnyObject? : false as AnyObject?
                            switch tempOrderType {
                            case .kDineIn:
                                  mutableElement["OrderStatusText"] = READYTOSERVE as AnyObject?
                                  //TODO:- Change respective icons
                                  mutableElement["StatusImageSelected"] = "ReadyToServeTwo" as AnyObject?
                                  mutableElement["StatusImage"] = "ReadyToServeOne" as AnyObject?
                            case .kDelivery:
                                mutableElement["OrderStatusText"] = OUTFORDELIVERY as AnyObject?
                                mutableElement["StatusImageSelected"] = "OutForDeliveryTwo" as AnyObject?
                                mutableElement["StatusImage"] = "OutForDeliveryOne" as AnyObject?
                            case .kTakeAway:
                                mutableElement["OrderStatusText"] = READYFORTAKEAWAY as AnyObject?
                                mutableElement["StatusImageSelected"] = "TakeAwayOrderTwo" as AnyObject?
                                mutableElement["StatusImage"] = "TakeAwayOrderOne" as AnyObject?
                            }
                           
                            arrTemp[orderingIndex] = mutableElement
                        }
                    }
                }
                if (element["OrderStatusKey"] as! String) == DELIVERED{
                    if var mutableElement = element as? [String:AnyObject]{
                        if let orderingIndex = arrOrdering.index(of: tempOrderType == .kDelivery ? DELIVERED:SERVED) {
                            mutableElement["OrderStatus"] = orderingIndex <= statusOfOrderIndex! ? true as AnyObject? : false as AnyObject?
                            switch tempOrderType {
                            case .kDineIn:
                                mutableElement["OrderStatusText"] = "Served" as AnyObject?
                            case .kDelivery,.kTakeAway:
                                mutableElement["OrderStatusText"] = "Delivered" as AnyObject?
                            }
                            arrTemp[orderingIndex] = mutableElement
                        }
                    }
                }
            }
            
            if arrOrdering.count == arrTemp.count - 1 {
                arrTemp.removeLastObject()
            }
            
            self.arrOrderItems.removeAll()
            self.arrOrderItems.append(contentsOf: arrTemp as [AnyObject])
            self.tableTrackOrder.reloadData()
        }
    }
}
