//
//  PYLFoodDetailsViewController.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let HeightImageSlideCell = 232.0
let HeightAddOnDefaultValueCell = 54.0
let HeightAddOnValueCell = IS_IPAD() ? 105.0 : 95.0
let HeightDeliveryModeCell = 100.0 //115.0
let HeightSumTotalCell = 204.0
let HeightSumTotalLoyalityCell = 254.0
let HeightAddOnHeaderCell = 62.0

let HeightFoodNameCell = 58.0
let HeightFoodDescriptionCell = 41.0
let HeightPreparationTimeCell = 64.0
let HeightFoodSizeCell = 35.0
let HeightFoodQuantityCell = 86.0
let HeightFoodPriceCell = 44.0
let HeightFoodDiscountCell = 44.0

let CAT_DESSERTS = "Desserts"

class PYLFoodDetailsViewController: PYLBaseViewController {
    
    enum vcType:Int {
        case kMyCart = 1
        case kFoodList = 2
    }
    
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewForm: UITableView!
    
    var arrData = [[String:AnyObject]]()
    var selectCountItems: Int?
    
    var limitValue: Int?
    var foodID: String?
    var foodDetailsDictionary = [String: AnyObject]()
    var editFoodDetailsDictionary = [String: AnyObject]()
    var previousVcType:vcType = PYLFoodDetailsViewController.vcType.kFoodList
    var strNote = ""
    
    //hard-code usage
    let sectionIndexBanner = 0, sectionIndexFoodDesc = 1, sectionIndexDefaultAddOn = 2, sectionIndexAddOn = 3, sectionIndexTotal = 4
    //    let rowIndexBilling = 2, rowIndexMainFoodDetails = 0
    let rowIndexTotal = 0, rowIndexQty = 4, rowIndexDiscount = 7, rowIndexPrice = 8, rowIndexFoodName = 0, rowIndexFoodSize = 3
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        selectCountItems = 0
        setupUI()
        
        //        if previousVcType == vcType.kMyCart {
        //            self.title = "EDIT CART"
        //            loadEditedData()
        //        }
        //        else {
        //            self.title = "FOOD DETAILS"
        //            if foodID != nil{
        //                self.callFoodDetailsAPI()
        //            }else{
        //                self.view.showToastWithMessage(NO_RESULT_FOUND)
        //                return
        //            }
        //
        //        }
        
