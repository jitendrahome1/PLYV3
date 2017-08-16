//
//  PYLPaymentViewController.swift
//  Peyala
//
//  Created by Soumen Das on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
////

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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

enum paymentOption : String {
    case Online = "ONLINE"
    case COD    = "COD"
    case NotSelected  = "Select Payment Option"
    case WALLET  = "PEYALA_WALLET"
}

class PYLPaymentViewController: PYLBaseViewController , SSLCommerzDelegate ,UITableViewDelegate,UITableViewDataSource{
    
    //MARK: - Outlet Collections
    
    @IBOutlet weak var paymentTable: UITableView!
    
    @IBOutlet var constraintTableViewHeight: NSLayoutConstraint!
    var customHeaderHeight: Float = 0
    var  sdkObject : SSLCommerz!
    let paymentOptions = ["Select Payment Option","Online", "Cash On Delivery"]
    var arrPaymentOptions = [AnyObject]()
    let deliveryChannels = ["Fedex","E-Card","Delhivery"]
    var selectedpaymentOption : paymentOption = .NotSelected
    var selectedDeliveryChannel = ""
    var orderDetails : JSON!
    var transactionID : String!
    var selectedPeyalaCash:String! = "0"
    var rowsWhichAreChecked :IndexPath = []
    var selectedIndexPath : IndexPath = []
    var indexIntegerValue:NSInteger = 0
    var newInteger = NSInteger()
    var paymentArray = [[String:AnyObject]]()
    var reqPaymentResponse : JSON!
    var paymentDone:Bool = false
    var transactionDetails : TransactionDetails!
    var isDeliveryType : Bool = false  //TODO: pass deliveryType from previous classes, if deliveryMode is there.
    var roundValue: Double?
    var amountPayable : String! = "0"
    var peyalaAvailableCash: String?
    var noSection:Int?
    var finalPayableAmount : String! = "0"
    //MARK: - View Life Cycle
    
    var valueEnteredInPeyalaCashBox = ""
    var payableAmount = ""
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        noSection = 2
        paymentTable.defaultSetup()
        paymentDone = false
        self.paymentTable.estimatedRowHeight = 100;
        paymentTable.rowHeight = UITableViewAutomaticDimension;
        // let paymentOptions = ["Online", "Cash On Delivery"]
        self.makeLocalDictPayment(_forArrData: paymentOptions as [AnyObject])
        //        //****** test
        //        isDeliveryType = true//(Int(arc4random_uniform(16)) % 2) == 0 ? true : false //change
        //        var userDetails = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY) as? [String:AnyObject]
        //        userDetails!["loyaltycash"] = "1000"
        //        SET_USERDEFAULT_VALUE(userDetails!, forKey: USER_DEFAULT_STORED_USER_KEY)
        //        //****** test end
        
