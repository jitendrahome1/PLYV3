//
//  PYLComboFoodDetailsViewController.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

//let HeightComboBillingCell = 46.0
//let HeightComboFoodDescCell = 105.0

class PYLComboFoodDetailsViewController: PYLBaseViewController {
    
    enum vcType:Int {
        case kMyCart = 1
        case kFoodDetails = 2
    }
    
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewForm: UITableView!
    var selectCountItems: Int?
    
    var limitValue: Int?
    var comboDetailsDictionary = [String: AnyObject]()
    var addToCartID = ""
    var totalSeletedItems: Int?
    var arrComboFoods:[AnyObject] = []
    var arrData:[[String:AnyObject]] = []
    var foodDetailsDictionary = [String: AnyObject]()
    var previousVcType:vcType = PYLComboFoodDetailsViewController.vcType.kFoodDetails
    var currentFoodIndex = 0, totalComboPrice = 0, comboQuantity = 1
    
    //hard-code usage
    let sectionIndexBanner = 0, sectionIndexFoodDesc = 1, sectionIndexDefaultAddOn = 2, sectionIndexAddOn = 3, sectionIndexTotal = 4
    let rowIndexTotal = 0, rowIndexFoodName = 0, rowIndexFoodSize = 2, rowIndexPrice = 3
    //    let rowIndexMainFoodDetails = 0, rowIndexBilling = 1,
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        
    
        setupUI()
        initializeValues()
        
        if previousVcType == vcType.kMyCart {
            self.title = "EDIT CART"
        } else {
            self.title = "FOOD DETAILS"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //selectCountItems = 0
        //self.navigationController!.navigationBar.layer.zPosition = 1000.0
        trackScreenForAnalyticsWithName(COMBO_DETAILS_SCREEN, isGoogle: true, isFB: true)
    }
    