        if previousVcType == vcType.kMyCart {
            self.title = "EDIT CART"
            foodID =  String.getSafeString(editFoodDetailsDictionary["food_id"]).getAESDecryption()
            self.callFoodDetailsAPI()
        }
        else {
            self.title = "FOOD DETAILS"
            if foodID != nil{
                self.callFoodDetailsAPI()
            }else{
                self.view.showToastWithMessage(NO_RESULT_FOUND)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController!.navigationBar.layer.zPosition = 1000.0
        trackScreenForAnalyticsWithName(FOOD_DETAILS_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController!.navigationBar.layer.zPosition = 0.0
    }
    
    // MARK: - User Defined Function
    func setupUI() {
        self.view.backgroundColor = UIColor(red: 243/255.0, green: 232/255.0, blue: 207/255.0, alpha: 1)
        tableViewForm.backgroundColor = UIColor.clear
        sizeHeaderToFit(tableViewForm)  //header
    }
    
    func redirectToMyPeyalaCash() {
        
        if IS_USER_LOGIN() == false {
            
            self.present(UIAlertController.showStandardAlertWith(kAppDetailedTitle, alertText: ALERT_MESSAGE_SIGN_IN, cancelTitle: OK, doneTitle: CANCEL, selected_: { (index) in
                
                if index == 0 {
                    
                    self.goToLoginScreen({ (success) in
                        self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyPeyalaCashViewController.self))
                    })
                } else { // stay on this page
                }
            }), animated: true, completion: nil)
        }
        else {
            self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyPeyalaCashViewController.self))
        }
    }
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        //self.title = "FOOD DETAILS"
    }
    
    //header
    func sizeHeaderToFit(_ tableView: UITableView) {
        if let headerView = tableView.tableHeaderView {
            _ = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = UIScreen.main.bounds.height/3.0
            headerView.frame = frame
            tableView.tableHeaderView = headerView
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
    
    func getHeightForRowAtIndexPath(_ indexPath: NSIndexPath, isEstimated: Bool) -> Double {
        var height = 0.0
        if indexPath.section == sectionIndexBanner {
            //            //since cell is only 1 in this section (Image-Slider)
            //            height = HeightImageSlideCell
            
            height = 0.0 // as we have used the headerView for showing FoodImage  //header
        }
        else if indexPath.section == sectionIndexFoodDesc {
            
            let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            switch dataSource["cellID"] as! String {
            case "PYLFoodNameCell":
                height = HeightFoodNameCell
                
            case "PYLFoodDescriptionCell":
                height = isEstimated ? HeightFoodDescriptionCell : Double(UITableViewAutomaticDimension)
                
                let foodDesc = dataSource["foodDesc"] as! String
                if foodDesc.isBlank {
                    height = 0.0
                }
            case "PYLDeliveryModeCell":
                height = HeightDeliveryModeCell
                
            case "PYLFoodSizeCell":
                height = HeightFoodSizeCell
                
                //check if category = desserts, then height will be 0.
                /*
                 var arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
                 let dictQty = arrSectionFoodDesc[rowIndexQty]
                 let foodCategoryName = dictQty["foodCategoryName"] as! String
                 if foodCategoryName == CAT_DESSERTS {
                 height = 0.0
                 }
                 else if let sizeArray = dataSource["size"] as? [String] { //this is general case when category is not dessert and size array as some value.
                 height = height * Double(sizeArray.count)
                 }
                 */
                
                // Above Code has been blocked because, Now we need to Show Size Section For Dessert as well
                if let sizeArray = dataSource["size"] as? [String] { //this is general case when category is not dessert and size array as some value.
                    height = height * Double(sizeArray.count)
                }
                
            case "PYLFoodQuantityCell":
                height = HeightFoodQuantityCell
            case "PYLFoodPreparationTimeCell":
                height = HeightPreparationTimeCell
                
                if let preparationTime = dataSource["preparationTime"] as? String {
                    if preparationTime.isBlank {
                        height = 0.0
                    }
                }
                else {
                    let deliveryTime = dataSource["deliveryTime"] as! String
                    if deliveryTime.isBlank {
                        height = 0.0
                    }
                }
            case "PYLFoodDiscountCell":
                height = HeightFoodDiscountCell
                
                if let strDiscount = dataSource["discount"] as? String {
                    if strDiscount == "0" {
                        height = 0.0
                    }
                }
            case "PYLFoodPriceCell":
                height = HeightFoodPriceCell
            default:
                break
            }
        }
        else if indexPath.section == sectionIndexDefaultAddOn {
            switch indexPath.row {
            case 0:
                let arrSectionAddOns = self.arrData[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
                if arrSectionAddOns.count >= 2 { // as 1 element will always be there, i.e. header cell, so if actual default-addOns is present, then arrSectionAddOns.count will atleast be 2.
                    height = HeightAddOnHeaderCell
                }
                else {
                    height = 0.0
                }
                
            default:
                height = HeightAddOnDefaultValueCell
            }
        }
        else if indexPath.section == sectionIndexAddOn {
            
            switch indexPath.row {
            case 0:
                let arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
                if arrSectionAddOns.count >= 2 { // as 1 element will always be there, i.e. header cell, so if actual addOns is present, then arrSectionAddOns.count will atleast be 2.
                    height = HeightAddOnHeaderCell
                }
                else {
                    height = 0.0
                }
                
            default:
                height = HeightAddOnValueCell
                let lastRowIndex = (arrData[indexPath.section]["value"] as! Array<AnyObject>).count
                if (indexPath.row == lastRowIndex - 1) {
                    height = height + 20
                }
            }
            
        }
        else if indexPath.section == sectionIndexTotal {
            
            height = HeightSumTotalCell
            var arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
            var dictRow = arrSectionSumTotal[rowIndexTotal]
            let isLoyaltyAvailable = Int(dictRow["isLoyaltyAvailable"] as! String)
            if isLoyaltyAvailable != 0 {
                height = HeightSumTotalLoyalityCell
            }
        }
        return height
    }
    
    //MARK: - API section
    
    func callFoodDetailsAPI() {
        PYLAPIHandler.handler.getFoodDetails(foodID!, success: { (response) in
            //            switch (response["ResponseCode"]) {
            //            case "200":
            //                self.successFoodDetailApi(response)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //            }
            self.offlineOrSuccessResponseHandleFoodDetailApi(response!)
        }, offlineBlock: { (response) in
            self.offlineOrSuccessResponseHandleFoodDetailApi(response!)
        }) { (error) in
            
        }
    }
    
    func callAddToCartAPI() {
        let arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        let foodID = arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String
        let foodSizeID = arrSectionFoodDesc[rowIndexFoodSize]["sizeIdOfSelected"] as! String
        let foodSizeQuantity = arrSectionFoodDesc[rowIndexQty]["quantity"] as! String
        
        //Default-addOns
        var arrSectionDefaultAddOns = self.arrData[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiDefaultAddOn = [[String:String]]()
        for i in 1..<arrSectionDefaultAddOns.count {
            let addOnIsChecked = (arrSectionDefaultAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionDefaultAddOns[i]["addon_id"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionDefaultAddOns[i]["addon_price"]).setAESEncription()
                arrApiDefaultAddOn.append(["addon_id":addOnId,"addon_price":addOnPrice])
            }
        }
        
        //Extra-addOns
        var arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiExtraAddOn = [[String:String]]()
        for i in 1..<arrSectionAddOns.count {
            let addOnIsChecked = (arrSectionAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionAddOns[i]["addon_id"]).setAESEncription()
                let addOnQty = String.getSafeString(arrSectionAddOns[i]["addOnQuantity"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionAddOns[i]["addon_price"]).setAESEncription()
                arrApiExtraAddOn.append(["addon_id":addOnId, "addon_qty":addOnQty,"addon_price":addOnPrice])
            }
        }
        
        //Total
        let arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        let totalPrice = arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String
        let note = arrSectionSumTotal[rowIndexTotal]["note"] as! String
        
        //Now call api
        PYLAPIHandler.handler.addToCart(foodID, note:note, foodItemQty: foodSizeQuantity, foodSizeID: foodSizeID, totalPrice: totalPrice, defaultAddOnArray: arrApiDefaultAddOn, extraAddOnArray: arrApiExtraAddOn, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                
                self.successTasksAddToCartApi(response!)
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
    
    func callAddToCartForComboApi(_ addToCartID:String) {
        
        let arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        let foodID = (arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String).setAESEncription()
        let foodSizeID = (arrSectionFoodDesc[rowIndexFoodSize]["sizeIdOfSelected"] as! String).setAESEncription()
        let foodSizeQuantity = (arrSectionFoodDesc[rowIndexQty]["quantity"] as! String).setAESEncription()
        
        //Default-addOns
        var arrSectionDefaultAddOns = self.arrData[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiDefaultAddOn = [[String:String]]()
        for i in 1..<arrSectionDefaultAddOns.count {
            let addOnIsChecked = (arrSectionDefaultAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionDefaultAddOns[i]["addon_id"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionDefaultAddOns[i]["addon_price"]).setAESEncription()
                arrApiDefaultAddOn.append(["addon_id":addOnId,"addon_price":addOnPrice])
            }
        }
        
        //Extra-addOns
        var arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiExtraAddOn = [[String:String]]()
        for i in 1..<arrSectionAddOns.count {
            let addOnIsChecked = (arrSectionAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionAddOns[i]["addon_id"]).setAESEncription()
                let addOnQty = String.getSafeString(arrSectionAddOns[i]["addOnQuantity"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionAddOns[i]["addon_price"]).setAESEncription()
                arrApiExtraAddOn.append(["addon_id":addOnId, "addon_qty":addOnQty,"addon_price":addOnPrice])
            }
        }
        
        //Total
        let arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        let totalPrice = arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String
        let note = (arrSectionSumTotal[rowIndexTotal]["note"] as! String).setAESEncription()
        let dictFood: [String:AnyObject] = ["food_id":foodID as AnyObject,"food_size_id":foodSizeID as AnyObject,"note":note as AnyObject,"default_addon_details":arrApiDefaultAddOn as AnyObject,"extra_addon_details":arrApiExtraAddOn as AnyObject,"qty":foodSizeQuantity as AnyObject]
        debugPrint(dictFood)
        
        //Now call api
        PYLAPIHandler.handler.addToCartWithCombo(addToCartID, comboTakingOrNot: false, totalPrice: totalPrice, foodDetailsArray: [dictFood], comboDetailsArray: [], success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue) //commented to stop toast 'added to cart successfully'
                self.successTasksAddToCartForComboApi(response!)
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
    
    func callEditCartApi() {
        
        let arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        let foodID = (arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String).setAESEncription()
        let foodUniqueID = (arrSectionFoodDesc[rowIndexFoodName]["foodUniqueID"] as! String).setAESEncription()
        let foodSizeID = (arrSectionFoodDesc[rowIndexFoodSize]["sizeIdOfSelected"] as! String).setAESEncription()
        let foodSizeQuantity = (arrSectionFoodDesc[rowIndexQty]["quantity"] as! String).setAESEncription()
        
        //Default-addOns
        var arrSectionDefaultAddOns = self.arrData[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiDefaultAddOn = [[String:String]]()
        for i in 1..<arrSectionDefaultAddOns.count {
            let addOnIsChecked = (arrSectionDefaultAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionDefaultAddOns[i]["addon_id"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionDefaultAddOns[i]["addon_price"]).setAESEncription()
                arrApiDefaultAddOn.append(["addon_id":addOnId,"addon_price":addOnPrice])
            }
        }
        
        //Extra-addOns
        var arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        var arrApiExtraAddOn = [[String:String]]()
        for i in 1..<arrSectionAddOns.count {
            let addOnIsChecked = (arrSectionAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnId = String.getSafeString(arrSectionAddOns[i]["addon_id"]).setAESEncription()
                let addOnQty = String.getSafeString(arrSectionAddOns[i]["addOnQuantity"]).setAESEncription()
                let addOnPrice = String.getSafeString(arrSectionAddOns[i]["addon_price"]).setAESEncription()
                arrApiExtraAddOn.append(["addon_id":addOnId, "addon_qty":addOnQty,"addon_price":addOnPrice])
            }
        }
        
        //Total
        let arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        let totalPrice = (arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String).setAESEncription()
        let note = (arrSectionSumTotal[rowIndexTotal]["note"] as! String).setAESEncription()
        let dictFood: [String:AnyObject] = ["food_id":foodID as AnyObject,"food_unique_id":foodUniqueID as AnyObject,"qty":foodSizeQuantity as AnyObject,"food_size_id":foodSizeID as AnyObject,"note":note as AnyObject,"total_price":totalPrice as AnyObject,"default_addon_details":arrApiDefaultAddOn as AnyObject,"extra_addon_details":arrApiExtraAddOn as AnyObject]
        debugPrint(dictFood)
        
        //Now call api
        PYLAPIHandler.handler.editCart(dictFood, dictComboDetails:[:], success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                let title = response?["Responsedetails"].stringValue
                if title != "success" {
                    self.view.showToastWithMessage((response?["Responsedetails"].stringValue)!)
                }
                self.successTasksEditCartApi(response!)
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
    
    func successTasksEditCartApi(_ response: JSON) {
        _ = PYLNavigationHelper.helper.navigationController?.popViewController(animated: true)
    }
    
    func successTasksAddToCartForComboApi(_ response: JSON) {
        //analytics
        let arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        let foodID = arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String
        let arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        let totalPrice = arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String
        trackAddedToCartForAnalytics(foodID: foodID, price: totalPrice.toDoubleWithRoundOfUpToTwoDecimal()!)
        //--analytics
        
        self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyCartViewController.self))
    }
    
    func successTasksAddToCartApi(_ response: JSON) {
        debugPrint(response.dictionaryObject!)
        
        let arrCombos = response["combo_details"].arrayObject!
        if arrCombos.count > 0 {
            PYLComboPopUpControllerViewController.showComboPopUp(self, dataArray: response["combo_details"].arrayObject! as [AnyObject]) { (isChosen, chosenComboDict) in
                guard isChosen else {
                    //code when there is no combo for food-item
                    self.callAddToCartForComboApi(response["add_to_cart_id"].string!)
                    return }
                debugPrint(chosenComboDict)
                let comboFoodDetailsVc = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLComboFoodDetailsViewController.self)) as! PYLComboFoodDetailsViewController
                comboFoodDetailsVc.comboDetailsDictionary = chosenComboDict
                comboFoodDetailsVc.totalSeletedItems = self.selectCountItems
                comboFoodDetailsVc.addToCartID = response["add_to_cart_id"].string!
                self.removeViewControllerFromNavigationStack(String(describing: comboFoodDetailsVc))
                PYLNavigationHelper.helper.navigationController?.pushViewController(comboFoodDetailsVc, animated: true)
            }
        }
        else {
            //code when there is no combo for food-item
            
            //analytics
            let arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
            let foodID = arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String
            let arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
            let totalPrice = arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String
            trackAddedToCartForAnalytics(foodID: foodID, price: totalPrice.toDoubleWithRoundOfUpToTwoDecimal()!)
            //--analytics
            
            //            self.view.showToastWithMessage(ITEM_ADDED_TO_CART) //commented to stop toast 'added to cart successfully'
            self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyCartViewController.self))
        }
        
    }
    
    func successFoodDetailApi(_ response: JSON) {
        
        foodDetailsDictionary =  response.dictionaryObject! as [String : AnyObject]
        debugPrint(foodDetailsDictionary)
        if previousVcType == vcType.kMyCart {
            //set food_uniqueID from edit-cart dict to normal fooddetail dict, so that when size changes, this value doen't become nil.
            foodDetailsDictionary["food_unique_id"] = editFoodDetailsDictionary["food_unique_id"]
            //prepare the changed array for sizes
            var foodSizArray:[[String:AnyObject]] = foodDetailsDictionary["food_size_details"] as! [[String:AnyObject]]
            let editFoodSizeID = editFoodDetailsDictionary["food_size_id"] as! String
            var sizeIndex = 0
            for var dict in foodSizArray {
                let foodSizeID = dict["food_size_id"] as! String
                if foodSizeID == editFoodSizeID {
                    //prepare and set the changed size-dict to the size-array.
                    dict["default_addon_details"] = editFoodDetailsDictionary["default_addon_details"]
                    // may be
                    foodSizArray[sizeIndex] = dict
                    break
                }
                sizeIndex += 1
            }
            //add a new key 'food_size_details' which stores the new size array.
            editFoodDetailsDictionary["food_size_details"] = foodSizArray as AnyObject?
            self.loadEditedDataWithIndex(sizeIndex, fromDictionary: editFoodDetailsDictionary)
        }
        else {
            
            self.loadDataWithIndex(0)
        }
    }
    
    func offlineOrSuccessResponseHandleFoodDetailApi(_ response: JSON) {
        switch (response["ResponseCode"]) {
        case "200":
            self.successFoodDetailApi(response)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    func loadDataWithIndex(_ index:Int) {
        
        arrData.removeAll()
        //section-1
        let image = String.getSafeString(foodDetailsDictionary["food_item_img_url"]).getAESDecryption()
        let arrFoodImage = [["image":image,"title":"","price":""]]
        let arrSectionFoodImage = [["selectedIndex":"","images":arrFoodImage]]
        arrData.append(["sectionName":"Food Image" as AnyObject,"value":arrSectionFoodImage as AnyObject])
        
        //section-2
        let foodName = String.getSafeString(foodDetailsDictionary["food_name"]).getAESDecryption()
        let foodID = String.getSafeString(foodDetailsDictionary["food_id"]).getAESDecryption()
        let prepareTime = String.getSafeString(foodDetailsDictionary["food_item_preparation_time"]).getAESDecryption()
        let deliveryTime = String.getSafeString(foodDetailsDictionary["food_item_delivery_time"]).getAESDecryption() // is not coming, but must come.
        let isNew = String.getSafeString(foodDetailsDictionary["food_item_is_new"]).getAESDecryption()
        let foodDesc = String.getSafeString(foodDetailsDictionary["food_desc"]).getAESDecryption()
        let foodCategory = String.getSafeString(foodDetailsDictionary["category_name"]).getAESDecryption()
        
        let dineIn = String.getSafeString(foodDetailsDictionary["food_item_dine_in"]).getAESDecryption()
        let takeaway = String.getSafeString(foodDetailsDictionary["food_item_take_away"]).getAESDecryption()
        let delivery = String.getSafeString(foodDetailsDictionary["food_item_delivery"]).getAESDecryption()
        
        let foodSizArray:[AnyObject] = foodDetailsDictionary["food_size_details"] as! [AnyObject]
        var tempSizeArray = [String]()
        for i in 0..<foodSizArray.count {
            var tempDict: [String:AnyObject] = foodSizArray[i] as! [String:AnyObject]
            let sizename = String.getSafeString(tempDict["food_size_name"]).getAESDecryption()
            tempSizeArray.append(sizename)
        }
        
        let selectedSizeDict:[String:AnyObject] = foodSizArray[index] as! [String : AnyObject]
        var discount = String.getSafeString(selectedSizeDict["food_size_discount_amount"]).getAESDecryption()
        discount = discount.isBlank ? "0" : discount
        let basicPrice = String.getSafeString(selectedSizeDict["food_size_price"]).getAESDecryption()
        let sizeIdOfSelected = String.getSafeString(selectedSizeDict["food_size_id"]).getAESDecryption()
        
        let deliveryMode = [["deliveryType":"Dine in","deliveryStatus":dineIn],["deliveryType":"Take Away","deliveryStatus":takeaway],["deliveryType":"Delivery","deliveryStatus":delivery]]
        
        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"isNew":isNew,"cellID":"PYLFoodNameCell"],["foodDesc":foodDesc,"cellID":"PYLFoodDescriptionCell"],["deliveryMode":deliveryMode,"cellID":"PYLDeliveryModeCell"],["size":tempSizeArray,"sizeIndex":"\(index)","sizeIdOfSelected":sizeIdOfSelected,"cellID":"PYLFoodSizeCell"],["foodCategoryName":foodCategory,"quantity":"1","cellID":"PYLFoodQuantityCell"],["attribute":"Preparation Time","preparationTime":prepareTime,"cellID":"PYLFoodPreparationTimeCell"],["attribute":"Delivery Time","deliveryTime":deliveryTime,"cellID":String(describing: PYLFoodPreparationTimeCell.self)],["attribute":"Discount","discount":discount,"cellID":String(describing: PYLFoodDiscountCell.self)],["attribute":"Price","price":basicPrice,"basicPrice":basicPrice,"cellID":"PYLFoodPriceCell"]] as [Any]
        
        arrData.append(["sectionName":"Food Description" as AnyObject,"value":arrSectionFoodDesc as AnyObject])
        
        //section-3
        var addonDefaultArray = [AnyObject]()
        if let tempArr = selectedSizeDict["default_addon_details"] as? [AnyObject] {  // use of selected-size dict (for default-addOns)
            addonDefaultArray = tempArr
        }
        var maxDefaultAddOnOfSelected = String.getSafeString(selectedSizeDict["food_size_default_addon"]).getAESDecryption() //needed in add-on section
        var maxTotalAddOnOfSelected = String.getSafeString(selectedSizeDict["food_size_max_addon"]).getAESDecryption() //needed in add-on section
        maxDefaultAddOnOfSelected = maxDefaultAddOnOfSelected.isBlank ? "0" : maxDefaultAddOnOfSelected
        maxTotalAddOnOfSelected = maxTotalAddOnOfSelected.isBlank ? "0" : maxTotalAddOnOfSelected
        
        var arrSectionDefaultAddOns = [Any]()
        arrSectionDefaultAddOns.append(["title":"Default Add-Ons","max":maxDefaultAddOnOfSelected])
        //        var tempdictDefault = [String:String]()
        for i in 0..<addonDefaultArray.count {
            let name = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
            //  let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":"0", "addOnQuantity" : "1"]
            
            let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":"0", "addOnQuantity" : "1", "maxLimit":maxDefaultAddOnOfSelected,"seletedItems":self.selectCountItems!] as [String : AnyObject]
            
            arrSectionDefaultAddOns.append(tempdictDefault)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionDefaultAddOns as AnyObject])
        
        //section-4
        var addonArray = [AnyObject]()
        if let tempArr = foodDetailsDictionary["addon_details"] as? [AnyObject] {
            addonArray = tempArr
        }
        var arrSectionAddOns = [Any]()
        //        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(Int(maxTotalAddOnOfSelected)! - Int(maxDefaultAddOnOfSelected)!)"])
        //todo:
        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(maxTotalAddOnOfSelected)"])
        // add extra-addOns
        for i in 0..<addonArray.count {
            let name = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
            let tempdict = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":"0", "addOnQuantity" : "1"]
            arrSectionAddOns.append(tempdict)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionAddOns as AnyObject])
        
        //section-5
        let isLoyaltyAvailable = String.getSafeString(foodDetailsDictionary["is_loyalty_available"]).getAESDecryption()
        let loyaltyPercentage = String.getSafeString(foodDetailsDictionary["loyalty_percentage"]).getAESDecryption()
        let loyaltyUnitValue = String.getSafeString(foodDetailsDictionary["loyalty_unit_value"]).getAESDecryption()
        
        let arrSectionSumTotal = [["note":strNote,"totalPrice":"0","addToCartText":"Add to Cart","isLoyaltyAvailable":isLoyaltyAvailable,"loyaltyPercentage":loyaltyPercentage,"loyaltyUnitValue":loyaltyUnitValue,"loyaltyPoints":"0","loyaltyCash":"0"]]
        arrData.append(["sectionName":"Sum-Total" as AnyObject,"value":arrSectionSumTotal as AnyObject])
        calculateTotalPriceAndStoreInMainArray()
        calculateLoyaltyPointsAndStoreInMainArray()
        tableViewForm.reloadData()
    }
    
    // MARK: Cheak Box Button Action
    
    
    
    func loadEditedDataWithIndex(_ sizeIndex: Int, fromDictionary foodDict:[String:AnyObject]) {
        
        arrData.removeAll()
        //section-1
        let image = String.getSafeString(foodDict["food_item_img_url"]).getAESDecryption()
        let arrFoodImage = [["image":image,"title":"","price":""]]
        let arrSectionFoodImage = [["selectedIndex":"","images":arrFoodImage]]
        arrData.append(["sectionName":"Food Image" as AnyObject,"value":arrSectionFoodImage as AnyObject])
        
        //section-2
        let foodName = String.getSafeString(foodDict["food_name"]).getAESDecryption()
        let foodID = String.getSafeString(foodDict["food_id"]).getAESDecryption()
        let foodUniqueID = String.getSafeString(foodDict["food_unique_id"]).getAESDecryption()
        let prepareTime = String.getSafeString(foodDict["food_item_preparation_time"]).getAESDecryption()
        let deliveryTime = String.getSafeString(foodDict["food_item_delivery_time"]).getAESDecryption() // is not coming, but must come.
        let isNew = String.getSafeString(foodDict["food_item_is_new"]).getAESDecryption()
        var foodQuantity = String.getSafeString(foodDict["qty"]).getAESDecryption()
        foodQuantity = foodQuantity.isBlank ? "1" : foodQuantity
        let foodDesc = String.getSafeString(foodDict["food_desc"]).getAESDecryption()
        let foodCategory = String.getSafeString(foodDict["category_name"]).getAESDecryption()
        
        let dineIn = String.getSafeString(foodDict["food_item_dine_in"]).getAESDecryption()
        let takeaway = String.getSafeString(foodDict["food_item_take_away"]).getAESDecryption()
        let delivery = String.getSafeString(foodDict["food_item_delivery"]).getAESDecryption()
        //        let sizename = String.getSafeString(foodDict["food_size_name"]).getAESDecryption()
        //        let tempSizeArray = [sizename]
        
        //        var discount = String.getSafeString(foodDict["food_size_discount_amount"]).getAESDecryption()
        //        discount = discount.isBlank ? "0" : discount
        //        let basicPrice = String.getSafeString(foodDict["food_size_price"]).getAESDecryption()
        //        let sizeIdOfSelected = String.getSafeString(foodDict["food_size_id"]).getAESDecryption()
        
        //
        let foodSizArray:[AnyObject] = foodDict["food_size_details"] as! [AnyObject]
        var tempSizeArray = [String]()
        for i in 0..<foodSizArray.count {
            var tempDict: [String:AnyObject] = foodSizArray[i] as! [String:AnyObject]
            let sizename = String.getSafeString(tempDict["food_size_name"]).getAESDecryption()
            tempSizeArray.append(sizename)
        }
        
        let selectedSizeDict:[String:AnyObject] = foodSizArray[sizeIndex] as! [String : AnyObject]
        var discount = String.getSafeString(selectedSizeDict["food_size_discount_amount"]).getAESDecryption()
        discount = discount.isBlank ? "0" : discount
        let basicPrice = String.getSafeString(selectedSizeDict["food_size_price"]).getAESDecryption()
        let sizeIdOfSelected = String.getSafeString(selectedSizeDict["food_size_id"]).getAESDecryption()
        //
        
        let deliveryMode = [["deliveryType":"Dine in","deliveryStatus":dineIn],["deliveryType":"Take Away","deliveryStatus":takeaway],["deliveryType":"Delivery","deliveryStatus":delivery]]
        
        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"foodUniqueID":foodUniqueID,"isNew":isNew,"cellID":"PYLFoodNameCell"],["foodDesc":foodDesc,"cellID":"PYLFoodDescriptionCell"],["deliveryMode":deliveryMode,"cellID":"PYLDeliveryModeCell"],["size":tempSizeArray,"sizeIndex":"\(sizeIndex)","sizeIdOfSelected":sizeIdOfSelected,"cellID":"PYLFoodSizeCell"],["foodCategoryName":foodCategory,"quantity":foodQuantity,"cellID":"PYLFoodQuantityCell"],["attribute":"Preparation Time","preparationTime":prepareTime,"cellID":"PYLFoodPreparationTimeCell"],["attribute":"Delivery Time","deliveryTime":deliveryTime,"cellID":String(describing: PYLFoodPreparationTimeCell.self)],["attribute":"Discount","discount":discount,"cellID":String(describing: PYLFoodDiscountCell.self)],["attribute":"Price","price":basicPrice,"basicPrice":basicPrice,"cellID":"PYLFoodPriceCell"]] as [Any]
        
        arrData.append(["sectionName":"Food Description" as AnyObject,"value":arrSectionFoodDesc as AnyObject])
        
        //section-3
        var addonDefaultArray = [AnyObject]()
        if let tempArr = selectedSizeDict["default_addon_details"] as? [AnyObject] {  // use of selected-size dict (for default-addOns)
            addonDefaultArray = tempArr
        }
        var maxDefaultAddOnOfSelected = String.getSafeString(selectedSizeDict["food_size_default_addon"]).getAESDecryption() //needed in add-on section
        var maxTotalAddOnOfSelected = String.getSafeString(selectedSizeDict["food_size_max_addon"]).getAESDecryption() //needed in add-on section
        maxDefaultAddOnOfSelected = maxDefaultAddOnOfSelected.isBlank ? "0" : maxDefaultAddOnOfSelected
        maxTotalAddOnOfSelected = maxTotalAddOnOfSelected.isBlank ? "0" : maxTotalAddOnOfSelected
        
        var arrSectionDefaultAddOns = [Any]()
        arrSectionDefaultAddOns.append(["title":"Default Add-Ons","max":maxDefaultAddOnOfSelected])
        //        var tempdictDefault = [String:String]()
        for i:Int in 0..<addonDefaultArray.count {
            let name = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
            var isSelected = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["is_selected"]).getAESDecryption()
            isSelected = isSelected.lowercased() == "true" ? "1" : "0"
            //let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":isSelected, "addOnQuantity" : "1"]
            // may be
            let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":isSelected, "addOnQuantity" : "1", "maxLimit":maxDefaultAddOnOfSelected,"seletedItems":self.selectCountItems!] as [String : AnyObject]
            
            arrSectionDefaultAddOns.append(tempdictDefault)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionDefaultAddOns as AnyObject])
        
        //section-4
        var addonArray = [AnyObject]()
        if let tempArr = foodDict["extra_addon_details"] as? [AnyObject] {
            addonArray = tempArr
        }
        else if let tempArr = foodDict["addon_details"] as? [AnyObject] {
            addonArray = tempArr
        }
        var arrSectionAddOns = [Any]()
        //        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(Int(maxTotalAddOnOfSelected)! - Int(maxDefaultAddOnOfSelected)!)"])
        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(Int(maxTotalAddOnOfSelected)!)"])
        
        // add extra-addOns (no need to add default-addons here, as it will automatically come in this section in case of edit-cart)
        for i in 0..<addonArray.count {
            let name = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
            var isSelected = String.getSafeString((addonArray[i] as! [String:AnyObject])["is_selected"]).getAESDecryption()
            isSelected = isSelected.lowercased() == "true" ? "1" : "0"
            var addOnQuantity = String.getSafeString( (addonArray[i] as! [String:AnyObject])["qty"]).getAESDecryption()
            addOnQuantity = (addOnQuantity.isBlank || isSelected == "0") ? "1" : addOnQuantity
            let tempdict = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":isSelected, "addOnQuantity" : addOnQuantity]
            arrSectionAddOns.append(tempdict)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionAddOns as AnyObject])
        
        //section-5
        let isLoyaltyAvailable = String.getSafeString(foodDetailsDictionary["is_loyalty_available"]).getAESDecryption()
        let loyaltyPercentage = String.getSafeString(foodDetailsDictionary["loyalty_percentage"]).getAESDecryption()
        let loyaltyUnitValue = String.getSafeString(foodDetailsDictionary["loyalty_unit_value"]).getAESDecryption()
        
        strNote = String.getSafeString(foodDict["note"]).getAESDecryption()
        let arrSectionSumTotal = [["note":strNote,"totalPrice":"0","addToCartText":"Update Cart","isLoyaltyAvailable":isLoyaltyAvailable,"loyaltyPercentage":loyaltyPercentage,"loyaltyUnitValue":loyaltyUnitValue,"loyaltyPoints":"0","loyaltyCash":"0"]]
        arrData.append(["sectionName":"Sum-Total" as AnyObject,"value":arrSectionSumTotal as AnyObject])
        calculateTotalPriceAndStoreInMainArray()
        calculateLoyaltyPointsAndStoreInMainArray()
        tableViewForm.reloadData()
    }
    
    func calculateTotalPriceAndStoreInMainArray() {
        
        var arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        //        let foodBasicPrice = Double(arrSectionFoodDesc[rowIndexBilling]["basicPrice"] as! String)
        let foodBasicPrice = Double(arrSectionFoodDesc[rowIndexPrice]["basicPrice"] as! String)
        let foodDiscount = Double(arrSectionFoodDesc[rowIndexDiscount]["discount"] as! String)
        let foodQuantity = Double(arrSectionFoodDesc[rowIndexQty]["quantity"] as! String)
        //        var sumTotal = Int(foodBasicPrice! * foodQuantity! * ((100 - foodDiscount!) * 0.01))
        //        var sumTotal = Int(foodBasicPrice! * ((100 - foodDiscount!) * 0.01))
        var sumTotal = foodBasicPrice! * ((100 - foodDiscount!) * 0.01)
        
        let arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        for i in 1..<arrSectionAddOns.count {
            let addOnIsChecked = (arrSectionAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnPrice = Int(arrSectionAddOns[i]["addon_price"] as! String)
                let addOnQuantity = Int(arrSectionAddOns[i]["addOnQuantity"] as! String)
                //                sumTotal += (addOnPrice! * addOnQuantity!)
                sumTotal += Double(addOnPrice! * addOnQuantity!)
            }
        }
        
        //Set the total price
        var arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        var dictRow = arrSectionSumTotal[rowIndexTotal]
        //        dictRow["totalPrice"] = "\(sumTotal * Int(foodQuantity!))"
        dictRow["totalPrice"] = "\(sumTotal * foodQuantity!)" as AnyObject?
        arrSectionSumTotal[rowIndexTotal] = dictRow
        self.arrData[sectionIndexTotal]["value"] = arrSectionSumTotal as AnyObject?
        
        //Change the 'price' key in foodDesc section = basicPrice x quantity
        //This part is necessary to be executed when this function gets called when foodQty is being updated, and not necessary for addOns cases.
        var dictPrice = arrSectionFoodDesc[rowIndexPrice]
        dictPrice["price"] = "\(Int(foodBasicPrice! * foodQuantity!))" as AnyObject?
        arrSectionFoodDesc[rowIndexPrice] = dictPrice
        self.arrData[sectionIndexFoodDesc]["value"] = arrSectionFoodDesc as AnyObject?
    }
    
    func calculateLoyaltyPointsAndStoreInMainArray() {
        
        //check from sectionTotal that loyalty available or not.
        var arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
        var dictRow = arrSectionSumTotal[rowIndexTotal]
        let isLoyaltyAvailable = Int(dictRow["isLoyaltyAvailable"] as! String)
        guard isLoyaltyAvailable != 0 else { return }
        
        //get the basic price and quantity from foodDesc section
        //var arrSectionFoodDesc = self.arrData[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
        //let foodBasicPrice = Double(arrSectionFoodDesc[rowIndexPrice]["basicPrice"] as! String)
        // as per the new requirement peyala points and cash needs to be calculate with the Total Price. So basic pric changes to total price. that's why commented above line.
        let foodBasicPrice = Double(arrSectionSumTotal[rowIndexTotal]["totalPrice"] as! String)
        //let foodQuantity = Double(arrSectionFoodDesc[rowIndexQty]["quantity"] as! String)
        
        //Set the loyalty things in sectionTotal.
        let loyaltyPercentage = Double(dictRow["loyaltyPercentage"] as! String)
        let loyaltyUnitValue = Double(dictRow["loyaltyUnitValue"] as! String)
        //let loyaltyPoints = foodBasicPrice! * foodQuantity! * loyaltyPercentage! * 0.01
        let loyaltyPoints = foodBasicPrice! * loyaltyPercentage! * 0.01
        let loyaltyCash = loyaltyPoints * loyaltyUnitValue!
        //        dictRow["loyaltyPoints"] = "\(Int(loyaltyPoints))"
        //        dictRow["loyaltyCash"] = "\(Int(loyaltyCash))"
        dictRow["loyaltyPoints"] = "\(loyaltyPoints)".toStringWithRoundOfUpToTwoDecimal() as AnyObject?
        dictRow["loyaltyCash"] = "\(loyaltyCash)".toStringWithRoundOfUpToTwoDecimal() as AnyObject?
        arrSectionSumTotal[rowIndexTotal] = dictRow
        self.arrData[sectionIndexTotal]["value"] = arrSectionSumTotal as AnyObject?
    }
    
    
    func checkAddOnValidity() -> Bool {
        var validate = true
        var countDefaultAddOn = 0, countExtraAddOn = 0
        let rowHeaderDefaultAddons = 0, rowHeaderExtraAddons = 0
        
        var arrSectionDefaultAddOns = self.arrData[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        for i in 1..<arrSectionDefaultAddOns.count {
            let addOnIsChecked = (arrSectionDefaultAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnQty = String.getSafeString(arrSectionDefaultAddOns[i]["addOnQuantity"])
                countDefaultAddOn += (Int(addOnQty))!
            }
        }
        
        var arrSectionAddOns = self.arrData[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        for i in 1..<arrSectionAddOns.count {
            let addOnIsChecked = (arrSectionAddOns[i]["checked"] as! String) == "1"
            if addOnIsChecked {
                let addOnQty = String.getSafeString(arrSectionAddOns[i]["addOnQuantity"])
                countExtraAddOn += (Int(addOnQty))!
            }
        }
        
    //get the max values of boths addOns
        let maxDefault = Int(arrSectionDefaultAddOns[rowHeaderDefaultAddons]["max"] as! String)
        let totalAddons = Int(arrSectionAddOns[rowHeaderExtraAddons]["max"] as! String)
        
        if countDefaultAddOn > maxDefault! {
            validate = false
            
            let extraItems = countDefaultAddOn -  maxDefault!
            
            self.view.showToastWithMessage(DEFAULT_EXCEED_LIMIT + " extra \(String(describing:extraItems)) out of \(String(describing: totalAddons!))")
        }
            //        else if countExtraAddOn > maxExtra {
            //            validate = false
            //            self.view.showToastWithMessage(EXTRA_EXCEED_LIMIT)
            //        }
        else if (countExtraAddOn + countDefaultAddOn) > totalAddons! {
            validate = false
            let totalSelectedItems = countExtraAddOn + countDefaultAddOn
           let extraItems = totalSelectedItems -  totalAddons!
            
            let outAddonsItems = totalAddons! - countDefaultAddOn

           // self.view.showToastWithMessage(TOTAL_EXCEED_LIMIT + " extra \(String(describing:extraItems)) out of \(String(describing: totalAddons!))")
           // When 2 Default Add-Ons are selected you can only choose 4 Extra Add-Ons
            if countDefaultAddOn > 0 {
                self.view.showToastWithMessage(("When \(countDefaultAddOn) Default Add-Ons are selected you can only choose \(outAddonsItems) Extra Add-Ons" + "\n" + "Deselect any \(extraItems)  from Extra Add-Ons"), delayTime: 4)
            }else{
                self.view.showToastWithMessage(("You can select only \(String(describing: totalAddons!)) Extra Add-Ons" + "\n" + "Deselect any \(extraItems)  from Extra Add-Ons"), delayTime: 4)
            }
            
            
        }
        
        
        return validate
    }
}

extension PYLFoodDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(getHeightForRowAtIndexPath(indexPath as NSIndexPath, isEstimated: true))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(getHeightForRowAtIndexPath(indexPath as NSIndexPath, isEstimated: false))
    }
    
    //header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = tableViewForm.tableHeaderView as! HeaderView
        headerView.scrollViewDidScroll(scrollView)
    }
}

