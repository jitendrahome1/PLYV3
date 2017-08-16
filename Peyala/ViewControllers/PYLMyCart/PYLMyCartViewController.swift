//
//  PYLMyCartViewController.swift
//  Peyala
//
//  Created by Adarsh on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let HeightCartHeader = 62.0
let HeightAllergyNotes = 50.0
let HeightAllergicTextField = 50.0
let HeightCartItem = 220.0
let HeightCartItemLoyalty = 257.0
let HeightOrderSummary = 344.0
let HeightOrderSummaryPYLCash = 375.0

let ViewBaseTag = 100
let ButtonBaseTag = 200
let LabelBaseTag = 300
let TextFieldBaseTag = 400
let ImageViewBaseTag = 500

import UIKit

class PYLMyCartViewController: PYLBaseViewController {
    
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewData: UITableView!
    
    var arrData:[Dictionary<String,AnyObject>] = []
    var allergyText = ""
    let indexSectionSummary = 2, indexSectionHeader = 0, indexSetionCartItems = 1
    let indexRowTotal = 0, indexRowAllergyNotes = 2
    var totalPeyalaCashAmountReceived = 0.0
    
    var myCartApiCallCount = 0
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        //        callMyCartApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callMyCartApi()
        trackScreenForAnalyticsWithName(MY_CART_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debugPrint("\(tableViewData.frame.size)")
    }
    
