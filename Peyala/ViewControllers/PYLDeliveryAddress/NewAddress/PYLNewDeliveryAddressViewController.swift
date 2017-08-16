//
//  PYLNewDeliveryAddressViewController.swift
//  Peyala
//
//  Created by Adarsh on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//


let HeightNewDeliveryHeader = 62.0
let HeightEnterTextField = 87.0
let HeightEnterTextFieldAddress = 102.0
let HeightOkButton = 76.0

class PYLNewDeliveryAddressViewController: PYLBaseViewController {
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewForm: UITableView!
    
    var arrData:[[String : Any]] = []
    var EditAddress : AnyObject!
    var addressID : String = ""
    var latLong : (latitude:String , longitude :String)!
    var shouldSaveAddressInDirectory = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        populateDataArray()
    }
    
    // MARK: - User Defined Function
    func setUpperNavigationItems() {
        self.notificationButtonEnabled = true
        self.backButtonEnabled = true
        self.cartButtonEnabled = true
        self.title = "DELIVERY ADDRESS"
    }
    
    func setupUI() {
        tableViewForm.backgroundColor = UIColor.clear
    }
    
    func populateDataArray() {
        if let address = EditAddress as? [String : String]{
            addressID = address["address_id"]!.getAESDecryption()
            
            arrData = [["attribute":"Delivery Address" as AnyObject,"cellId":"PYLHeaderCell" as AnyObject],
                       ["attribute":"Flat No." as AnyObject,"attributeText":"Flat no./House no./Apt Name" as AnyObject,"value":address["address_line1"]!.getAESDecryption() as AnyObject,"isAddress":"0" as AnyObject,"cellId":String(describing:PYLDeliveryEnterTextCell.self) as AnyObject],
                       ["attribute":"Landmark" as AnyObject,"attributeText":"Landmark" as AnyObject,"value":address["landmark"]!.getAESDecryption() as AnyObject,"isAddress":"0" as AnyObject,"cellId":String(describing:PYLDeliveryEnterTextCell.self) as AnyObject],
                       ["attribute":"Address" as AnyObject,"attributeText":"Address details" as AnyObject,"value":address["address_line2"]!.getAESDecryption() as AnyObject,"isAddress":"1" as AnyObject,"cellId":"PYLDeliveryEnterTextCellAddress" as AnyObject],
                       ["attribute":"Postal Code" as AnyObject,"attributeText":"Postal Code" as AnyObject,"value":address["pin"]!.getAESDecryption() as AnyObject,"isAddress":"0" as AnyObject,"cellId":String(describing:PYLDeliveryEnterTextCell.self) as AnyObject],
                       ["attribute":"Phone No." as AnyObject,"attributeText":"Phone No." as AnyObject,"value":address["phone_no"]!.getAESDecryption(),"isAddress":"0","cellId":"PYLDeliveryEnterTextCell"],
                       ["attribute":"OK","cellId":"PYLDeliveryButtonCell"]]
            
            latLong = (address["latitude"]!.getAESDecryption(),address["longitude"]!.getAESDecryption())

        }else if arrData.count == 0{

//            arrData = [["attribute":"Delivery Address","cellId":"PYLHeaderCell"],
//                       ["attribute":"Flat No.","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                       ["attribute":"Landmark","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                       ["attribute":"Address","value":"","isAddress":"1","cellId":"PYLDeliveryEnterTextCellAddress"],
//                       ["attribute":"City","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                       ["attribute":"Postal Code","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                       ["attribute":"Phone No.","value":"","isAddress":"0","cellId":"PYLDeliveryEnterTextCell"],
//                       ["attribute":"OK","cellId":"PYLDeliveryButtonCell"]]
            
            arrData = [["attribute":"Delivery Address" as AnyObject,"cellId":"PYLHeaderCell" as AnyObject],
                       ["attribute":"Flat No." as AnyObject,"attributeText":"Flat no./House no./Apt Name" as AnyObject,"value":"" as AnyObject,"isAddress":"0" as AnyObject,"cellId":String(describing: PYLDeliveryEnterTextCell.self)],
                       ["attribute":"Landmark","attributeText":"Landmark","value":"","isAddress":"0","cellId":String(describing: PYLDeliveryEnterTextCell.self)],
                       ["attribute":"Address","attributeText":"Address details","value":"","isAddress":"1","cellId":"PYLDeliveryEnterTextCellAddress"],
                       ["attribute":"Postal Code","attributeText":"Postal Code","value":"","isAddress":"0","cellId":String(describing: PYLDeliveryEnterTextCell.self)],
                       ["attribute":"Phone No.","attributeText":"Phone No.","value":PYLHelper.helper.userModelObj!.phone,"isAddress":"0","cellId":"PYLDeliveryEnterTextCell"],
                       ["attribute":"OK","cellId":"PYLDeliveryButtonCell"]]

        }
    }
    
    // MARK: Api Section
    func callPlaceOrderApi()
    {
        PYLHelper.helper.placeOrderObj!.orderType = PYLHelper.helper.selectedServiceType.rawValue
        PYLAPIHandler.handler.placeOrder({ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                PYLHelper.helper.placedOrderID = (response?["order_id"].stringValue.getAESDecryption())!
                if (response?["order_id"].stringValue.getAESDecryption().length)! > 0 {
                    // SET_CART_BADGE("0")
                }
                //self.view.showToastWithMessage(response["Responsedetails"].stringValue)
                let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLPaymentViewController.self)) as? PYLPaymentViewController
                viewController?.isDeliveryType = false  // //MARK: Phase 2 - make it true
                //viewController?.orderDetails = response
                self.removeViewControllerFromNavigationStack(String(describing: viewController))
                viewController?.orderDetails = response
                PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
                
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
                
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
                
            default :
                self.view.showToastWithMessage((response!["Responsedetails"].stringValue), delayTime: 3)
            }
        }) { (error) in
            //            self.view.showToastWithMessage(error.description)
        }
    }
    
    func checkServiceOptionAvailable(_ isServiceAvailable: @escaping (Bool)->()){
        let deliveryOption = PYLHelper.helper.selectedServiceType
        let addressToPost = [
            "address_id"   : addressID.setAESEncription() ,
            "address_line1": (arrData[1]["value"] as! String).setAESEncription(),
            "address_line2": (arrData[3]["value"] as! String).setAESEncription(),
            "landmark"     : (arrData[2]["value"] as! String).setAESEncription(),
            "city"         : "".setAESEncription(),
            "pin"          : (arrData[4]["value"] as! String).setAESEncription(),
            "phone_no"     : (arrData[5]["value"] as! String).setAESEncription()
        ]
        
        PYLAPIHandler.handler.getBranchesByServiceAndAddress(preferredServiceType: (deliveryOption?.rawValue)!, userLatitude: latLong.latitude, userLongitude: latLong.longitude, address: addressToPost, saveAddInUserDirectory: shouldSaveAddressInDirectory, success: { (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                if let branches = response?[ "branch_details"].arrayObject{
                    if branches.count > 0 {
                        PYLHelper.helper.placeOrderObj!.branchID =  (branches.count > 0 ?  (response?[ "branch_details"][0]["branch_id"].stringValue.getAESDecryption())! : "")
                        branches.count > 0 ? isServiceAvailable(true): isServiceAvailable(false)
                    }else {
                        
                        var message = response?["message"].stringValue.getAESDecryption()
                        if message?.length == 0 {
                            message = "This address is out of delivery area. Please try with a different address."
                        }
                        
                        let alertController = UIAlertController.showSimpleAlertWith(message!, alertText: "", selected_: { (index) in
                        })
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
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
    
    // MARK: - Button actions
    
    func okBtnTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        //address_line1
        for (_,addressdic) in arrData.enumerated() {
            
//            let attributeName = String.getSafeString(addressdic["attribute"])
//            let attributeVal = String.getSafeString(addressdic["value"])
            
            
//            if ((addressdic["value"] != nil) && (addressdic["value"] as! String).isEmpty) && (addressdic["attribute"] as! String).containsString("Flat No.") == false{
            if ((addressdic["value"] != nil) && (addressdic["value"] as! String).isEmpty){
                self.view.showToastWithMessage("Please enter \((addressdic["attribute"] as! String))")
                return
            }else{
//                if ((attributeName == "Phone No.") && attributeVal.length<10) {
//                    self.view.showToastWithMessage(INVALID_PHONE)
//                    return
//                }
            }
        }
        
        //        PYLAPIHandler.handler.addOrEditDeliveryAddress(addressID ?? "", addressLine1: (arrData[1]["value"] as! String), addressLine2: (arrData[2]["value"] as! String), Landmark: (arrData[2]["value"] as! String), City: (arrData[3]["value"] as! String), Pincode: (arrData[4]["value"] as! String), PhoneNo: (arrData[5]["value"] as! String), success: { (response) in
        //            
        //            }, failure: { (error) in
        //                
        //        })
        
        //Address-stuffs for place-order (delivery)
        PYLHelper.helper.placeOrderObj!.addressID = addressID 
        PYLHelper.helper.placeOrderObj!.addressLine1 = (arrData[1]["value"] as! String)
        PYLHelper.helper.placeOrderObj!.addressLine2 = (arrData[3]["value"] as! String)
        PYLHelper.helper.placeOrderObj!.addressLandmark = (arrData[2]["value"] as! String)
        PYLHelper.helper.placeOrderObj!.addressCity = ""
        PYLHelper.helper.placeOrderObj!.addressPin = (arrData[4]["value"] as! String)
        PYLHelper.helper.placeOrderObj!.addressPhone = (arrData[5]["value"] as! String)
        checkServiceOptionAvailable { (isServiceAvailable) in
            if isServiceAvailable == true{
                self.callPlaceOrderApi()
            }else{
                self.view.showToastWithMessage(NO_BRANCH_AVAILABLE)
            }
        }
    }
}

extension PYLNewDeliveryAddressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0.0
        let cellID = arrData[indexPath.row]["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            height = HeightNewDeliveryHeader
            
        case String(describing: PYLDeliveryEnterTextCell.self):
            height = HeightEnterTextField
            
        case "PYLDeliveryEnterTextCellAddress":
            height = HeightEnterTextFieldAddress
            
        case "PYLDeliveryButtonCell":
            height = HeightOkButton
            
        default:
            break
        }
        return CGFloat(height)
        
    }
}

extension PYLNewDeliveryAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellGlobal = UITableViewCell()
        let cellID = arrData[indexPath.row]["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            cellGlobal = cell
            
        case String(describing: PYLDeliveryEnterTextCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PYLDeliveryEnterTextCell
            cell.datasource = arrData[indexPath.row] as AnyObject!
            cell.textFieldEndedEditing = {(fieldvalue) in
                var dictionary = self.arrData[indexPath.row]
                dictionary["value"] = fieldvalue as AnyObject?
                self.arrData[indexPath.row] = dictionary
            }
            cellGlobal = cell
            
        case "PYLDeliveryEnterTextCellAddress":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PYLDeliveryEnterTextCell
            cell.datasource = arrData[indexPath.row] as AnyObject!
            cell.textViewEndedEditing = {(fieldvalue) in
                var dictionary = self.arrData[indexPath.row]
                dictionary["value"] = fieldvalue as AnyObject?
                self.arrData[indexPath.row] = dictionary
            }
            cellGlobal = cell
            
        case "PYLDeliveryButtonCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            let buttonOk = cell.viewWithTag(ButtonBaseTag+1) as! UIButton
            buttonOk.addTarget(self, action: #selector(PYLNewDeliveryAddressViewController.okBtnTapped(_:)), for: .touchUpInside)
            cellGlobal = cell
            
        default:
            break
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