        customHeaderHeight = IS_IPAD() ? 70.0 : 59.0
        sdkObject = SSLCommerz()
        sdkObject.delegate = self
        var userDetails = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY) as? [String:AnyObject]
        peyalaAvailableCash = (userDetails!["loyaltycash"] as! String).length > 0 ? (userDetails!["loyaltycash"] as! String):"0"
        
        
        let make = "chevy"
        //let year = 2008
        let orderDetailsDictionary  = ["trackMake":[make]]
        let orderDictionary = ["trackMake":[make]]
        //let neworderDictionary = ["trackMake":[make]]
        paymentArray.append(orderDictionary as [String : AnyObject])
        paymentArray.append(orderDetailsDictionary as [String : AnyObject])
        //        paymentArray.append(neworderDictionary as [String : AnyObject])
        //        if isDeliveryType {
        //            paymentArray.append(["trackMake":[make] as AnyObject])
        //
        //        }
        
        var height = (customHeaderHeight + Float(62) + Float(55 * paymentOptions.count)) //255
        if Double(peyalaAvailableCash!) > 0 {
            height = height + (IS_IPAD() ? 250.0 : 210.0)
            
        }
        height = height + (IS_IPAD() ? 55 : 28)
        //paymentTable.frame.size.height = CGFloat(height)
        constraintTableViewHeight.constant = CGFloat(height )
        self.view.layoutIfNeeded()

    }
    // MAKE- toolbar
    func addToolBar(_ textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        // toolBar.barTintColor = UIColor.redColor()
        toolBar.barTintColor = UIColorRGB(57, g: 181, b: 74)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PYLPaymentViewController.donePressed))
        // let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PYLPaymentViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton ,spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.inputAccessoryView = toolBar
    }
    func donePressed(){
        
        
        view.endEditing(true)
        self.paymentTable.reloadData()
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    // MARK:- Make Local Dict or payment type
    func makeLocalDictPayment(_forArrData pData: [AnyObject]){
        var dictTempPymentType = [String: AnyObject]()
        self.arrPaymentOptions.removeAll()
        for index in 0..<pData.count
        {
            dictTempPymentType  = ["Name":(pData[index] as! String) as AnyObject , "buttonStatus": false as AnyObject]
            self.arrPaymentOptions.append(dictTempPymentType as AnyObject)
        }
        
    }
    // MARK:- Payment Type Check box Action
    func actionPaytemTypeCheckBox(_ sender: UIButton){
        self.makeLocalDictPayment(_forArrData: self.paymentOptions as [AnyObject])
        let pointInTable: CGPoint  = sender.convert(sender.bounds.origin, to: self.paymentTable)
        let cellIndexPath = self.paymentTable.indexPathForRow(at: pointInTable)
        if cellIndexPath?.item == 1{
            var tempData =  self.arrPaymentOptions[(cellIndexPath?.item)!] as![String: AnyObject]
            tempData["buttonStatus"]  = true as Bool as AnyObject
            self.arrPaymentOptions.remove(at: (cellIndexPath?.item)!)
            self.arrPaymentOptions.insert(tempData as AnyObject, at: (cellIndexPath?.item)!)
            selectedpaymentOption = .Online
        }
        else if cellIndexPath?.item == 2{
            var tempData =  self.arrPaymentOptions[(cellIndexPath?.item)!] as![String: AnyObject]
            tempData["buttonStatus"]  = true as Bool as AnyObject
            self.arrPaymentOptions.remove(at: (cellIndexPath?.item)!)
            self.arrPaymentOptions.insert(tempData as AnyObject, at: (cellIndexPath?.item)!)
            selectedpaymentOption = .COD
        }
        calculateRoundOff()
        self.paymentTable.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.searchButtonEnabled = false
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.title = "PAYMENT"
    }
    
    func onSelectedPaymentAction(_ sender: UIButton!) {
        
        //        PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: paymentOption, position: .bottom, pickerTitle: "", preSelected:(sender.titleLabel?.text)!, selected: { (value, index) in
        //
        //            if value != nil {
        //                guard (value as! String).length > 0 else { return }
        //
        //                if (sender.titleLabel?.text)! != (value as? String) {
        //
        //                    sender.setTitle(value as? String, for: UIControlState())
        //                    sender.setTitle(value as? String, for: .highlighted)
        //                    sender.setTitle(value as? String, for: .selected)
        //
        //                }
        //
        //                //sender.titleLabel?.text = value as? String
        //
        //            }
        //        })
        
    }
    
    
    // MARK: - Table View DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int{
        //    return paymentArray.count
        
        // jitu code
        
        return selectedPeyalaCash.toDouble()! == amountPayable.toDouble()! ? 1 : noSection!
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if section == 0{
        //            return (paymentArray[0]["trackMake"]?.count)!
        //        }
        //        else if section == 1{
        //            return (paymentArray[0]["trackMake"]?.count)!
        //        }
        //        else if section == 2{
        //            return (paymentArray[0]["trackMake"]?.count)!
        //        }
        //        else if section == 3{
        //            //MARK: Phase 2 return (paymentArray[0]["trackMake"]?.count)!
        //
        //           return 0 //return (paymentArray[0]["trackMake"]?.count)!
        //        }
        //        else{
        //            return 0
        //        }
        // Jitu code
        if section == 0{
            if Double(peyalaAvailableCash!) > 0{
                return 2
            }else{
                return 1
            }
        }
        else if section == 1{
            return arrPaymentOptions.count;
        }else{
            return 0
        }
        
    }
    
    func calculateRoundOff() {
        
        let orginalValue = orderDetails["total_price"].stringValue.getAESDecryption()
        let decimalPart = orginalValue.components(separatedBy: ".")[1]
        let index = decimalPart.index (decimalPart.startIndex, offsetBy: 0)
        let signleDecimalValue = Int(String(decimalPart[index]))
        
        if signleDecimalValue! >= 5{
            let cellValue =    ceil(Double(orginalValue)!)
            
            
            roundValue =  cellValue - Double(orginalValue)!
            if selectedpaymentOption == .Online{
                self.amountPayable = String(Double(orginalValue)!)
            }else{
                self.amountPayable = String(Double(orginalValue)! + roundValue!)
            }
            
            
        }else {
            
            
            let floorValue =    floor(Double(orginalValue)!)
            roundValue = Double(orginalValue)! -  floorValue
            if selectedpaymentOption == .Online{
                self.amountPayable = String(Double(orginalValue)!)
            }
            else{
                self.amountPayable = String(Double(orginalValue)! - roundValue!)
            }
            
            
//            finalPayableAmount = finalPayableAmount + roundValue!
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let orginalValue = orderDetails["total_price"].stringValue.getAESDecryption()
        let decimalPart = orginalValue.components(separatedBy: ".")[1]
        let index = decimalPart.index (decimalPart.startIndex, offsetBy: 0)
        let signleDecimalValue = Int(String(decimalPart[index]))
        
        calculateRoundOff()
        //let amountPayable:String = orderDetails["total_price"].stringValue.getAESDecryption()
        var cellReuseIdentifier = "paymentCell"
        // let cell:PYLPaymentTableViewCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentTableViewCell
        var cell: PYLBaseTableViewCell?
        
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 && Double(peyalaAvailableCash!) > 0 {
                
                
                cellReuseIdentifier = "paymentCell"
                cell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentTableViewCell
                if selectedpaymentOption == .Online{
                   (cell as! PYLPaymentTableViewCell).nsConstRoundOff.constant = 0.0
                }else{
                    
                    if signleDecimalValue  == 0{
                       (cell as! PYLPaymentTableViewCell).nsConstRoundOff.constant = 0.0
                    }else{
                       (cell as! PYLPaymentTableViewCell).nsConstRoundOff.constant = 33.0
                    }
                
                }
                
                (cell as! PYLPaymentTableViewCell).selectedAmout = selectedPeyalaCash
                (cell as! PYLPaymentTableViewCell).isDeliveryType = isDeliveryType //change
                (cell as! PYLPaymentTableViewCell).selectedpaymentOption = selectedpaymentOption
                (cell as! PYLPaymentTableViewCell).datasource = orderDetails.dictionaryObject as AnyObject!
                self.addToolBar( (cell as! PYLPaymentTableViewCell).textfieldPeyalaCashSelected)
                (cell as! PYLPaymentTableViewCell).accessoryView = nil;
                (cell as! PYLPaymentTableViewCell).peyalaCashSelected = { amountselected in
                    self.selectedPeyalaCash = amountselected.length > 0 ? amountselected : "0"
                    //tableView.reloadSections(IndexSet(integer: 1), with: .none)
                    tableView.reloadData()
                }
                
                
                return cell!
            }
            else{
                if selectedpaymentOption == .NotSelected || selectedpaymentOption == .COD || signleDecimalValue == 0
                {// new cell
                    if indexPath.row == 0 && Double(peyalaAvailableCash!) == 0.00{
                        let cellReuseIdentifier = "PYLPaymentRoundOffCell"
                        
                        let cell:PYLPaymentRoundOffCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentRoundOffCell
                        
                        cell.datasource = orderDetails.dictionaryObject as AnyObject!
                        
                        return cell
                    }
                        
                    else{
                        let cellReuseIdentifier = "paymentdetailsCell"
                        let cell:PYLPaymentDetailsTableViewCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentDetailsTableViewCell
                        //
                        if  Double(peyalaAvailableCash!) > 0 {
                            let __amountPayable = (self.amountPayable?.toDouble()!)! - selectedPeyalaCash.toDouble()!
                            cell.textLabel?.text = "Amount Payable: " +  "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                            finalPayableAmount = "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! as String
                        }
                        else{
                            let __amountPayable = (orginalValue.toDouble()!) - selectedPeyalaCash.toDouble()!
                            cell.textLabel?.text = "Amount Payable: " +  "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                            finalPayableAmount = "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! as String
                        }
                        
                        
                        
                        return cell
                    }
                }
                else if selectedpaymentOption == .Online{
                    // old cell
                    if indexPath.row == 0 && Double(peyalaAvailableCash!) == 0.00{
                        let cellReuseIdentifier = "paymentdetailsCell"
                        let cell:PYLPaymentDetailsTableViewCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentDetailsTableViewCell
                        //                        let amountPayable = (self.amountPayable?.toDouble()!)! - selectedPeyalaCash.toDouble()!
                        //                        cell.textLabel?.text = "Amount Payable: " +  "\(amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                        
                        let __amountPayable = (orginalValue.toDouble()!) - selectedPeyalaCash.toDouble()!
                        cell.textLabel?.text = "Amount Payable: " +  "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                        finalPayableAmount = "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! as String
                        
                        return cell
                    }
                        
                    else{
                        let cellReuseIdentifier = "paymentdetailsCell"
                        let cell:PYLPaymentDetailsTableViewCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentDetailsTableViewCell
                        
                        
                        if Double(peyalaAvailableCash!)  > 0 {
                            let __amountPayable = (self.amountPayable?.toDouble()!)! - selectedPeyalaCash.toDouble()!
                            cell.textLabel?.text = "Amount Payable: " +  "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                            finalPayableAmount = "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! as String
                        }else{
                            let __amountPayable = (orginalValue.toDouble()!) - selectedPeyalaCash.toDouble()!
                            cell.textLabel?.text = "Amount Payable: " +  "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! + " Taka" //change
                            finalPayableAmount = "\(__amountPayable)".toStringWithRoundOfUpToTwoDecimal()! as String
                        }
                        
                        
                        return cell
                    }
                }
                
                
                
                
                
            }
            
        case 1:
            let cellReuseIdentifier = "paymentBillCell"

            let cell:PYLPaymentBillTableViewCell = paymentTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PYLPaymentBillTableViewCell
            
            cell.datasource  = self.arrPaymentOptions[indexPath.row]
            cell.btnPaymentType.addTarget(self, action:#selector(actionPaytemTypeCheckBox), for:.touchUpInside)
            // cell.lblPaymentType?.text = paymentOptions[indexPath.row]
            return cell
            
        default:
            break
        }

        
        return cell!

    }
    
    //MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        // jitu code
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 && Double(peyalaAvailableCash!) > 0 {
                return IS_IPAD() ? 250 : 210
            }
            else {
                if Double(peyalaAvailableCash!)  == 0.00{
                    //return IS_IPAD() ? 150 : 134
                    
                    return UITableViewAutomaticDimension;
                }
                else{
                    return IS_IPAD() ? 70 : 59
                }
                
                
            }
        case 1:
            return IS_IPAD() ? 70 : 59
            
        default:
            break
        }
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColorRGB(250, g: 250, b: 247)
        
        let headreLabel = UILabel()
        headreLabel.frame = CGRect(x: 15, y: 0, width: tableView.frame.width, height: CGFloat(customHeaderHeight))
        headreLabel.text = "Payment"
        headreLabel.font = IS_IPAD() ? UIFont.boldSystemFont(ofSize: 20) : UIFont.boldSystemFont(ofSize: 18)
        headerView.addSubview(headreLabel)
        
        let seperatorLabel = UILabel()
        seperatorLabel.frame = CGRect(x: 0, y: headreLabel.frame.height-1, width: tableView.frame.width, height: 0.5)
        seperatorLabel.backgroundColor = UIColor.lightGray
        headerView.addSubview(seperatorLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section)
        {
        case 0:
            return CGFloat(customHeaderHeight)
            
        case 1:
            return 0.0
        case 2:
            return 0.0
        case 3:
            return 0.0
            
        default :break
        }
        
        return CGFloat(customHeaderHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColorRGB(250, g: 250, b: 247)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //        if indexPath.section == 1{
        //        self.makeLocalDictPayment(_forArrData: self.paymentOptions as [AnyObject])
        //        switch indexPath.section {
        //
        //        case 1:
        //            if indexPath.row == 0{
        //            var tempData =  self.arrPaymentOptions[indexPath.row] as![String: AnyObject]
        //             tempData["buttonStatus"]  = true as Bool as AnyObject
        //                self.arrPaymentOptions.remove(at: (indexPath.row))
        //                self.arrPaymentOptions.insert(tempData as AnyObject, at: (indexPath.row))
        //                selectedpaymentOption = .Online
        //
        //
        //            }else if indexPath.row == 1{
        //                var tempData =  self.arrPaymentOptions[indexPath.row] as![String: AnyObject]
        //                tempData["buttonStatus"]  = true as Bool as AnyObject
        //                self.arrPaymentOptions.remove(at: (indexPath.row))
        //                self.arrPaymentOptions.insert(tempData as AnyObject, at: (indexPath.row))
        //                  selectedpaymentOption = .COD
        //            }
        //        default:
        //            break;
        //        }
        //        }
        //  self.paymentTable.reloadData()
        //        let cell = tableView.cellForRow(at: indexPath)
        //        switch indexPath.section {
        //        case 0:
        //            self.rowsWhichAreChecked = indexPath
        //            self.selectedIndexPath = self.rowsWhichAreChecked
        //            self.paymentTable.reloadData()
        //        case 2:
        //            let strInitializer = selectedpaymentOption == .COD ? paymentOptions[1] : selectedpaymentOption == .Online ? paymentOptions[0] : paymentOptions.first!
        //            self.view.endEditing(true)
        //            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: paymentOptions, position: IS_IPAD() ? .center : .bottom, pickerTitle: "", preSelected: strInitializer, selected: { (value, index) in
        //                if value != nil {
        //                    guard (value as! String).length > 0 else { return }
        //                    cell?.textLabel!.text = value as? String
        //                    if index == 0 {
        //                        self.selectedpaymentOption = .Online
        //                    }else if index == 1{
        //                        self.selectedpaymentOption = .COD
        //                    }
        //                }
        //            })
        //
        //        case 3:
        //            let strInitializer = selectedDeliveryChannel.isBlank ? deliveryChannels.first! : selectedDeliveryChannel
        //            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: deliveryChannels, position: IS_IPAD() ? .center : .bottom, pickerTitle: "", preSelected: strInitializer, selected: { (value, index) in
        //                if value != nil {
        //                    guard (value as! String).length > 0 else { return }
        //                    cell?.textLabel!.text = value as? String
        //                    self.selectedDeliveryChannel = value as! String
        //                }
        //            })
        //
        //        default:
        //            break
        //        }
        
        //  self.actionCheckBoxTap()
        
    }
    
    //MARK: - Button Action
    
    @IBAction func proceedToPayAction(_ sender: UIButton!) {
        
        calculateRoundOff()
        
        self.view.endEditing(true)
        
        if self.amountPayable!.toDouble() ==  selectedPeyalaCash!.toDouble() {
            selectedpaymentOption = .WALLET
        }
        
        if selectedpaymentOption != .NotSelected && paymentDone == false
        {
            trackButtonTapEventsForAnalytics(actionName: PROCEED_TO_PAY_EVENT, tapsRequired: "1")
            let __amountPayable:String = orderDetails["total_price"].stringValue.getAESDecryption()
            //let peyalaAvailableCash = PYLHelper.helper.userModelObj!.loyaltycash.length > 0 ? PYLHelper.helper.userModelObj!.loyaltycash:"0"
            
            let minCODPrice  = orderDetails["minimum_cod_price"].stringValue.getAESDecryption()
            guard minCODPrice.toDouble() < __amountPayable.toDouble() || selectedpaymentOption == .Online else{
                self.view.showToastWithMessage(("Minimum purchase amount to avail the COD service is \(minCODPrice) Taka"), delayTime: 3.0)
                return
            }
            let maxCODPrice  = orderDetails["maximum_cod_price"].stringValue.getAESDecryption()
            let payableAmount = __amountPayable.toDouble()! - selectedPeyalaCash.toDouble()!
            guard (payableAmount <= maxCODPrice.toDouble()!) || selectedpaymentOption == .Online else{
                self.view.showToastWithMessage(("COD service will not available over \(maxCODPrice) Taka"), delayTime: 3.0)
                return
            }
//            guard peyalaAvailableCash.toDouble() >= selectedPeyalaCash.toDouble() else{
//                self.view.showToastWithMessage(("Entered amount not available in PEYALA Cash"), delayTime: 3.0)
//                return
//            }
//            guard selectedPeyalaCash.toDouble() < amountPayable.toDouble() else{
//                self.view.showToastWithMessage(("Peyala cash used should be less than purchase amount"), delayTime: 3.0)
//                return
//            }
            
            let orderID  = orderDetails["order_id"].stringValue.getAESDecryption()
            PYLAPIHandler.handler.requestPaymentTransaction(selectedpaymentOption.rawValue, OrderID:orderID,PayByPeyalaCash:"\(selectedPeyalaCash!)", OrderPrice:self.amountPayable!, success: { (response) in
                if response?["ResponseCode"].stringValue == "200" {
                    self.reqPaymentResponse = response
                    self.transactionID = response?["transaction_id"].stringValue.getAESDecryption()
                    debugPrint(self.transactionID)
                    if self.selectedpaymentOption == .Online{
                        var payableAmount =  self.orderDetails["total_price"].stringValue.getAESDecryption().isEmpty ? 0.0 : self.orderDetails["total_price"].stringValue.getAESDecryption().toDouble()
                        payableAmount = payableAmount! - self.selectedPeyalaCash.toDouble()!
                        if payableAmount >= 10 {
                            self.ProceedOnlinePayment()
                        }else{
                            self.view.showToastWithMessage(("Amount should be greater than 10 Taka to pay online"), delayTime: 3.0)
                        }
                        
                    }else{
                        PYLHelper.helper.placeOrderObj?.transactionId = (response?["transaction_id"].stringValue.getAESDecryption())!
                        PYLHelper.helper.placedOrderID = (response?["order_id"].stringValue.getAESDecryption())!
                        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderConfirmationViewController.self)) as? PYLOrderConfirmationViewController
                        viewController?.orderDetails = response
                        self.removeViewControllerFromNavigationStack(String(describing: viewController))
                        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
                    }
                }
                else if response?["ResponseCode"].stringValue == "207" {
                    self.transactionID = response?["transaction_id"].stringValue.getAESDecryption()
                    debugPrint(self.transactionID)
                    if self.selectedpaymentOption == .Online{
                        var payableAmount =  self.orderDetails["total_price"].stringValue.getAESDecryption().isEmpty ? 0.0 : self.orderDetails["total_price"].stringValue.getAESDecryption().toDouble()
                        payableAmount = payableAmount! - self.selectedPeyalaCash.toDouble()!
                        if payableAmount >= 10 {
                            self.ProceedOnlinePayment()
                        }else{
                            self.view.showToastWithMessage(("Amount should be greater than 10 Taka to pay online"), delayTime: 3.0)
                        }
                    }else{
                        PYLHelper.helper.placeOrderObj?.transactionId = (response?["transaction_id"].stringValue.getAESDecryption())!
                        
                        PYLHelper.helper.placedOrderID = self.reqPaymentResponse["order_id"].stringValue.getAESDecryption()
                        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderConfirmationViewController.self)) as? PYLOrderConfirmationViewController
                        viewController?.orderDetails = self.reqPaymentResponse
                        self.removeViewControllerFromNavigationStack(String(describing: viewController))
                        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
                    }
                }
                else if response?["ResponseCode"].stringValue == "201"{
                    self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                }
                else if response?["ResponseCode"].stringValue == CODE_SESSION_TOKEN_MISMATCH {
                    self.logOutForSessionTokenMismatch()
                }
                else if response?["ResponseCode"].stringValue == CODE_INACTIVE_USER {
                    self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
                }
                
            }, failure: { (error) in
                
            })
        }else if paymentDone == true {
            if transactionDetails != nil {
                transactionSuccessful(withCompletionhandler: transactionDetails)
            }
        }else{
            self.view.showToastWithMessage("Please select payment option from the list")
        }
    }
    
    func ProceedOnlinePayment() {
        //todo
        // 0 for Live Account Credential - false
        // 1 for Test Account Credential - true
        //        let value = "0"
        //        let shouldRunInTestMode = false
        
        let value = "1"
        let shouldRunInTestMode = true
        
        PYLAPIHandler.handler.requestMyPeyalaStoreCredential(value, success: { (response) in
            
            debugPrint("response is %@", response ?? "")
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                let storeID = (response?.dictionaryObject!["storeID"] as? String)!.getAESDecryption()
                let storePassword = (response?.dictionaryObject!["storePassword"] as? String)!.getAESDecryption()
                self.finalPaymentService(storeID, storePass: storePassword, runInTestMode: shouldRunInTestMode)
            default :
                break
            }
        }) { (error) in
        }
    }
    
    func finalPaymentService(_ storeID:String!, storePass:String!, runInTestMode:Bool!) {
        
        /*
         sdkObject.startSSLCOMMERZinViewController(self,
         withStoreID: "testbox",
         storePassword: "qwerty",
         amountToPay: "0.01",
         amountCurrency: "BDT",
         applicationUDID: "com.peyala",
         appTransactionID: self.randomStringWithLength(13) as String,
         shouldRunInTestMode: true)
         */
        //Sandbox StoreID: "testbox"; storePassword: "qwerty"
        //Live : StoreID: "peyala001live"; storePassword: "peyala001live61219"
        
        var payableAmount =  orderDetails["total_price"].stringValue.getAESDecryption().isEmpty ? 0.0 : orderDetails["total_price"].stringValue.getAESDecryption().toDouble()
        payableAmount = payableAmount! - selectedPeyalaCash.toDouble()!
        
        sdkObject.startSSLCOMMERZinViewController(self,
                                                  withStoreID: storeID,
                                                  storePassword: storePass,
                                                  amountToPay: "\(payableAmount!)",
            amountCurrency: "BDT",
            applicationUDID: "com.peyala",
            appTransactionID: self.transactionID,
            sourceDetail: "Peyala App iOS",
            withCustomerEmail: PYLHelper.helper.userModelObj?.email,
            customerName: PYLHelper.helper.userModelObj?.firstName,
            customerContactNumber: PYLHelper.helper.userModelObj?.phone,
            customerFax: "",
            customerAddress1: PYLHelper.helper.userModelObj?.address,
            customerAddress2: "",
            customerCity: "",
            customerState: "",
            customerPostCode: PYLHelper.helper.userModelObj?.zipCode,
            customerCountry: "",
            withShipmentInfo: "",
            shipmentAddress1: PYLHelper.helper.placeOrderObj!.addressLine1,
            shipmentAddress2: PYLHelper.helper.placeOrderObj!.addressLine2,
            shipmentCity: PYLHelper.helper.placeOrderObj!.addressCity,
            shipmentState: "",
            sHipmentPostCode: PYLHelper.helper.placeOrderObj!.addressPin,
            shipmentCountry: "",
            withOptionalValueA: "",
            optionalValueB: "",
            optionalValueC: "",
            optionalValueD: "",
            shouldRunInTestMode: runInTestMode)
        
        /* sdkObject.startSSLCOMMERZinViewController(self,
         withStoreID: storeID,
         storePassword: storePass,
         amountToPay:"\(payableAmount!)",
         amountCurrency: "BDT",
         applicationUDID: "com.peyala",
         appTransactionID: self.transactionID,
         sourceDetail: "Peyala App iOS",
         withCustomerEmail: PYLHelper.helper.userModelObj?.email,
         customerName: PYLHelper.helper.userModelObj?.firstName,
         customerContactNumber: PYLHelper.helper.userModelObj?.phone,
         customerFax: "",
         customerAddress1: PYLHelper.helper.userModelObj?.address,
         customerAddress2: "",
         customerCity: "",
         customerState: "",
         customerPostCode: PYLHelper.helper.userModelObj?.zipCode,
         customerCountry: "",
         withShipmentInfo: "",
         shipmentAddress1: PYLHelper.helper.placeOrderObj!.addressLine1,
         shipmentAddress2: PYLHelper.helper.placeOrderObj!.addressLine2,
         shipmentCity: PYLHelper.helper.placeOrderObj!.addressCity,
         shipmentState: "",
         SHipmentPostCode: PYLHelper.helper.placeOrderObj!.addressPin,
         shipmentCountry: "",
         withOptionalValueA: "",
         optionalValueB: "",
         optionalValueC: "",
         optionalValueD: "",
         shouldRunInTestMode: runInTestMode) //true false
         
         */
    }
    
    //MARK: Payment calllbacks
    func transactionSuccessful(withCompletionhandler transactionData: TransactionDetails!) {
        
        if (transactionData.status == "VALID") { //VALID //VALIDATED //FAILED
            paymentDone = true
            transactionDetails = transactionData
            let orderID = orderDetails["order_id"].stringValue.getAESDecryption()
            PYLAPIHandler.handler.confirmPaymentTransaction("Transaction successful", orderID: orderID, transactionID: transactionData.tran_id, status: transactionData.status, amount: transactionData.amount, cardNo: transactionData.card_no, transactionDate: transactionData.tran_date , sessionKey: transactionData.sessionkey, success: { (response) in
                
                
                if response?["ResponseCode"] == "200"{
                    self.paymentDone = false
                    trackPurchaseForAnalytics(PYLHelper.helper.placedOrderID, transactionID: PYLHelper.helper.placeOrderObj!.transactionId , strPrice: transactionData.amount)
                    PYLHelper.helper.userModelObj!.loyaltycash = (response?["loyalty_cash"].stringValue.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!)!
                    SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
                    PYLHelper.helper.placeOrderObj?.transactionId = (response?["transaction_id"].stringValue.getAESDecryption())!
                    PYLHelper.helper.placedOrderID = (response?["order_id"].stringValue.getAESDecryption())!
                    let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderConfirmationViewController.self)) as? PYLOrderConfirmationViewController
                    viewController?.orderDetails = response
                    self.removeViewControllerFromNavigationStack(String(describing: viewController))
                    PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
                }
                
            }) { (error) in
                self.view.showToastWithMessage("Payment Failed")
            }
        }
        else if (transactionData.status == "FAILED") {
            var transactionDetailsString = ""
            if (transactionData != nil) {
                
                transactionDetailsString = "Status \(transactionData.status)\nSessionID \(transactionData.sessionkey)\nBank Transaction ID \(transactionData.bank_tran_id)\nAmount \(transactionData.amount)BDT\nCardType \(transactionData.card_type)\nDate \(transactionData.tran_date)"
            }
            else{
                transactionDetailsString = "Status : Transaction ID Mismatch!"
            }
            let alertController = UIAlertController.showSimpleAlertWith("Transaction \(transactionData.status)", alertText: transactionDetailsString, selected_: { (index) in
                
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func transactionFailedWithCompletionhandler() {
        // Transaction has been failed and call API to inform about that unsuccessful transaction.
        debugPrint("transactionFailedWithCompletionhandler")
        paymentDone = false
        DispatchQueue.main.async( execute: {
            PYLSpinner.hide()
            self.view.showToastWithMessage("Transaction Failed")
        })
    }
    
    //MARK:- Netrork-ON Notification Observer
    override func networkOnConnectAction() {
        if paymentDone == true {
            paymentDone = false
            transactionSuccessful(withCompletionhandler: transactionDetails)
        }
    }
    
}