    // MARK: - User Defined Function
    func setupUI() {
        //        self.view.backgroundColor = UIColor(red: 243/255.0, green: 232/255.0, blue: 207/255.0, alpha: 1)
        self.view.backgroundColor = BG_CREAM_COLOR
        tableViewData.backgroundColor = UIColor.clear
        //        tableViewData.defaultSetup()
    }
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = false
        self.menuButtonEnabled = true
        self.backButtonEnabled = false
        self.title = "MY CART"
    }
    
    func validateCart() -> Bool {
        var validate = true
        let sectionTwoArray = self.arrData[indexSetionCartItems]["value"] as! Array<Dictionary<String,AnyObject>>
        for dictCartItem in sectionTwoArray {
            let isChanged = (dictCartItem["isChanged"] as! String) == "1"
            let isDeleted = (dictCartItem["isDeleted"] as! String) == "1"
            if isDeleted {
                validate = false
                self.view.showToastWithMessage(REMOVE_CART_DEL_MODIFY,delayTime:2.0)
                break
            }
            else if isChanged {
                validate = false
                self.view.showToastWithMessage(REMOVE_CART_DEL_MODIFY,delayTime:2.0)
                break
            }
        }
        return validate
    }
    
    func getHeightForRowAtIndexPath(_ indexPath: IndexPath, isEstimated: Bool) -> Double {
        var height = 0.0
        let cellID = ((arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row])["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            height = HeightCartHeader
            
        case "PYLAllergyNotes":
            height = HeightAllergyNotes
            
        case String(describing: PYLAllergicTextFieldCell.self):
            height = HeightAllergicTextField
            
        case String(describing: PYLCartItemCell.self):
            //            height = HeightCartItem
            //
            //            var dictRow = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            //            let isLoyaltyAvailable = Int(dictRow["isLoyaltyAvailable"] as! String)
            //            if isLoyaltyAvailable != 0 {
            //                height = HeightCartItemLoyalty
            //            }
            
            height = isEstimated ? HeightCartItemLoyalty : Double(UITableViewAutomaticDimension)
            
        case String(describing: PYLOrderSummaryCell.self):
//            height = HeightOrderSummary
//            var dictRow = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
//            let myPeyalaCash = Int(Double(dictRow["myPeyalaCash"] as! String)!)
//            if myPeyalaCash != 0 {
//                height = HeightOrderSummaryPYLCash
//            }
            
            height = HeightOrderSummaryPYLCash
            
        default:
            break
        }
        return height
    }
    
    
    func populateDataArray() {
        
        //section-1
        let arrSectionAllergyNotes = [["attribute":"My Cart","cellId":"PYLHeaderCell"],
                                      ["shouldAdd":"0","cellId":"PYLAllergyNotes"]]
        arrData.append(["sectionName":"Allergy Notes" as AnyObject,"value":arrSectionAllergyNotes as AnyObject])
        
        //section-2
        let arrSectionOrderDetails = [["itemImage":"FoodDetailsBanner","itemName":"Chittaginian beef bhuna","itemDesc":"dsjuhygdqeyd ygyd gweygd uuyye yhfgt67fy6t jg6yftrd hgftyfhyugyug uhguhguhy8uy8 ytfg6rfyguguy6","addOnsValue":"Meat2x","basicPrice":"750","quantity":"3","total":"2250","cellId":String(describing: PYLCartItemCell.self)],
                                      ["itemImage":"FoodDetailsBanner","itemName":"Peyala combo meal","itemDesc":"dsjuhygdqeyd ygyd gweygd uuyye yhfgt67fy6t jg6yftrd hgftyfhyugyug uhguhguhy8uy8 ytfg6 rfyguguy6","addOnsValue":"Meat2x","basicPrice":"750","quantity":"3","total":"2250","cellId":String(describing: PYLCartItemCell.self)],["itemImage":"FoodDetailsBanner","itemName":"Chittaginian beef bhuna","itemDesc":"dsjuhygdqeyd ygydg weygd uuyye yhfgt67fy6t jg6yftrd hgftyfhyugyug uhguhguhy8uy8 ytfg6rfyguguy6","addOnsValue":"Meat2x","basicPrice":"750","quantity":"3","total":"2250","cellId":String(describing: PYLCartItemCell.self)]]
        arrData.append(["sectionName":"Order Details" as AnyObject,"value":arrSectionOrderDetails as AnyObject])
        
        //section-3
        let arrSectionSummary = [["totalPrice":"4500","tax":"100","grandTotal":"4600","checked":"0","cellId":String(describing: PYLOrderSummaryCell.self)]]
        arrData.append(["sectionName":"Summary" as AnyObject,"value":arrSectionSummary as AnyObject])
        
    }
    
    func getTotalPriceForGrand() -> Double {
        var totalPriceForGrand = 0.0
        let sectionTwoArray = self.arrData[1]["value"] as! Array<Dictionary<String,AnyObject>>
        for dict in sectionTwoArray {
            let price = Double((dict["total"] as? String)!)
            totalPriceForGrand += price!
        }
        return totalPriceForGrand
    }
    
    //    func getTaxFromTotal(totalPrice: Double) -> Double{
    //        var tax = 0.0
    //        for taxObj in PYLHelper.helper.arrTax {
    //            //            if taxObj.taxName == KEY_SERVICE_TAX {
    //            //                tax = totalPrice * Double(taxObj.taxPercentage)! * 0.01
    //            //                break
    //            //            }
    //            tax = tax + (totalPrice * Double(taxObj.taxPercentage)! * 0.01)
    //        }
    //        return tax
    //    }
    
    func getTaxFromTotal(_ totalPrice: Double) -> (taxValue: Double, taxableAmount: Double){
        var taxValue = 0.0
        for taxObj in PYLHelper.helper.arrTax {
            
            taxValue += Double(taxObj.taxPercentage)!
        }
        let taxableAmount = totalPrice * taxValue * 0.01
        return (taxValue: "\(taxValue)".toDoubleWithRoundOfUpToTwoDecimal()!, taxableAmount: "\(taxableAmount)".toDoubleWithRoundOfUpToTwoDecimal()!)
        //        return (taxValue: taxValue, taxableAmount: taxableAmount)
    }
    
    func updatedApiObjOfCartItem(_ apiObj:[String:AnyObject], isCombo:String, newQuantity:Int, newTotalPrice:Int) -> [String:AnyObject] {
        var copyApiObj = apiObj
        copyApiObj["total_price"] = "\(newTotalPrice)".setAESEncription() as AnyObject?
        if isCombo == "1" {
            copyApiObj["combo_qty"] = "\(newQuantity)".setAESEncription() as AnyObject?
        }
        else {
            copyApiObj["qty"] = "\(newQuantity)".setAESEncription() as AnyObject?
        }
        return copyApiObj
    }
    
    func updateLastSectionForTotal() {
        //modify summary cell(in section-3) with the change in quantity for this product
        var sectionThreeArray = self.arrData[self.arrData.count-1]["value"] as! Array<Dictionary<String,AnyObject>>
        var dataSrcDictSectionThree = sectionThreeArray[indexRowTotal] as! Dictionary<String,String>
        
        let totalPrice = getTotalPriceForGrand()
        let taxTuple = getTaxFromTotal(totalPrice)
        let taxableAmount = taxTuple.taxableAmount  //no need to get the taxValue, as it will always remain same for this screen.
        let grandTotal = totalPrice + taxableAmount
        dataSrcDictSectionThree["totalPrice"] = "\(totalPrice)"
        dataSrcDictSectionThree["grandTotal"] = "\(grandTotal)"
        dataSrcDictSectionThree["taxableAmount"]  = "\(taxableAmount)"
        sectionThreeArray[indexRowTotal] = dataSrcDictSectionThree as [String : AnyObject]
        self.arrData[self.arrData.count-1]["value"] = sectionThreeArray as AnyObject?
    }
    
    //when quantity of certain cart item changes, this function is responsible to make all the necessary updates to any cell in the table.
    func updateTableArrayForUpdatedProduct(atIndexPath indexPath: IndexPath, newQuantity quantity:Int, newTotalPrice totalPrice:Double)
    {
        //modify the total price of tthis product according with quantity
        var dataSrcDict = ((arrData[indexPath.section] as [String:AnyObject])["value"] as! [[String:AnyObject]])[indexPath.row]
        dataSrcDict["quantity"] = "\(quantity)" as AnyObject?
        dataSrcDict["total"] = "\(totalPrice)".toStringWithRoundOfUpToTwoDecimal() as AnyObject?
        let item = dataSrcDict["apiSentObj"] as! [String:AnyObject]
        let isCombo = dataSrcDict["isCombo"] as! String
        dataSrcDict["apiSentObj"] = updatedApiObjOfCartItem(item, isCombo:isCombo , newQuantity: quantity, newTotalPrice: Int(totalPrice)) as AnyObject?
        //now loyalty part
        dataSrcDict["loyaltyCash"] = getLoyaltyPointsOfItem(dataSrcDict) as AnyObject?
        
        var sectionTwoArray = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
        sectionTwoArray[indexPath.row] = dataSrcDict
        self.arrData[indexPath.section]["value"] = sectionTwoArray as AnyObject?
        //modify summary cell(in section-3) with the change in quantity for this product
        updateLastSectionForTotal()
    }
    
    func getLoyaltyPointsOfItem(_ dataSrcDict: [String:AnyObject]) -> String {
        //        var dataSrcDict = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
        let isLoyaltyAvailable = Int(dataSrcDict["isLoyaltyAvailable"] as! String)
        guard isLoyaltyAvailable != 0 else { return "0" }
        //let foodBasicPrice = Double(dataSrcDict["basicPrice"] as! String)
        // as per the new requirement peyala points and cash needs to be calculate with the Total Price. So basic pric changes to total price. that's why commented above line.
        let foodBasicPrice = Double(dataSrcDict["total"] as! String)
        //let foodQuantity = Double(dataSrcDict["quantity"] as! String)
        let loyaltyPercentage = Double(dataSrcDict["loyaltyPercentage"] as! String)
        let loyaltyUnitValue = Double(dataSrcDict["loyaltyUnitValue"] as! String)
        //let loyaltyPoints = foodBasicPrice! * foodQuantity! * loyaltyPercentage! * 0.01
        let loyaltyPoints = foodBasicPrice! * loyaltyPercentage! * 0.01
        let loyaltyCash = loyaltyPoints * loyaltyUnitValue!
        //        return "\(Int(loyaltyCash))"
        return "\(loyaltyCash)".toStringWithRoundOfUpToTwoDecimal()!
    }
    
    func setupNoData() {
        arrData = []
        SET_CART_BADGE("\(0)")
        //        tableViewData.layoutSubviews()
        tableViewData.reloadData()
        //        tableViewData.showNodataLabelWithText(NO_ITEMS_CART)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.tableViewData.showNodataLabelWithText(NO_ITEMS_CART)
        }
    }
    
    func prepareArrayForComboDetailsCell(_ arrPrevFoodDetails:[[String:AnyObject]]) -> [[String:AnyObject]] {
        var arrNewFoodDetails = [[String:AnyObject]]()
        for dictPrevFood in arrPrevFoodDetails {
            var dictNewFood = [String:AnyObject]()
            dictNewFood["food_name"] = dictPrevFood["food_name"]
            dictNewFood["food_size_name"] = dictPrevFood["food_size_name"]
            dictNewFood["discount_text"] = "" as AnyObject?
            dictNewFood["food_item_img_url"] = dictPrevFood["food_item_img_url"]
            var arrNewAddOn = [[String:AnyObject]]()
            for dictPrevAddOn in dictPrevFood["extra_addon_details"] as! [[String:AnyObject]] {
                guard (String.getSafeString(dictPrevAddOn["is_selected"]).getAESDecryption() == "true") else {
                    continue
                }
                var dictNewAddOn = [String:AnyObject]()
                dictNewAddOn["addon_name"] = dictPrevAddOn["addon_name"]
                dictNewAddOn["addon_quantity"] = dictPrevAddOn["qty"]
                arrNewAddOn.append(dictNewAddOn)
            }
            dictNewFood["addon_details"] = arrNewAddOn as AnyObject?
            var arrNewDefaultAddOn = [[String:AnyObject]]()
            for dictPrevDefaultAddOn in dictPrevFood["default_addon_details"] as! [[String:AnyObject]] {
                guard (String.getSafeString(dictPrevDefaultAddOn["is_selected"]).getAESDecryption() == "true") else {
                    continue
                }
                var dictNewDefaultAddOn = [String:AnyObject]()
                dictNewDefaultAddOn["addon_name"] = dictPrevDefaultAddOn["addon_name"]
                dictNewDefaultAddOn["addon_quantity"] = "1".setAESEncription() as AnyObject?
                arrNewDefaultAddOn.append(dictNewDefaultAddOn)
            }
            dictNewFood["default_addon_details"] = arrNewDefaultAddOn as AnyObject?
            arrNewFoodDetails.append(dictNewFood)
        }
        return arrNewFoodDetails
    }
    
    func prepareExtraAddOnTextCommaSeparated(addOnsArray arrApiAddOns:[[String:AnyObject]], arrApiFood:[[String:AnyObject]]) -> String {
        var adonsString = ""
        if arrApiAddOns.count > 0 { //for a single food-item
            var i = 0
            for dictApiAddOn in arrApiAddOns {
                guard (String.getSafeString(dictApiAddOn["is_selected"]).getAESDecryption() == "true") else {
                    continue
                }
                i += 1
//                adonsString = adonsString + "\((dictApiAddOn["addon_name"] as! String).getAESDecryption())x\((dictApiAddOn["qty"] as! String).getAESDecryption()), "
                
                
                adonsString = adonsString + "\((dictApiAddOn["addon_name"] as! String).getAESDecryption()) \((dictApiAddOn["qty"] as! String).getAESDecryption())x, "
            }
        }
        else { // in case of a 'combo'
            var i = 0
            for dictApiFood in arrApiFood {
                i += 1
                let arrAddOns = dictApiFood["extra_addon_details"] as! [[String:AnyObject]]
                let newFoodAddOnStr = prepareExtraAddOnTextCommaSeparated(addOnsArray: arrAddOns, arrApiFood: [])
                if !newFoodAddOnStr.isBlank {
                    adonsString = adonsString + newFoodAddOnStr + ", "
                }
            }
        }
        //        if adonsString.length>=2 {
        //            adonsString = adonsString.chopSuffix(2) // removes last 2 characters from resultant string i.e ",_"
        //        }
        return adonsString.isBlank ? "" : adonsString.chopSuffix(2)
    }
    
    func prepareDefaultAddOnTextCommaSeparated(addOnsArray arrApiAddOns:[[String:AnyObject]], arrApiFood:[[String:AnyObject]]) -> String {
        var adonsString = ""
        if arrApiAddOns.count > 0 { //for a single food-item
            var i = 0
            for dictApiAddOn in arrApiAddOns {
                guard (String.getSafeString(dictApiAddOn["is_selected"]).getAESDecryption() == "true") else {
                    continue
                }
                i += 1
                //                adonsString = adonsString + "\((dictApiAddOn["addon_name"] as! String).getAESDecryption())x\((dictApiAddOn["qty"] as! String).getAESDecryption()), "
                adonsString = adonsString + "\((dictApiAddOn["addon_name"] as! String).getAESDecryption()) 1x, "
            }
        }
        else { // in case of a 'combo'
            var i = 0
            for dictApiFood in arrApiFood {
                i += 1
                let arrAddOns = dictApiFood["default_addon_details"] as! [[String:AnyObject]]
                let newFoodAddOnStr = prepareDefaultAddOnTextCommaSeparated(addOnsArray: arrAddOns, arrApiFood: [])
                if !newFoodAddOnStr.isBlank {
                    adonsString = adonsString + newFoodAddOnStr + ", "
                }
            }
        }
        //        if adonsString.length>=2 {
        //            adonsString = adonsString.chopSuffix(2) // removes last 2 characters from resultant string i.e ",_"
        //        }
        return adonsString.isBlank ? "" : adonsString.chopSuffix(2)
    }
    
    // MARK: - Button actions
    func menuMyCartBtnTapped(_ sender: UIButton) {
        PYLAddOrClearPopUp.showAddOrClearPopUp(self, selected: { (buttonIndex) in
            //selected code here
            switch(buttonIndex) {
            case ButtonBaseTag + 1 :
                trackButtonTapEventsForAnalytics(actionName: CART_ADD_MORE_ITEM_EVENT, tapsRequired: "1")
                self.addMoreItemAction()
            case ButtonBaseTag + 2 :
                trackButtonTapEventsForAnalytics(actionName: CLEAR_CART_EVENT, tapsRequired: "1")
                self.callClearCartApi()
            default :
                break
            }
            
            }, dismiss: {
                //dismiss code here
        })
    }
    
    func addMoreItemAction(_ sender:AnyObject? = nil) {
        if let button = sender as? UIButton {
            button.isEnabled = false
        }
        for viewControllerObj in PYLNavigationHelper.helper.navigationController.viewControllers {
            if viewControllerObj .isKind(of: PYLFoodItemsViewController.self) {
                let viewController = viewControllerObj as! PYLFoodItemsViewController
                PYLNavigationHelper.helper.navigationController.viewControllers.removeObject(viewController)
            }
        }
        let foodItemsVc = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLFoodItemsViewController.self))  as! PYLFoodItemsViewController
        let arrCategory = PYLHelper.helper.arrFoodCategory
        if arrCategory.count < 1 {
            self.view.showToastWithMessage(FOOD_ITEM_NOT_AVAILABLE)
            return
        }
        let catagoryDict = arrCategory[0] // set the category as 1st element by default.
        if let catagoryID =  catagoryDict["food_category_id"] as? String {
            foodItemsVc.foodCatagoryID = catagoryID.getAESDecryption()
        }
        if let catagoryName =  catagoryDict["food_category_name"] as? String{
            foodItemsVc.foodCatagoryName = catagoryName.getAESDecryption()
        }
        foodItemsVc.catagoryArray = PYLHelper.helper.arrFoodCategory
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            PYLNavigationHelper.helper.navigationController!.pushViewController(foodItemsVc, animated: true)
        }
    }
    
    //MARK: - API section
    
    func callMyCartApi()
    {
        PYLAPIHandler.handler.getMyCartDetails({ (response) in
            //            switch (response["ResponseCode"].stringValue) {
            //            case "200":
            //                self.successTaskMyCartApi(response)
            //            case CODE_SESSION_TOKEN_MISMATCH:
            //                self.logOutForSessionTokenMismatch()
            //            case CODE_INACTIVE_USER:
            //                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //            }
            
            self.myCartApiCallCount += 1
            self.offlineOrSuccessResponseHandleMyCartApi(response!)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleMyCartApi(response!)
        }) { (error) in
            //            self.view.showToastWithMessage(error.description)
        }
    }
    
    func callDeleteFoodItemFromMyCartApi(_ foodUniqueID:String, comboUniqueID:String, success:@escaping ()->())
    {
        PYLAPIHandler.handler.deleteFoodItemFromCart(foodUniqueID, comboUniqueID: comboUniqueID, success:{ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.view.showToastWithMessage(ITEM_REMOVED)
                success()
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            //            self.view.showToastWithMessage(error.description)
        }
    }
    
    func callClearCartApi()
    {
        self.present(UIAlertController.showStandardAlertWith(kAppDetailedTitle, alertText: SURE_DELETE_ALL_ITEM, cancelTitle: NO, doneTitle: YES, selected_: { (index) in
            if index == 1 {
                PYLAPIHandler.handler.clearCart({ (response) in
                    switch (response?["ResponseCode"].stringValue)! {
                    case "200":
                        self.successTaskClearCartApi(response!)
                    case CODE_SESSION_TOKEN_MISMATCH:
                        self.logOutForSessionTokenMismatch()
                    case CODE_INACTIVE_USER:
                        self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
                    default :
                        self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                    }
                }) { (error) in
                    //            self.view.showToastWithMessage(error.description)
                }
            }else {  //if pressed NO
                // stay on this page
            }
            
        }), animated: true, completion: nil)
        
        
    }
    
    func callUpdateCartItemQuantityApi(_ foodUniqueID:String, comboUniqueID:String,totalPrice:String, quantity:String,completion: @escaping ()->())
    {
        PYLAPIHandler.handler.updateCartItemQuantity(foodUniqueID, comboUniqueID: comboUniqueID, totalPrice: totalPrice, quantity: quantity, success:{ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                completion()
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
            //            self.view.showToastWithMessage(error.description)
        }
    }
    
    func successTaskClearCartApi(_ response: JSON) {
        //self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        //        tableViewData.isHidden = true
        self.setupNoData()
    }
    
    func successTaskMyCartApi(_ response: JSON) {
        
        debugPrint(response)
        //set user-peyalaCash in app global var for user.
        PYLHelper.helper.userModelObj!.loyaltycash = response["loyalty_cash"].stringValue.getAESDecryption().toStringWithRoundOfUpToTwoDecimal()!
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        
        arrData = []
        //section-1
        let arrSectionAllergyNotes = [["attribute":"My Cart","cellId":"PYLHeaderCell"],
                                      ["shouldAdd":"0","cellId":"PYLAllergyNotes"]]
        arrData.append(["sectionName":"Allergy Notes" as AnyObject,"value":arrSectionAllergyNotes as AnyObject])
        
        //section-2
        let arrComboFoodDetails = response["combo_food_details"].array
        SET_CART_BADGE("\((arrComboFoodDetails?.count)!)")
        guard (arrComboFoodDetails?.count)! > 0 else {
            //            tableViewData.isHidden = true
            self.setupNoData()
            return
        }
        tableViewData.isHidden = false
        var arrSectionOrderDetails:[[String:AnyObject]] = []
        for i in 0..<arrComboFoodDetails!.count {
            var dict = Dictionary<String,AnyObject>()
            var strDefaultAddOns = ""
            var strExtraAddOns = ""
            if String.getSafeString(arrComboFoodDetails![i]["combo_id"].string as AnyObject?).length > 0 {
                
                dict["isCombo"] = "1" as AnyObject?
                dict["itemImage"] = String.getSafeString(arrComboFoodDetails![i]["combo_image_url"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["itemName"] = String.getSafeString(arrComboFoodDetails![i]["combo_name"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["itemDesc"] = String.getSafeString(arrComboFoodDetails![i]["combo_description"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["basicPrice"] = String.getSafeString(arrComboFoodDetails![i]["combo_price"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["quantity"] = String.getSafeString(arrComboFoodDetails![i]["combo_qty"].string as AnyObject?).getAESDecryption() as AnyObject?
                let arrFoodTemp = (arrComboFoodDetails![i].dictionaryObject)!["food_details"] as! [[String:AnyObject]]
                strDefaultAddOns = prepareDefaultAddOnTextCommaSeparated(addOnsArray: [], arrApiFood: arrFoodTemp)
                strExtraAddOns = prepareExtraAddOnTextCommaSeparated(addOnsArray: [], arrApiFood: arrFoodTemp)
            }
            else
            {
                dict["isCombo"] = "0" as AnyObject?
                dict["itemImage"] = String.getSafeString(arrComboFoodDetails![i]["food_item_img_url"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["itemName"] = String.getSafeString(arrComboFoodDetails![i]["food_name"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["itemDesc"] = String.getSafeString(arrComboFoodDetails![i]["food_description"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["basicPrice"] = String.getSafeString(arrComboFoodDetails![i]["food_size_price"].string as AnyObject?).getAESDecryption() as AnyObject?
                dict["quantity"] = String.getSafeString(arrComboFoodDetails![i]["qty"].string as AnyObject?).getAESDecryption() as AnyObject?
                let arrDefaultAddOnTemp = (arrComboFoodDetails![i].dictionaryObject)!["default_addon_details"] as! [[String:AnyObject]]
                strDefaultAddOns = prepareDefaultAddOnTextCommaSeparated(addOnsArray: arrDefaultAddOnTemp, arrApiFood:[])
                let arrAddOnTemp = (arrComboFoodDetails![i].dictionaryObject)!["extra_addon_details"] as! [[String:AnyObject]]
                strExtraAddOns = prepareExtraAddOnTextCommaSeparated(addOnsArray: arrAddOnTemp, arrApiFood:[])
            }
            //            dict["addOnsValue"] = String.getSafeString(dict["addOnsValue"]).isBlank ? "N/A" : dict["addOnsValue"]
            dict["addOnsValue"] = strDefaultAddOns.isBlank ? (strExtraAddOns.isBlank ? "N/A" : strExtraAddOns) as AnyObject? : (strExtraAddOns.isBlank ? strDefaultAddOns as AnyObject? : "\(strDefaultAddOns),\(strExtraAddOns)" as AnyObject?) as AnyObject?
            dict["quantity"] = (dict["quantity"] as! String).isBlank ? "1" as AnyObject? : dict["quantity"] as AnyObject?
            //            dict["total"] = "\(Int(dict["basicPrice"]! as! String)! * Int(dict["quantity"]! as! String)! )"
            var strTotal = String.getSafeString(arrComboFoodDetails![i]["total_price"].string as AnyObject?).getAESDecryption()
            strTotal = strTotal.isBlank ? "0.0" : strTotal
            //            dict["total"] = Int(strTotal) != nil ? strTotal : "\(Int(Double(strTotal)!))"
            //            dict["singlePrice"] = "\(Int(dict["total"]! as! String)! / Int(dict["quantity"]! as! String)! )"
            dict["total"] = strTotal as AnyObject?  //this time the value should be in 'double'
            dict["singlePrice"] = "\(Double(dict["total"]! as! String)!/Double(dict["quantity"]! as! String)! )" as AnyObject?
            
            dict["isDeleted"] = String.getSafeString(arrComboFoodDetails![i]["is_deleted"].string as AnyObject?).getAESDecryption().lowercased() == "true" ? "1" as AnyObject? : "0" as AnyObject?
            dict["isChanged"] = String.getSafeString(arrComboFoodDetails![i]["is_change"].string as AnyObject?).getAESDecryption().lowercased() == "true" ? "1" as AnyObject? : "0" as AnyObject?
            
            //Set the loyalty things in sectionTotal.
            //            dict["isLoyaltyAvailable"] = String.getSafeString(arrComboFoodDetails![i]["is_loyalty_available"].string).getAESDecryption()
            //            dict["loyaltyPercentage"] = String.getSafeString(arrComboFoodDetails![i]["loyalty_percentage"].string).getAESDecryption()
            //            dict["loyaltyUnitValue"] = String.getSafeString(arrComboFoodDetails![i]["loyalty_unit_value"].string).getAESDecryption()
            
            let isLoyaltyAvailable = String.getSafeString(arrComboFoodDetails![i]["is_loyalty_available"].string as AnyObject?).getAESDecryption()
            dict["isLoyaltyAvailable"] = isLoyaltyAvailable.isBlank ? "0" as AnyObject? : isLoyaltyAvailable as AnyObject?
            let loyaltyPercentage = String.getSafeString(arrComboFoodDetails![i]["loyalty_percentage"].string as AnyObject?).getAESDecryption()
            dict["loyaltyPercentage"] = loyaltyPercentage.isBlank ? "0" as AnyObject? : loyaltyPercentage as AnyObject?
            let loyaltyUnitValue = String.getSafeString(arrComboFoodDetails![i]["loyalty_unit_value"].string as AnyObject?).getAESDecryption()
            dict["loyaltyUnitValue"] = loyaltyUnitValue.isBlank ? "0" as AnyObject? : loyaltyUnitValue as AnyObject?
            dict["loyaltyCash"] = getLoyaltyPointsOfItem(dict) as AnyObject?
            
            dict["cellId"] = String(describing:PYLCartItemCell.self) as AnyObject?
            dict["apiSentObj"] = arrComboFoodDetails![i].dictionaryObject as AnyObject?
            arrSectionOrderDetails.append(dict)
        }
        arrData.append(["sectionName":"Order Details" as AnyObject,"value":arrSectionOrderDetails as AnyObject])
        
        //section-3
        //        let totalPrice = Int(getTotalPriceForGrand())
        //        let tax = Int(getTaxFromTotal(Double(totalPrice)))
        
        let totalPrice = getTotalPriceForGrand()
        let taxTuple = getTaxFromTotal(totalPrice)
        let taxValue = taxTuple.taxValue
        let taxableAmount = taxTuple.taxableAmount
        let myPeyalaCash = PYLHelper.helper.userModelObj!.loyaltycash.isBlank ? "0.00" : PYLHelper.helper.userModelObj!.loyaltycash
        //        let myPeyalaCash = "44"
        let arrSectionSummary = [["totalPrice":"\(totalPrice)","taxValue":"\(taxValue)","taxableAmount":"\(taxableAmount)","grandTotal":"\(totalPrice + taxableAmount)","checked":"0","myPeyalaCash":myPeyalaCash,"cellId":String(describing: PYLOrderSummaryCell.self)]]
        arrData.append(["sectionName":"Summary" as AnyObject,"value":arrSectionSummary as AnyObject])
        tableViewData.reloadData()
    }
    
    func offlineOrSuccessResponseHandleMyCartApi(_ response: JSON) {
        switch (response["ResponseCode"].stringValue) {
        case "200":
            self.successTaskMyCartApi(response)
        case CODE_SESSION_TOKEN_MISMATCH:
            self.logOutForSessionTokenMismatch()
        case CODE_INACTIVE_USER:
            self.inactiveUserAction(withMessage: response["Responsedetails"].stringValue)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    //MARK:- Netrork-ON Notification Observer
    override func networkOnConnectAction() {
        if(myCartApiCallCount < 1){
            callMyCartApi()
        }
    }
}

extension PYLMyCartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellID = ((arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row])["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            break
            
        case "PYLAllergyNotes":
            let cell = tableView.cellForRow(at: indexPath)
            var datasource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            let shouldAdd = (datasource["shouldAdd"] as? String) == "1"
            datasource["shouldAdd"] = shouldAdd ? "0" as AnyObject? : "1" as AnyObject?
            let buttonMenu = cell!.viewWithTag(ButtonBaseTag+1) as! UIButton
            buttonMenu.isSelected = (datasource["shouldAdd"] as? String) == "1"
            
            //modify allergic cell, then add/remove textfield cell after it
            var sectionOneArray = arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
            sectionOneArray[1] = datasource
            if buttonMenu.isSelected { //add
                sectionOneArray.append(["note":allergyText as AnyObject,"cellId": String(describing:PYLAllergicTextFieldCell.self) as AnyObject])
                arrData[0]["value"] = sectionOneArray as AnyObject?
                tableView.insertRows(at: [IndexPath(row: sectionOneArray.count-1, section: 0)], with: .fade)
            }
            else { //remove
                sectionOneArray.remove(at: sectionOneArray.count-1)
                arrData[0]["value"] = sectionOneArray as AnyObject?
                tableView.deleteRows(at: [IndexPath(row: sectionOneArray.count, section: 0)], with: .fade)
            }
            
        case String(describing: PYLAllergicTextFieldCell.self):
            break
            
        case String(describing: PYLCartItemCell.self):
            break
            
        case String(describing: PYLOrderSummaryCell.self):
            break
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(getHeightForRowAtIndexPath(indexPath, isEstimated: true))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(getHeightForRowAtIndexPath(indexPath, isEstimated: false))
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        var height = 0.0
    //        let cellID = ((arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row])["cellId"] as! String
    //        switch cellID {
    //        case "PYLHeaderCell":
    //            height = HeightCartHeader
    //            
    //        case "PYLAllergyNotes":
    //            height = HeightAllergyNotes
    //            
    //        case String(PYLAllergicTextFieldCell):
    //            height = HeightAllergicTextField
    //            
    //        case String(PYLCartItemCell):
    //            height = HeightCartItem
    //            
    //            var dictRow = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
    //            let isLoyaltyAvailable = Int(dictRow["isLoyaltyAvailable"] as! String)
    //            if isLoyaltyAvailable != 0 {
    //                height = HeightCartItemLoyalty
    //            }
    //            
    //        case String(PYLOrderSummaryCell):
    //            height = HeightOrderSummary
    //            var dictRow = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
    //            let myPeyalaCash = Int(Double(dictRow["myPeyalaCash"] as! String)!)
    //            if myPeyalaCash != 0 {
    //                height = HeightOrderSummaryPYLCash
    //            }
    //            
    //        default:
    //            break
    //        }
    //        return CGFloat(height)
    //        
    //    }
}

extension PYLMyCartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrData[section]["value"] as! Array<AnyObject>).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellGlobal = UITableViewCell()
        let cellID = ((arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row])["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            let buttonMenu = cell.viewWithTag(ButtonBaseTag+33) as! UIButton
            buttonMenu.isEnabled = true
            // let buttonMenu = cell.viewWithTag(ButtonBaseTag+1) as! UIButton
            //            buttonMenu.addTarget(self, action: #selector(PYLMyCartViewController.menuMyCartBtnTapped(_:)), forControlEvents: .TouchUpInside)
            buttonMenu.addTarget(self, action: #selector(addMoreItemAction), for: .touchUpInside)
            cellGlobal = cell
            
        case "PYLAllergyNotes":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            let datasource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            let buttonMenu = cell.viewWithTag(ButtonBaseTag+1) as! UIButton
            buttonMenu.isSelected = (datasource["shouldAdd"] as? String) == "1"
            cellGlobal = cell
            
        case String(describing: PYLAllergicTextFieldCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PYLAllergicTextFieldCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.textFieldEndedEditing = { (fieldValue) in
                var dict = cell.datasource as! Dictionary<String,AnyObject>
                self.allergyText = fieldValue
                dict["note"] = self.allergyText as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            cellGlobal = cell
            
        case String(describing: PYLCartItemCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PYLCartItemCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.productQuantityUpdateBlock = { (quantity, totalPrice) in
                //MARK: call quantity api
                let dictApi = cell.datasource["apiSentObj"] as! [String:AnyObject]
                var foodUniqueID = ""
                var comboUniqueID = ""
                if String.getSafeString(dictApi["combo_id"]).length > 0 {
                    comboUniqueID = String.getSafeString(dictApi["combo_unique_id"]).getAESDecryption()
                }
                else {
                    foodUniqueID = String.getSafeString(dictApi["food_unique_id"]).getAESDecryption()
                }
                self.callUpdateCartItemQuantityApi(foodUniqueID, comboUniqueID: comboUniqueID, totalPrice: "\(Int(totalPrice))", quantity: "\(quantity)", completion: {
                    self.updateTableArrayForUpdatedProduct(atIndexPath: indexPath, newQuantity: quantity, newTotalPrice: totalPrice)
                    tableView.reloadRows(at: [indexPath,IndexPath(row: 0, section: self.arrData.count-1)], with: .none)
                    
                    //                    self.callMyCartApi()
                })
            }
            cell.deleteButtonTapped = {
                
                // show alert
                self.present(UIAlertController.showStandardAlertWith(kAppDetailedTitle, alertText: SURE_DELETE_ITEM, cancelTitle: NO, doneTitle: YES, selected_: { (index) in
                    if index == 1 {
                        
                        let dictApi = cell.datasource["apiSentObj"] as! [String:AnyObject]
                        var foodUniqueID = ""
                        var comboUniqueID = ""
                        if String.getSafeString(dictApi["combo_id"]).length > 0 {
                            comboUniqueID = String.getSafeString(dictApi["combo_unique_id"]).getAESDecryption()
                        }
                        else {
                            foodUniqueID = String.getSafeString(dictApi["food_unique_id"]).getAESDecryption()
                        }
                        self.callDeleteFoodItemFromMyCartApi(foodUniqueID, comboUniqueID: comboUniqueID,success: {
                            var sectionTwoArray = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                            sectionTwoArray.remove(at: indexPath.row)
                            SET_CART_BADGE("\(sectionTwoArray.count)")
                            self.arrData[indexPath.section]["value"] = sectionTwoArray as AnyObject?
                            self.updateLastSectionForTotal() //the deletion should affect the last section for Total/Grand-Total price.
                            if(sectionTwoArray.count>0) {
                                tableView.deleteRows(at: [indexPath], with: .fade) //used to show delete-animation
                                //below code is used to correct the indexpaths of each row after deletion, prevents a certain crash.
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                                    tableView.reloadData()
                                }
                            }
                            else {
                                //                        tableView.isHidden = true
                                self.setupNoData()
                            }
                        })
                        
                        
                    } else {  //if pressed NO
                        // stay on this page
                    }
                    
                }), animated: true, completion: nil)
                
                //                let dictApi = cell.datasource["apiSentObj"] as! [String:AnyObject]
                //                var foodUniqueID = ""
                //                var comboUniqueID = ""
                //                if String.getSafeString(dictApi["combo_id"]).length > 0 {
                //                    comboUniqueID = String.getSafeString(dictApi["combo_unique_id"]).getAESDecryption()
                //                }
                //                else {
                //                    foodUniqueID = String.getSafeString(dictApi["food_unique_id"]).getAESDecryption()
                //                }
                //                self.callDeleteFoodItemFromMyCartApi(foodUniqueID, comboUniqueID: comboUniqueID,success: {
                //                    var sectionTwoArray = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                //                    sectionTwoArray.removeAtIndex(indexPath.row)
                //                    SET_CART_BADGE("\(sectionTwoArray.count)")
                //                    self.arrData[indexPath.section]["value"] = sectionTwoArray
                //                    self.updateLastSectionForTotal() //the deletion should affect the last section for Total/Grand-Total price.
                //                    if(sectionTwoArray.count>0) {
                //                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade) //used to show delete-animation
                //                        //below code is used to correct the indexpaths of each row after deletion, prevents a certain crash.
                //                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                //                            tableView.reloadData()
                //                        }
                //                    }
                //                    else {
                //                        //                        tableView.isHidden = true
                //                        self.setupNoData()
                //                    }
                //                })
            }
            cell.editButtonTapped = {
                
                let dictApi = cell.datasource["apiSentObj"] as! [String:AnyObject]
                if String.getSafeString(dictApi["combo_id"]).length > 0 {
                    let comboFoodDetailsViewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLComboFoodDetailsViewController.self)) as! PYLComboFoodDetailsViewController
                    comboFoodDetailsViewController.previousVcType = PYLComboFoodDetailsViewController.vcType.kMyCart
                    comboFoodDetailsViewController.comboDetailsDictionary = dictApi
                    PYLNavigationHelper.helper.navigationController.pushViewController(comboFoodDetailsViewController, animated: true)
                }
                else {
                    let foodDetailsViewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLFoodDetailsViewController.self)) as! PYLFoodDetailsViewController
                    foodDetailsViewController.previousVcType = PYLFoodDetailsViewController.vcType.kMyCart
                    foodDetailsViewController.editFoodDetailsDictionary = dictApi
                    PYLNavigationHelper.helper.navigationController.pushViewController(foodDetailsViewController, animated: true)
                }
            }
            cell.comboDetailsTapped = {
                //If the cart-item is a combo (not a food), then only it will work.
                cell.buttonComboDetails.isUserInteractionEnabled = false
                let dictApi = cell.datasource["apiSentObj"] as! [String:AnyObject]
                let arrModifiedComboFoods = self.prepareArrayForComboDetailsCell(dictApi["food_details"]! as! [[String : AnyObject]])
                PYLComboDetailsPopUp.showComboDetailsPopUp(self, comboItems:arrModifiedComboFoods as AnyObject, dissmiss: {
                    cell.buttonComboDetails.isUserInteractionEnabled = true
                })
            }
            //UI
            if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)  {
                cell.constraintCurveViewBottom.constant = 4.0 //correct value
                cell.viewLineGray.isHidden = true
            }
            else {
                cell.constraintCurveViewBottom.constant = 100.0 //this number can be anything, but should be quite greater than 4.
                //                cell.constraintCurveViewBottom.constant = 4.0 //this number can be anything, but should be quite greater than 4.
                cell.viewLineGray.isHidden = false
            }
            cellGlobal = cell
            
        case String(describing: PYLOrderSummaryCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PYLOrderSummaryCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.placeOrderCompletion = { [weak self] in
                
                self?.totalPeyalaCashAmountReceived = 0.0
                
                let valueArraay = ((self?.arrData[indexPath.section - 1])?["value"] as! [[String:AnyObject]])
                for (_, obj) in valueArraay.enumerated() {
                    self?.totalPeyalaCashAmountReceived = (self?.totalPeyalaCashAmountReceived)! + (obj["loyaltyCash"] as! String).toDouble()!
                }
                //debugPrint((self?.totalPeyalaCashAmountReceived)!)
                //debugPrint((self?.totalPeyalaCashAmountReceived)!.roundTo(places: 2))
                //debugPrint(String(format: "%.2f", ((self?.totalPeyalaCashAmountReceived)!.roundTo(places: 2))))
                trackButtonTapEventsForAnalytics(actionName: PLACE_ORDER_EVENT, tapsRequired: "1")
                
                guard (self?.validateCart())! else{return}
                guard PYLHelper.helper.isNetworkOn else{
                    //                    animateNoNetworkViewIfPresent()       //noNetwork animate
                    return}
                
                let arrSectionSummary = self?.arrData[(self?.indexSectionSummary)!]["value"] as! Array<Dictionary<String,AnyObject>>
                let grandTotal = Double(arrSectionSummary[(self?.indexRowTotal)!]["grandTotal"] as! String)
                let totalPriceWithOutVat = arrSectionSummary[(self?.indexRowTotal)!]["totalPrice"] as! String
                let tax = arrSectionSummary[(self?.indexRowTotal)!]["taxableAmount"] as! String
                PYLHelper.helper.placeOrderObj = ModelPlaceOrder()
                PYLHelper.helper.placeOrderObj!.totalPriceWithOutVat = totalPriceWithOutVat
                PYLHelper.helper.placeOrderObj!.totalReceivablePeyalaCash = (String(format: "%.2f", ((self?.totalPeyalaCashAmountReceived)!.roundTo(places: 2))))
                PYLHelper.helper.placeOrderObj!.totalPrice = "\(grandTotal!)"
                PYLHelper.helper.placeOrderObj!.tax = tax
                PYLHelper.helper.placeOrderObj!.allergyNotes = (self?.allergyText)!
                self?.pushToViewController(servicesStoryboard, viewController: String(describing: PYLServiceViewController.self))
            }
            cell.clearCartCompletion = {
                self.callClearCartApi()
            }
            cellGlobal = cell
            
        default:
            break
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