extension PYLFoodDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrData[section]["value"] as! Array<AnyObject>).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellGlobal = UITableViewCell()
        if indexPath.section == sectionIndexBanner {
            //            //since cell is only 1 in this section (Image-Slider)
            //            let cell = tableView.dequeueReusableCellWithIdentifier(String(PYLImageSlideCell), forIndexPath: indexPath) as! PYLImageSlideCell
            //            cell.datasource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            //            cellGlobal = cell
            
            //header
            // this task is not for cell no. zero, but it is the task of headerView. This is done here
            //as now headerview is doing the task of of cell zero i.e showing FoodImage.
            let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            let imageUrlStr = ((dataSource["images"] as! [[String:String]])[0]["image"])!.replaceSpaceFromURL()
            let headerView = tableViewForm.tableHeaderView as! HeaderView
            headerView.setImagePicWithURLString(imageUrlStr)
        }
        else if indexPath.section == sectionIndexFoodDesc {
            
            
            let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            switch dataSource["cellID"] as! String {
            case "PYLFoodNameCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodNameCell.self), for: indexPath as IndexPath) as! PYLFoodNameCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
                
            case "PYLFoodDescriptionCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodDescriptionCell.self), for: indexPath as IndexPath) as! PYLFoodDescriptionCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
                
            case "PYLDeliveryModeCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLDeliveryModeCell.self), for: indexPath as IndexPath) as! PYLDeliveryModeCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
                
            case "PYLFoodSizeCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodSizeCell.self), for: indexPath as IndexPath) as! PYLFoodSizeCell
                cell.cellHeightForSingle = HeightFoodSizeCell
                cell.datasource = dataSource as AnyObject!
                //                if previousVcType == vcType.kFoodList {
                //                    cell.selectSizeButton = {  (selectedIndex) in
                //                        self.loadDataWithIndex(Int(selectedIndex)!)
                //                    }
                //                }
                
                cell.selectSizeButton = {  (selectedIndex) in
                    if self.previousVcType == vcType.kFoodList {
                        self.loadDataWithIndex(Int(selectedIndex)!)
                    }
                    else {
                        self.loadEditedDataWithIndex(Int(selectedIndex)!, fromDictionary: self.foodDetailsDictionary)
                    }
                }
                
                cellGlobal = cell
            case "PYLFoodQuantityCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodQuantityCell.self), for: indexPath as IndexPath) as! PYLFoodQuantityCell
                cell.datasource = dataSource as AnyObject!
                cell.quantityUpdateBlock = { (quantity) in
                    // maybe here
                    var arrSectionBilling = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                    var dictRow = arrSectionBilling[indexPath.row]
                    dictRow["quantity"] = "\(quantity)" as AnyObject?
                    arrSectionBilling[indexPath.row] = dictRow
                    self.arrData[indexPath.section]["value"] = arrSectionBilling as AnyObject?
                    self.calculateTotalPriceAndStoreInMainArray()
                    self.calculateLoyaltyPointsAndStoreInMainArray()
                    tableView.reloadRows(at: [IndexPath(row: self.rowIndexPrice, section: self.sectionIndexFoodDesc),IndexPath(row: self.rowIndexTotal, section: self.sectionIndexTotal)], with: .none)
                }
                cellGlobal = cell
            case "PYLFoodPreparationTimeCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodPreparationTimeCell.self), for: indexPath as IndexPath) as! PYLFoodPreparationTimeCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
            case "PYLFoodDiscountCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodDiscountCell.self), for: indexPath as IndexPath) as! PYLFoodDiscountCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
            case "PYLFoodPriceCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodPriceCell.self), for: indexPath) as! PYLFoodPriceCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
            default:
                break
            }
            
        }
        else if indexPath.section == sectionIndexDefaultAddOn {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PYLAddOnHeaderCell", for: indexPath as IndexPath)
                let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
                let labelTitle = cell.viewWithTag(LabelBaseTag+1) as! UILabel
                labelTitle.text = dataSource["title"] as? String
                let labelDesc = cell.viewWithTag(LabelBaseTag+2) as! UILabel
                labelDesc.text = "Can choose maximum of \(dataSource["max"] as! String)"
                self.limitValue = Int(dataSource["max"] as! String)
                cellGlobal = cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLAddOnDefaultCell.self), for: indexPath as IndexPath) as! PYLAddOnDefaultCell
                cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
                
                cell.checkBoxTapped = { (isChecked) in
                    var arrSectionAddOns = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                    if self.limitValue! == self.selectCountItems {
                        var dictRow = arrSectionAddOns[indexPath.row]
                        if dictRow["checked"] as! String  ==  "1" && isChecked == false{
                            self.selectCountItems! = self.selectCountItems! - 1
                            var dictRow = arrSectionAddOns[indexPath.row]
                            dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
                            dictRow["seletedItems"] =   (self.selectCountItems!) as AnyObject
                            arrSectionAddOns[indexPath.row] = dictRow
                            self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                            
                        else{
                            return
                        }
                    }
                    else{
                        var dictRow = arrSectionAddOns[indexPath.row]
                        if dictRow["checked"] as! String == "1" && isChecked == false{
                            self.selectCountItems! = self.selectCountItems! - 1
                        }
                        else if dictRow["checked"] as! String == "0" && isChecked == true{
                            self.selectCountItems! = self.selectCountItems! + 1
                        }
                        dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
                        dictRow["seletedItems"] =   (self.selectCountItems!) as AnyObject
                        arrSectionAddOns[indexPath.row] = dictRow
                        self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    //                    var dictRow = arrSectionAddOns[indexPath.row]
                    //                    dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
                    //                    arrSectionAddOns[indexPath.row] = dictRow
                    //                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                    //                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                //UI
                if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)  {
                    cell.constraintCurveViewBottom.constant = 4.0 //correct value
                }
                else {
                    cell.constraintCurveViewBottom.constant = 20.0 //this number can be anything, but should be quite greater than 4.
                }
                cellGlobal = cell
            }
            
        }
            
        else if indexPath.section == sectionIndexAddOn {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PYLAddOnHeaderCell", for: indexPath)
                let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
                let labelTitle = cell.viewWithTag(LabelBaseTag+1) as! UILabel
                labelTitle.text = dataSource["title"] as? String
                let labelDesc = cell.viewWithTag(LabelBaseTag+2) as! UILabel
                labelDesc.text = "Can choose all total add-Ons of \(dataSource["max"] as! String)"
                cellGlobal = cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLAddOnValueCell.self), for: indexPath) as! PYLAddOnValueCell
                cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
                cell.addOnQuantityUpdateBlock = { (quantity) in
                    
                    var arrSectionAddOns = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                    var dictRow = arrSectionAddOns[indexPath.row]
                    dictRow["addOnQuantity"] = "\(quantity)" as AnyObject?
                    arrSectionAddOns[indexPath.row] = dictRow
                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                    self.calculateTotalPriceAndStoreInMainArray()
                    self.calculateLoyaltyPointsAndStoreInMainArray()
                    tableView.reloadRows(at: [IndexPath(row: self.rowIndexTotal, section: self.sectionIndexTotal)], with: .none)
                }
                cell.checkBoxTapped = { (isChecked) in
                    var arrSectionAddOns = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                    var dictRow = arrSectionAddOns[indexPath.row]
                    dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
                    arrSectionAddOns[indexPath.row] = dictRow
                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                    self.calculateTotalPriceAndStoreInMainArray()
                    self.calculateLoyaltyPointsAndStoreInMainArray()
                    tableView.reloadRows(at: [indexPath,IndexPath(row: self.rowIndexTotal, section: self.sectionIndexTotal)], with: .none)
                }
                //UI
                if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)  {
                    cell.constraintCurveViewBottom.constant = 4.0 //correct value
                }
                else {
                    cell.constraintCurveViewBottom.constant = 20.0 //this number can be anything, but should be quite greater than 4.
                }
                cellGlobal = cell
            }
        }
        else if indexPath.section == sectionIndexTotal {
            
            //only 1 cell in this section
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLSumTotalCell.self), for: indexPath) as! PYLSumTotalCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.textFieldEndedEditing = { (fieldValue) in
                var dict = cell.datasource as! Dictionary<String,AnyObject>
                self.strNote = fieldValue
                dict["note"] = self.strNote as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            // made this label clickable and redirect to My Peyala Cash Screen
            cell.labelLoyalityValue.isUserInteractionEnabled = true
            cell.labelLoyalityValue.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.redirectToMyPeyalaCash)))
            cell.addTocart = {
                self.view.endEditing(true)
                guard self.checkAddOnValidity() else { return }
                
                if self.previousVcType == vcType.kMyCart {
                    self.callEditCartApi()
                }
                else {
                    if IS_USER_LOGIN() == false{
                        
                        self.present(UIAlertController.showStandardAlertWith(kAppDetailedTitle, alertText: ALERT_MESSAGE_SIGN_IN, cancelTitle: OK, doneTitle: CANCEL, selected_: { (index) in
                            
                            if index == 0 {
                                
                                self.goToLoginScreen({ (success) in
                                    self.callAddToCartAPI()
                                })
                            } else {
                                // stay on this page
                            }
                            
                        }), animated: true, completion: nil)
                    }
                    else {
                        self.callAddToCartAPI()
                    }
                }
            }
            cellGlobal = cell
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