    // MARK: - User Defined Function
    func setupUI() {
        self.view.backgroundColor = UIColor(red: 243/255.0, green: 232/255.0, blue: 207/255.0, alpha: 1)
        tableViewForm.backgroundColor = UIColor.clear
        sizeHeaderToFit(tableViewForm)  //header
    }
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
        
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        //        self.title = "FOOD DETAILS"
    }
    
    func initializeValues() {
        debugPrint(comboDetailsDictionary)
           selectCountItems = 0
        
        if previousVcType == vcType.kMyCart {
            var strComboPrice = String.getSafeString(comboDetailsDictionary["total_price"]).getAESDecryption()
            strComboPrice = strComboPrice.isBlank ? "0" : strComboPrice
            //totalComboPrice = Int(strComboPrice)!
            let totalComboPriceDouble = strComboPrice.toDouble()
            totalComboPrice = Int(totalComboPriceDouble!)
            var strComboQty = String.getSafeString(comboDetailsDictionary["combo_qty"]).getAESDecryption()
            strComboQty = strComboQty.isBlank ? "1" : strComboQty
            comboQuantity = Int(strComboQty)!
            self.loadEditCartFreshDataWithIndex(currentFoodIndex)
        }
        else {
            var strComboPrice = String.getSafeString(comboDetailsDictionary["combo_price"]).getAESDecryption()
            strComboPrice = strComboPrice.isBlank ? "0" : strComboPrice
            //totalComboPrice = Int(strComboPrice)!
            let totalComboPriceDouble = strComboPrice.toDouble()
            totalComboPrice = Int(totalComboPriceDouble!)
            comboQuantity = 1
            self.loadFreshDataWithIndex(currentFoodIndex)
        }
    }
    
    func loadFreshDataWithIndex(_ index:Int) {
        self.selectCountItems = 0
        let arrApiFoodDetail = comboDetailsDictionary["food_details"] as! [[String:AnyObject]]
        foodDetailsDictionary = arrApiFoodDetail[index]
        arrData.removeAll()
        //section-1
        let image = String.getSafeString(foodDetailsDictionary["food_item_img_url"]).getAESDecryption()
        let arrFoodImage = [["image":image,"title":"","price":""]]
        let arrSectionFoodImage = [["selectedIndex":"","images":arrFoodImage]]
        arrData.append(["sectionName":"Food Image" as AnyObject,"value":arrSectionFoodImage as AnyObject])
        
        //section-2
        let foodName = String.getSafeString(foodDetailsDictionary["food_name"]).getAESDecryption()
        let foodID = String.getSafeString(foodDetailsDictionary["food_id"]).getAESDecryption()
        let foodDesc = String.getSafeString(foodDetailsDictionary["food_desc"]).getAESDecryption()
        let sizename = String.getSafeString(foodDetailsDictionary["food_size_name"]).getAESDecryption()
        let tempSizeArray = [sizename]
        
        var strComboPrice = String.getSafeString(comboDetailsDictionary["combo_price"]).getAESDecryption()
        strComboPrice = strComboPrice.isBlank ? "0" : strComboPrice
        let sizeIdOfSelected = String.getSafeString(foodDetailsDictionary["food_size_id"]).getAESDecryption()
        let sizeIndex = 0  // it is always 0 for this screen.
        //        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"size":tempSizeArray,"sizeIndex":"\(sizeIndex)"],["basicPrice":strComboPrice,"sizeIdOfSelected":sizeIdOfSelected]]
        
        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"isNew":"0","cellID":"PYLFoodNameCell"],["foodDesc":foodDesc,"cellID":"PYLFoodDescriptionCell"],["size":tempSizeArray,"sizeIndex":"\(sizeIndex)","sizeIdOfSelected":sizeIdOfSelected,"cellID":"PYLFoodSizeCell"],["attribute":"Price","price":strComboPrice,"basicPrice":strComboPrice,"cellID":"PYLFoodPriceCell"]] as [Any]
        arrData.append(["sectionName":"Food Description" as AnyObject,"value":arrSectionFoodDesc as AnyObject])
        
        //section-3
        var addonDefaultArray = [AnyObject]()
        if let tempArr = foodDetailsDictionary["default_addon_details"] as? [AnyObject] {  // use of selected-size dict (for default-addOns)
            addonDefaultArray = tempArr
        }
        var maxDefaultAddOnOfSelected = String.getSafeString(foodDetailsDictionary["default_addon"]).getAESDecryption() //needed in add-on section
        var maxTotalAddOnOfSelected = String.getSafeString(foodDetailsDictionary["max_addon"]).getAESDecryption() //needed in add-on section
        maxDefaultAddOnOfSelected = maxDefaultAddOnOfSelected.isBlank ? "0" : maxDefaultAddOnOfSelected
        maxTotalAddOnOfSelected = maxTotalAddOnOfSelected.isBlank ? "0" : maxTotalAddOnOfSelected
        
        var arrSectionDefaultAddOns = [Any]()
        arrSectionDefaultAddOns.append(["title":"Default Add-Ons","max":maxDefaultAddOnOfSelected])
        //        var tempdictDefault = [String:String]()
        for i:Int in 0..<addonDefaultArray.count {
            let name = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonDefaultArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
           // let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":"0", "addOnQuantity" : "1"]
            let tempdictDefault = ["addon_id":addOnid as AnyObject,"addon_name":name as AnyObject,"addon_price":price as AnyObject,"checked":"0" as AnyObject, "addOnQuantity" : "1" as AnyObject, "maxLimit":maxDefaultAddOnOfSelected as AnyObject,"seletedItems":totalSeletedItems!] as [String : AnyObject]
            
            arrSectionDefaultAddOns.append(tempdictDefault)
            
            
            //maybe
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionDefaultAddOns as AnyObject])
        
        //section-4
        var addonArray = [AnyObject]()
        if let tempArr = foodDetailsDictionary["extra_addon_details"] as? [AnyObject] {
            addonArray = tempArr
        }
        var arrSectionAddOns = [Any]()
        //todo:
        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(maxTotalAddOnOfSelected)"])
        
        //then add extra-addOns
        for i:Int in 0..<addonArray.count {
            let name = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonArray[i] as! [String:AnyObject])["addon_id"]).getAESDecryption()
            let tempdict = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":"0", "addOnQuantity" : "1"]
            arrSectionAddOns.append(tempdict)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionAddOns as AnyObject])
        
        //section-5
        let isPrevisHidden = (index == 0) ? "1" : "0"
        let addToCartText = (index == arrApiFoodDetail.count - 1) ? "Add to Cart" : "Next"
        
        let isLoyaltyAvailable = String.getSafeString(comboDetailsDictionary["is_loyalty_available"]).getAESDecryption()
        let loyaltyPercentage = String.getSafeString(comboDetailsDictionary["loyalty_percentage"]).getAESDecryption()
        let loyaltyUnitValue = String.getSafeString(comboDetailsDictionary["loyalty_unit_value"]).getAESDecryption()
        
        let arrSectionSumTotal = [["note":"","totalPrice":"\(totalComboPrice)","isPrevisHidden":isPrevisHidden,"addToCartText":addToCartText,"isLoyaltyAvailable":isLoyaltyAvailable,"loyaltyPercentage":loyaltyPercentage,"loyaltyUnitValue":loyaltyUnitValue,"loyaltyPoints":"0","loyaltyCash":"0"]]
        arrData.append(["sectionName":"Sum-Total" as AnyObject,"value":arrSectionSumTotal as AnyObject])
        calculateLoyaltyPointsAndStoreInMainArray()
        tableViewForm.reloadData()
    }
    
    func loadEditCartFreshDataWithIndex(_ index:Int) {
        
        self.selectCountItems = 0
        let arrApiFoodDetail = comboDetailsDictionary["food_details"] as! [[String:AnyObject]]
        foodDetailsDictionary = arrApiFoodDetail[index]
        arrData.removeAll()
        //section-1
        let image = String.getSafeString(foodDetailsDictionary["food_item_img_url"]).getAESDecryption()
        let arrFoodImage = [["image":image,"title":"","price":""]]
        let arrSectionFoodImage = [["selectedIndex":"","images":arrFoodImage]]
        arrData.append(["sectionName":"Food Image" as AnyObject,"value":arrSectionFoodImage as AnyObject])
        
        //section-2
        let foodName = String.getSafeString(foodDetailsDictionary["food_name"]).getAESDecryption()
        let foodID = String.getSafeString(foodDetailsDictionary["food_id"]).getAESDecryption()
        let foodDesc = String.getSafeString(foodDetailsDictionary["food_desc"]).getAESDecryption()
        let sizename = String.getSafeString(foodDetailsDictionary["food_size_name"]).getAESDecryption()
        let tempSizeArray = [sizename]
        
        var strComboPrice = String.getSafeString(comboDetailsDictionary["combo_price"]).getAESDecryption()
        strComboPrice = strComboPrice.isBlank ? "0" : strComboPrice
        let sizeIdOfSelected = String.getSafeString(foodDetailsDictionary["food_size_id"]).getAESDecryption()
        let sizeIndex = 0  // it is always 0 for this screen.
        //        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"size":tempSizeArray,"sizeIndex":"\(sizeIndex)"],["basicPrice":strComboPrice,"sizeIdOfSelected":sizeIdOfSelected]]
        
        let arrSectionFoodDesc = [["foodName":foodName,"foodID":foodID,"isNew":"0","cellID":"PYLFoodNameCell"],["foodDesc":foodDesc,"cellID":"PYLFoodDescriptionCell"],["size":tempSizeArray,"sizeIndex":"\(sizeIndex)","sizeIdOfSelected":sizeIdOfSelected,"cellID":"PYLFoodSizeCell"],["attribute":"Price","price":strComboPrice,"basicPrice":strComboPrice,"cellID":"PYLFoodPriceCell"]] as [Any]
        arrData.append(["sectionName":"Food Description" as AnyObject,"value":arrSectionFoodDesc as AnyObject])
        
        //section-3
        var addonDefaultArray = [AnyObject]()
        if let tempArr = foodDetailsDictionary["default_addon_details"] as? [AnyObject] {  // use of selected-size dict (for default-addOns)
            addonDefaultArray = tempArr
        }
        var maxDefaultAddOnOfSelected = String.getSafeString(foodDetailsDictionary["default_addon"]).getAESDecryption() //needed in add-on section
        var maxTotalAddOnOfSelected = String.getSafeString(foodDetailsDictionary["max_addon"]).getAESDecryption() //needed in add-on section
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
            if isSelected  == "1" {
                self.selectCountItems =  selectCountItems! + 1
            }
            
           // let tempdictDefault = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":isSelected, "addOnQuantity" : "1"]
            
            let tempdictDefault = ["addon_id":addOnid as AnyObject,"addon_name":name as AnyObject,"addon_price":price as AnyObject,"checked":isSelected, "addOnQuantity" : "1" as AnyObject, "maxLimit":maxDefaultAddOnOfSelected as AnyObject,"seletedItems":self.selectCountItems!] as [String : AnyObject]
            
            
            
            arrSectionDefaultAddOns.append(tempdictDefault)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionDefaultAddOns as AnyObject])
        
        //section-4
        var addonArray = [AnyObject]()
        if let tempArr = foodDetailsDictionary["extra_addon_details"] as? [AnyObject] {
            addonArray = tempArr
        }
        var arrSectionAddOns = [Any]()
        //        var tempdict = [String:String]()
        //todo:
        arrSectionAddOns.append(["title":"Extra Add-Ons","max":"\(maxTotalAddOnOfSelected)"])
        // add extra-addOns (no need to add default-addons here, as it will automatically come in this section in case of edit-cart)
        for i:Int in 0..<addonArray.count {
            let name = String.getSafeString((addonArray[i] as! [String:AnyObject] )["addon_name"]).getAESDecryption()
            let price = String.getSafeString((addonArray[i] as! [String:AnyObject] )["addon_price"]).getAESDecryption()
            let addOnid = String.getSafeString((addonArray[i] as! [String:AnyObject] )["addon_id"]).getAESDecryption()
            var isSelected = String.getSafeString((addonArray[i] as! [String:AnyObject])["is_selected"]).getAESDecryption()
            isSelected = isSelected.lowercased() == "true" ? "1" : "0"
            var addOnQuantity = String.getSafeString((addonArray[i] as! [String:AnyObject])["qty"]).getAESDecryption()
            addOnQuantity = (addOnQuantity.isBlank || isSelected == "0") ? "1" : addOnQuantity
            let tempdict = ["addon_id":addOnid,"addon_name":name,"addon_price":price,"checked":isSelected, "addOnQuantity" : addOnQuantity]
            arrSectionAddOns.append(tempdict)
        }
        arrData.append(["sectionName":"Add-Ons" as AnyObject,"value":arrSectionAddOns as AnyObject])
        
        //section-5
        let isPrevisHidden = (index == 0) ? "1" : "0"
        let addToCartText = (index == arrApiFoodDetail.count - 1) ? "Update Cart" : "Next"
        let note = String.getSafeString(foodDetailsDictionary["note"]).getAESDecryption()
        
        let isLoyaltyAvailable = String.getSafeString(comboDetailsDictionary["is_loyalty_available"]).getAESDecryption()
        let loyaltyPercentage = String.getSafeString(comboDetailsDictionary["loyalty_percentage"]).getAESDecryption()
        let loyaltyUnitValue = String.getSafeString(comboDetailsDictionary["loyalty_unit_value"]).getAESDecryption()
        
        let arrSectionSumTotal = [["note":note,"totalPrice":"\(totalComboPrice)","isPrevisHidden":isPrevisHidden,"addToCartText":addToCartText,"isLoyaltyAvailable":isLoyaltyAvailable,"loyaltyPercentage":loyaltyPercentage,"loyaltyUnitValue":loyaltyUnitValue,"loyaltyPoints":"0","loyaltyCash":"0"]]
        arrData.append(["sectionName":"Sum-Total" as AnyObject,"value":arrSectionSumTotal as AnyObject])
        calculateLoyaltyPointsAndStoreInMainArray()
        tableViewForm.reloadData()
    }
    
    func calculateTotalPriceAndStoreInMainArray(_ addOnTuple:(IndexPath,prevQuantity: Int)?) {
        
        if addOnTuple != nil {
            let arrSectionAddOns = self.arrData[addOnTuple!.0.section]["value"] as! Array<Dictionary<String,AnyObject>>
            let addOnIsChecked = (arrSectionAddOns[addOnTuple!.0.row]["checked"] as! String) == "1"
            let addOnPrice = Int(arrSectionAddOns[addOnTuple!.0.row]["addon_price"] as! String)
            //MARK: - Int related issue may occur if there is value in point like "400.0"
            let newAddOnQuantity = Int(arrSectionAddOns[addOnTuple!.0.row]["addOnQuantity"] as! String)
            if addOnIsChecked { //it means addOn is checked now. (this is not the previous status, this is current status.)
                //                totalComboPrice -= (addOnPrice! * addOnTuple!.prevQuantity)
                //                totalComboPrice += (addOnPrice! * newAddOnQuantity!)
                
                totalComboPrice -= (addOnPrice! * addOnTuple!.prevQuantity * comboQuantity)
                totalComboPrice += (addOnPrice! * newAddOnQuantity! * comboQuantity)
            }
            else { //means addOn is unchecked this time.
                //                totalComboPrice -= (addOnPrice! * newAddOnQuantity!)
                
                totalComboPrice -= (addOnPrice! * newAddOnQuantity! * comboQuantity)
            }
            
            var arrSectionSumTotal = self.arrData[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
            var dictRow = arrSectionSumTotal[rowIndexTotal]
            dictRow["totalPrice"] = "\(totalComboPrice)" as AnyObject?
            arrSectionSumTotal[rowIndexTotal] = dictRow
            self.arrData[sectionIndexTotal]["value"] = arrSectionSumTotal as AnyObject?
        }
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
            self.view.showToastWithMessage(DEFAULT_EXCEED_LIMIT)
        }
            //        else if countExtraAddOn > maxExtra {
            //            validate = false
            //            self.view.showToastWithMessage(EXTRA_EXCEED_LIMIT)
            //        }
        else if (countExtraAddOn + countDefaultAddOn) > totalAddons! {
            validate = false
            self.view.showToastWithMessage(TOTAL_EXCEED_LIMIT)
        }
        
        return validate
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
        //let foodQuantity = Double(comboQuantity)
        
        //Set the loyalty things in sectionTotal.
        let loyaltyPercentage = Double(dictRow["loyaltyPercentage"] as! String)
        let loyaltyUnitValue = Double(dictRow["loyaltyUnitValue"] as! String)
        //let loyaltyPoints = foodBasicPrice! * foodQuantity * loyaltyPercentage! * 0.01
        let loyaltyPoints = foodBasicPrice! * loyaltyPercentage! * 0.01
        let loyaltyCash = loyaltyPoints * loyaltyUnitValue!
//        dictRow["loyaltyPoints"] = "\(Int(loyaltyPoints))"
//        dictRow["loyaltyCash"] = "\(Int(loyaltyCash))"
        dictRow["loyaltyPoints"] = "\(loyaltyPoints)".toStringWithRoundOfUpToTwoDecimal() as AnyObject?
        dictRow["loyaltyCash"] = "\(loyaltyCash)".toStringWithRoundOfUpToTwoDecimal() as AnyObject?
        arrSectionSumTotal[rowIndexTotal] = dictRow
        self.arrData[sectionIndexTotal]["value"] = arrSectionSumTotal as AnyObject?
    }
    
    func loadTableWithExistingArrayElement(_ index: Int) { // maybe
        //set Total price in each array inside arrCombo.
        self.selectCountItems = 0
        var tempArr = arrComboFoods[index] as! [[String:AnyObject]]
        var arrDefaultAddOn = tempArr[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
        for i:Int in 0..<arrDefaultAddOn.count {
            
            if let isSelected = String.getSafeString((arrDefaultAddOn[i])["checked"]).toBool() {
                
                if isSelected  == true {
                    self.selectCountItems =  selectCountItems! + 1
                }
            }
        }
        
        for i in 0..<arrComboFoods.count {
            var tempArr = arrComboFoods[i] as! [[String:AnyObject]]
            var arrSectionSumTotal = tempArr[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
            var dictRow = arrSectionSumTotal[rowIndexTotal]
            dictRow["totalPrice"] = "\(totalComboPrice)" as AnyObject?
            arrSectionSumTotal[rowIndexTotal] = dictRow
            tempArr[sectionIndexTotal]["value"] = arrSectionSumTotal as AnyObject?
            arrComboFoods[i] = tempArr as AnyObject
            
            
            
        }
        arrData = arrComboFoods[index] as! [[String:AnyObject]]
        tableViewForm.reloadData()
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
            case "PYLFoodSizeCell":
                height = HeightFoodSizeCell
                if let sizeArray = dataSource["size"] as? [String] {
                    height = height * Double(sizeArray.count)
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
    func callAddToCartForComboApi() {
        let comboID = comboDetailsDictionary["combo_id"] as! String
        let comboQuantity = "1".setAESEncription()
        var arrFoodDetails: [[String:AnyObject]] = []
        for i in 0..<arrComboFoods.count {
            let arrSingleFood = arrComboFoods[i] as! [[String:AnyObject]] // arrData for each food
            
            let arrSectionFoodDesc = arrSingleFood[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
            let foodID = (arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String).setAESEncription()
            let foodSizeID = (arrSectionFoodDesc[rowIndexFoodSize]["sizeIdOfSelected"] as! String).setAESEncription()
            
            //Default-addOns
            var arrSectionDefaultAddOns = arrSingleFood[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
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
            var arrSectionAddOns = arrSingleFood[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
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
            let arrSectionSumTotal = arrSingleFood[sectionIndexTotal]["value"] as! Array<Dictionary<String,AnyObject>>
            let note = (arrSectionSumTotal[rowIndexTotal]["note"] as! String).setAESEncription()
            
            let dictFood: [String:AnyObject] = ["food_id":foodID as AnyObject,"food_size_id":foodSizeID as AnyObject,"note":note as AnyObject,"default_addon_details":arrApiDefaultAddOn as AnyObject,"extra_addon_details":arrApiExtraAddOn as AnyObject]
            arrFoodDetails.append(dictFood)
        }
        let dictCombo: [String:AnyObject] = ["combo_id":comboID as AnyObject,"qty":comboQuantity as AnyObject,"food_details":arrFoodDetails as AnyObject]
        debugPrint(dictCombo)
        
        //Now call api
        PYLAPIHandler.handler.addToCartWithCombo(addToCartID, comboTakingOrNot: true, totalPrice: "\(totalComboPrice)", foodDetailsArray: [], comboDetailsArray: [dictCombo], success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
//                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)  //commented to stop toast 'added to cart successfully'
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
        
        let comboID = comboDetailsDictionary["combo_id"] as! String
        let comboUniqueID = comboDetailsDictionary["combo_unique_id"] as! String
        let comboQuantity = "\(self.comboQuantity)".setAESEncription()  
        var arrFoodDetails: [[String:AnyObject]] = []
        for i in 0..<arrComboFoods.count {
            let arrSingleFood = arrComboFoods[i] as! [[String:AnyObject]] // arrData for each food
            
            let arrSectionFoodDesc = arrSingleFood[sectionIndexFoodDesc]["value"] as! Array<Dictionary<String,AnyObject>>
            let foodID = (arrSectionFoodDesc[rowIndexFoodName]["foodID"] as! String).setAESEncription()
            let foodSizeID = (arrSectionFoodDesc[rowIndexFoodSize]["sizeIdOfSelected"] as! String).setAESEncription()
            
            //Default-addOns
            var arrSectionDefaultAddOns = arrSingleFood[sectionIndexDefaultAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
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
            var arrSectionAddOns = arrSingleFood[sectionIndexAddOn]["value"] as! Array<Dictionary<String,AnyObject>>
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
            let note = (arrSectionSumTotal[rowIndexTotal]["note"] as! String).setAESEncription()
            
            let dictFood: [String:AnyObject] = ["food_id":foodID as AnyObject,"food_size_id":foodSizeID as AnyObject,"note":note as AnyObject,"default_addon_details":arrApiDefaultAddOn as AnyObject,"extra_addon_details":arrApiExtraAddOn as AnyObject]
            arrFoodDetails.append(dictFood)
        }
        let totalPrice = "\(totalComboPrice)".setAESEncription()
        let dictCombo: [String:AnyObject] = ["total_price":totalPrice as AnyObject, "combo_id":comboID as AnyObject, "combo_unique_id":comboUniqueID as AnyObject,"qty":comboQuantity as AnyObject,"food_items":arrFoodDetails as AnyObject]
        debugPrint(dictCombo)
        
        //Now call api
        PYLAPIHandler.handler.editCart([:], dictComboDetails:dictCombo, success: { (response) in
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
        let comboID = comboDetailsDictionary["combo_id"] as! String
        trackAddedToCartForAnalytics(foodID: comboID, price: Double(totalComboPrice))
        //--analytics
        
        self.pushToViewController(otherStoryboard, viewController: String(describing: PYLMyCartViewController.self))
    }
}

extension PYLComboFoodDetailsViewController: UITableViewDelegate {
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

extension PYLComboFoodDetailsViewController: UITableViewDataSource {
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
            //            switch indexPath.row {
            //            case 0:
            //                let cell = tableView.dequeueReusableCellWithIdentifier(String(PYLFoodDescCell), forIndexPath: indexPath) as! PYLFoodDescCell
            //                cell.datasource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            //                cell.selectSizeButton = {  (selectedIndex) in
            //                }
            //                cellGlobal = cell
            //                
            //            case 1:
            //                let cell = tableView.dequeueReusableCellWithIdentifier(String(PYLBillingCell), forIndexPath: indexPath) as! PYLBillingCell
            //                cell.datasource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            //                //UI
            //                cell.constraintCurveViewBottom.constant = 4.0 //correct value
            //                cellGlobal = cell
            //            default:
            //                break
            //            }
            
            
            let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
            switch dataSource["cellID"] as! String {
            case "PYLFoodNameCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodNameCell.self), for: indexPath) as! PYLFoodNameCell
                cell.datasource = dataSource as AnyObject!
                cellGlobal = cell
                
            case "PYLFoodDescriptionCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodDescriptionCell.self), for: indexPath) as! PYLFoodDescriptionCell
                cell.datasource = dataSource as AnyObject!
                
                cellGlobal = cell
                
            case "PYLFoodSizeCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodSizeCell.self), for: indexPath) as! PYLFoodSizeCell
                cell.cellHeightForSingle = HeightFoodSizeCell
                cell.datasource = dataSource as AnyObject!
                cell.selectSizeButton = {  (selectedIndex) in
                }
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "PYLAddOnHeaderCell", for: indexPath)
                let dataSource = (arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row]
                let labelTitle = cell.viewWithTag(LabelBaseTag+1) as! UILabel
                labelTitle.text = dataSource["title"] as? String
                let labelDesc = cell.viewWithTag(LabelBaseTag+2) as! UILabel
                labelDesc.text = "Can choose maximum of \(dataSource["max"] as! String)"
                 self.limitValue = Int(dataSource["max"] as! String)
                cellGlobal = cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLAddOnDefaultCell.self), for: indexPath) as! PYLAddOnDefaultCell
                cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
                
                // new work hear
                
                
                cell.checkBoxTapped = {
                    
                    
                    (isChecked) in
//                    var arrSectionAddOns = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
//                    var dictRow = arrSectionAddOns[indexPath.row]
//                    dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
//                    arrSectionAddOns[indexPath.row] = dictRow
//                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
//                    tableView.reloadRows(at: [indexPath], with: .none)
                
                
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
                    let prevQuantity = Int(dictRow["addOnQuantity"] as! String) //take previous quantity in a back-up
                    dictRow["addOnQuantity"] = "\(quantity)" as AnyObject? //set the new quantity
                    arrSectionAddOns[indexPath.row] = dictRow
                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                    self.calculateTotalPriceAndStoreInMainArray((indexPath,prevQuantity:prevQuantity!))
                    self.calculateLoyaltyPointsAndStoreInMainArray()
                    tableView.reloadRows(at: [IndexPath(row: self.rowIndexTotal, section: self.sectionIndexTotal)], with: .none)
                }
                cell.checkBoxTapped = { (isChecked) in
                    var arrSectionAddOns = self.arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>
                    var dictRow = arrSectionAddOns[indexPath.row]
                    dictRow["checked"] = isChecked ? "1" as AnyObject? : "0" as AnyObject?
                    arrSectionAddOns[indexPath.row] = dictRow
                    self.arrData[indexPath.section]["value"] = arrSectionAddOns as AnyObject?
                    self.calculateTotalPriceAndStoreInMainArray((indexPath,prevQuantity:0)) // send previous quantity as 0.
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
                dict["note"] = fieldValue as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            cell.addTocart = {  // next/(addToCart/editCart)
              
                self.view.endEditing(true)
                guard self.checkAddOnValidity() else { return }
                let arrApiFoodDetail = self.comboDetailsDictionary["food_details"] as! [[String:AnyObject]]
                guard (self.currentFoodIndex != arrApiFoodDetail.count - 1) else { // Guard(addToCart)
                    //check whether current index exists in the main array or not.
                    
                    if self.currentFoodIndex < self.arrComboFoods.count {
                        self.arrComboFoods[self.currentFoodIndex] = self.arrData as AnyObject //copy the table dataArray to the comboArray before going anywhere
                    }
                    else { // populate fresh data with the dictionary
                        self.arrComboFoods.append(self.arrData as AnyObject)
                    }
                    if self.previousVcType == vcType.kMyCart {
                        self.callEditCartApi()
                    }
                    else {
                        self.callAddToCartForComboApi()
                    }
                    return
                }
                
                //check whether current index exists in the main array or not.
                if self.currentFoodIndex < self.arrComboFoods.count {
                    self.arrComboFoods[self.currentFoodIndex] = self.arrData as AnyObject
                    self.loadTableWithExistingArrayElement(self.currentFoodIndex + 1)
                }
                else { // populate fresh data with the dictionary
                    self.arrComboFoods.append(self.arrData as AnyObject)
                    if self.previousVcType == vcType.kMyCart {
                        self.loadEditCartFreshDataWithIndex(self.currentFoodIndex + 1)
                    }
                    else {
                        self.loadFreshDataWithIndex(self.currentFoodIndex + 1)
                    }
                }
                self.currentFoodIndex += 1  // now currentFoodIndex becomes the next page
            }
            cell.previousTappedBlock = {
                
                
         
                
                
                self.view.endEditing(true)
                guard self.checkAddOnValidity() else { return }
                if self.currentFoodIndex < self.arrComboFoods.count {
                    self.arrComboFoods[self.currentFoodIndex] = self.arrData as AnyObject //copy the table dataArray to the comboArray before going anywhere
                }
                else { // populate fresh data with the dictionary
                    self.arrComboFoods.append(self.arrData as AnyObject)
                }
                self.currentFoodIndex -= 1  // now currentFoodIndex becomes the previous page
                self.loadTableWithExistingArrayElement(self.currentFoodIndex)
            }
            cellGlobal = cell
            
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
