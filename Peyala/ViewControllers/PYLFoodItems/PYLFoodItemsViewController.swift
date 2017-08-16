//
//  PYLFoodItemsViewController.swift
//  Peyala
//
//  Created by Soumen Das on 06/09/16.
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


class PYLFoodItemsViewController: PYLBaseViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UIScrollViewDelegate {
    
    fileprivate var myContext = 0
    enum ScrollDirection {
        case up
        case down
        case notMoving
    }
    // MARK: - Outlet Connections
    
    @IBOutlet weak var foodCategory:    UITextField!
    @IBOutlet weak var foodSubCategory: UITextField!
    @IBOutlet weak var selectMenu: UITextField!
    @IBOutlet weak var foodItemTable:   UITableView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet var heightConstraintCategoryMenu: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintUpperView: NSLayoutConstraint!
    var arrFoodItems = NSArray()
    var arrFoodCategory :[String] = []
    var arrFoodSubCategory :[String] = []
    
    var searchText = ""
    var currentPageNo = 1
    var pageCount = 10
    var moreDataAvailable:Bool = false
    var IsLoading:Bool = false
    var selectedCategoryIndex :Int = 0
    var selectedSubCatIndex :Int = 0
    
    var arrTableFoodItems = NSArray()
    var foodCatagoryID: String?
    var subcatagoryID : String?
    var foodCatagoryName: String?
    var keywordSearch: String?
    var subCatagoryArray = [AnyObject]()
    var catagoryArray = [AnyObject]()
    var foodDetailsArray = [AnyObject]()
    var scrollDirection:ScrollDirection = .notMoving
    var iscollapsed:Bool = false
    fileprivate var lastContentOffset: CGFloat = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setUpCategoryArrayForPicker()
        setUpSubCategoryArrayForPicker()
        setupUI()
        if foodCatagoryID == nil {
            return
        }
        foodCategory.text = foodCatagoryName!
        callSubCatagoryAPI(foodCatagoryID!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(FOOD_ITEMS_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        upperView.layer.cornerRadius = 5
        upperView.clipsToBounds = true
        upperView.layer.borderColor = UIColor.lightGray.cgColor
        upperView.layer.borderWidth = 0.5
        foodItemTable.reloadData()
    }
    
    //MARK: - User Defined Function
    func setupUI() {
        foodItemTable.defaultSetup()
        if self.keywordSearch?.length > 0 {
            let constraint = self.heightConstraintUpperView.constraintWithMultiplier(0.0)
            self.view!.removeConstraint(self.heightConstraintUpperView)
            self.view!.addConstraint(constraint)
            self.view!.layoutIfNeeded()
            callFoodDetailsBySearchKeyword(currentPageNo, pageCount:pageCount)
        }
    }
    
    func setUpCategoryArrayForPicker() {
        self.arrFoodCategory.removeAll()
        for (index, _) in catagoryArray.enumerated() {
            self.arrFoodCategory.append(((catagoryArray[index]["food_category_name"] as? String)!).getAESDecryption())
        }
    }
    
    func setUpSubCategoryArrayForPicker() {
        self.arrFoodSubCategory.removeAll()
        for (index, _) in subCatagoryArray.enumerated() {
            self.arrFoodSubCategory.append(((subCatagoryArray[index]["food_subcategory_name"] as? String)!).getAESDecryption())
        }
    }
    
    //MARK: - Webservice Call
    
    func callSubCatagoryAPI(_ catagoryID: String) {
        IsLoading = true
        PYLAPIHandler.handler.getFoodSubCatagory(catagoryID, success: { (response) in
            //            switch (response["ResponseCode"]) {
            //            case "200":
            //                self.successSubCatagoryApi(response)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //            }
            self.IsLoading = false
            self.offlineOrSuccessResponseHandleSubCatagoryApi(response!)
            }, offlineBlock: { (response) in
                self.IsLoading = false
                self.offlineOrSuccessResponseHandleSubCatagoryApi(response!)
        }) { (error) in
            self.IsLoading = false
        }
    }
    
    func callFoodDetailsBySearchKeyword(_ pageNo: Int,pageCount:Int){
        IsLoading = true
        PYLAPIHandler.handler.searchByKey(keywordSearch!, page:"\(currentPageNo)", pagecontent: "\(pageCount)", success: { (response) in
             self.IsLoading = false
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                let fooditems = (response?["food_item"].arrayObject)! as [AnyObject]
                self.foodDetailsArray.append(contentsOf: fooditems)
                self.foodItemTable.hideNoDataLabel()
                guard self.foodDetailsArray.count > 0 else {
                    self.foodItemTable.showNodataLabelWithText(FOOD_ITEM_NOT_AVAILABLE)
                    return
                }
                fooditems.count == pageCount ? (self.moreDataAvailable = true) : (self.moreDataAvailable = false)
                self.foodItemTable.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                    self.foodItemTable.reloadData()
                }
                break
            //foodDetailsArray = response
            default :
                break
                //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
             self.IsLoading = false
        }
    }
    
    
    func callFoodDetailsByCatagory(_ catagoryID: String, subCatagoryID: String,pageNo: String) {
         IsLoading = true
        if(pageNo != "1") {
            //animating footer view addition
            let viewFooter = UIView(frame: CGRect(x: 0,y: 0,width: foodItemTable.frame.size.width,height: 44.0))
            viewFooter.backgroundColor = UIColor.white
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityIndicator.center = CGPoint(x: viewFooter.frame.width/2, y: viewFooter.frame.height/2)
            activityIndicator.startAnimating()
            viewFooter.addSubview(activityIndicator)
            self.foodItemTable.tableFooterView = viewFooter
            //end: animating footer view addition
            global_ShallShowHudForThisCall = false
        }
        
        PYLAPIHandler.handler.getFoodItemByCatagory(catagoryID, subCatagoryID: subCatagoryID,pageNo: pageNo,pageContent: "\(pageCount)" , success: { (response) in
             self.IsLoading = false
            //            switch (response["ResponseCode"]) {
            //            case "200":
            //                self.successFoodDetailsArray(response)
            //            default :
            //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            //            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5.0 * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.foodItemTable.tableFooterView = UIView() //animating footer view removal
            }
            //            self.foodItemTable.tableFooterView = UIView() //animating footer view removal
             self.IsLoading = false
            self.offlineOrSuccessResponseHandleFoodDetailsByCatagoryApi(response!)
            }, offlineBlock: { (response) in
                 self.IsLoading = false
                self.offlineOrSuccessResponseHandleFoodDetailsByCatagoryApi(response!)
        }) { (error) in
            
        }
    }
    
    //MARK: Fetch Response Data
    
    func offlineOrSuccessResponseHandleSubCatagoryApi(_ response: JSON) {
        switch (response["ResponseCode"]) {
        case "200":
            self.successSubCatagoryApi(response)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    func offlineOrSuccessResponseHandleFoodDetailsByCatagoryApi(_ response: JSON) {
        switch (response["ResponseCode"]) {
        case "200":
            self.successFoodDetailsArray(response)
        default :
            self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        }
    }
    
    func successSubCatagoryApi(_ response: JSON) {
        
        let responseDict =  response.dictionaryObject!
        self.subCatagoryArray  = responseDict["food_subcategory_list"] as! [AnyObject]
        
        if self.subCatagoryArray.count > 0 {
            foodSubCategory.isUserInteractionEnabled = true
            setUpSubCategoryArrayForPicker()
            subcatagoryID = self.subCatagoryArray[0]["food_subcategory_id"] as? String
            let subcatagoryName = self.subCatagoryArray[0]["food_subcategory_name"] as! String
            foodSubCategory.text = subcatagoryName.getAESDecryption()
            self.foodDetailsArray.removeAll()
            self.callFoodDetailsByCatagory(foodCatagoryID!, subCatagoryID: subcatagoryID!.getAESDecryption(),pageNo:"\(currentPageNo)")
            
        } else {
            DispatchQueue.main.async {
                self.foodSubCategory.text = "No Sub Category Available"
                self.foodSubCategory.isUserInteractionEnabled = false
                self.view.showToastWithMessage(FOOD_ITEM_NOT_AVAILABLE)
                self.foodItemTable.showNodataLabelWithText(FOOD_ITEM_NOT_AVAILABLE)
                self.foodDetailsArray.removeAll()
                self.foodItemTable.reloadData()
            }
        }
    }
    
    func successFoodDetailsArray(_ response: JSON) {
        
        let responseDict =  response.dictionaryObject!
        let tempFoodArray = responseDict["food_item"] as! [AnyObject]
        let totalCount = (responseDict["total_count"] as! String).getAESDecryption()
        for index in 0..<tempFoodArray.count {
            foodDetailsArray.append(tempFoodArray[index])
        }
        
        self.foodDetailsArray.count == Int(totalCount) ? (moreDataAvailable = false) : (moreDataAvailable = true)
        DispatchQueue.main.async {
            self.foodItemTable.hideNoDataLabel()
            if self.foodDetailsArray.count == 0 {
                self.view.showToastWithMessage(FOOD_ITEM_NOT_AVAILABLE)
                self.foodItemTable.showNodataLabelWithText(FOOD_ITEM_NOT_AVAILABLE)
            }
            self.foodItemTable.reloadData()
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            //                self.foodItemTable.reloadData()
            //            }
        }
    }
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
        self.backButtonEnabled = true
        self.title = "FOOD ITEMS"
    }
    
    // MARK: - Table View DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDetailsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLFoodItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFoodItemTableViewCell.self)) as! PYLFoodItemTableViewCell
        cell.configureCell()
        cell.datasource = foodDetailsArray[indexPath.row] // need to pass the Respective array
                //need to hide the last row here.....
//                let lastRowIndex = tableView.numberOfRowsInSection(tableView.numberOfSections-1)
//                if (indexPath.row == lastRowIndex - 1) {
//                    cell.labelSeparator.isHidden = true
//                }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath.row == foodDetailsArray.count - 1) && (moreDataAvailable == true) && (IsLoading == false){
            IsLoading = true
            currentPageNo = currentPageNo + 1
            if keywordSearch?.length > 0 {
                self.callFoodDetailsBySearchKeyword(currentPageNo, pageCount:pageCount)
            }else{
                self.callFoodDetailsByCatagory(foodCatagoryID!, subCatagoryID: subcatagoryID!.getAESDecryption(),pageNo:"\(currentPageNo)")
            }
        }

    }
    
    // Mark: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColorRGB(250, g: 250, b: 247)
        
        let headreLabel = UILabel()
        headreLabel.frame = CGRect(x: 15, y: 0, width: tableView.frame.width, height: IS_IPAD() ? 70.0 : 50.0)
        self.keywordSearch?.length > 0 ? (headreLabel.text = "Search Result") : (headreLabel.text = foodCategory.text)
        headreLabel.font = IS_IPAD() ? UIFont.boldSystemFont(ofSize: 24) : UIFont.boldSystemFont(ofSize: 18)
        headerView.addSubview(headreLabel)
        
        let seperatorLabel = UILabel()
        seperatorLabel.frame = CGRect(x: 0, y: headreLabel.frame.height-1, width: tableView.frame.width, height: 0.5)
        seperatorLabel.backgroundColor = UIColor.lightGray
        headerView.addSubview(seperatorLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return IS_IPAD() ? 70.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLFoodDetailsViewController.self)) as! PYLFoodDetailsViewController
        let foodItemDict: [String:String] = foodDetailsArray[indexPath.row] as! [String : String]
        viewController.foodID = foodItemDict["food_id"]!.getAESDecryption()
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
        if (self.lastContentOffset < offsetY - 50  && iscollapsed == true) {
            // move up
            self.scrollDirection = .Down
            heightConstraintCategoryMenu.constant = IS_IPAD() ? 120 : 100
            iscollapsed = false
            UIView.animateWithDuration(0.2, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        else if (self.lastContentOffset > offsetY + 100  && iscollapsed == false) {
            // move down
            self.scrollDirection = .Up
            heightConstraintCategoryMenu.constant = 0.0
            iscollapsed = true
            UIView.animateWithDuration(0.2, animations: {
                self.view.layoutIfNeeded()
            })
            
        }else{
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }
 */
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //print(velocity)
        let targetPoint: CGPoint = targetContentOffset.pointee;
        let currentPoint: CGPoint  = scrollView.contentOffset;
        if (targetPoint.y > currentPoint.y && velocity.y > 0.5 && iscollapsed == false) {
            //print("Up")
            heightConstraintCategoryMenu.constant = 0.0
            iscollapsed = true
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        else if velocity.y < -1 {
            //print("Down")
            heightConstraintCategoryMenu.constant = IS_IPAD() ? 120 : 100
            iscollapsed = false
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        
    }
    
    
    /* //Rounded corner section in tableview
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
     if cell.respondsToSelector(Selector("tintColor")){
     let cornerRadius : CGFloat  = 5.0
     cell.backgroundColor = UIColor.clearColor()
     let layer:CAShapeLayer = CAShapeLayer()
     let pathRef : CGMutablePathRef = CGPathCreateMutable()
     let bounds = CGRectInset(cell.bounds, 5, 0)
     var addLine = false
     if (indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
     CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
     } else if (indexPath.row == 0) {
     CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
     CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
     CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
     CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
     addLine = true;
     } else if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
     CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
     CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
     CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
     CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
     } else {
     CGPathAddRect(pathRef, nil, bounds);
     addLine = true;
     }
     layer.path = pathRef;
     //CFRelease(pathRef);
     layer.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor //[UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
     
     if (addLine == true) {
     let lineLayer : CALayer = CALayer()
     let lineHeight: CGFloat  = (1 / UIScreen.mainScreen().scale);
     lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
     lineLayer.backgroundColor = tableView.separatorColor!.CGColor;
     layer.addSublayer(lineLayer)
     }
     let testView :UIView = UIView()
     testView.layer.insertSublayer(layer, atIndex: 0)
     testView.backgroundColor = UIColor.clearColor()
     cell.backgroundView = testView;
     }
     }
     */
    
    
    //MARK:- UITextField delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == foodCategory) {
            
            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: arrFoodCategory, position: .bottom, pickerTitle: "", preSelected: textField.text!, selected: { (value, index) in
                
                guard (value as! String).length > 0 else { return }
                debugPrint("\(value) , \(index)")
                textField.text = value as? String
                
                self.foodCatagoryID = (self.catagoryArray[index!]["food_category_id"] as? String)!.getAESDecryption()
                self.currentPageNo = 1
                self.callSubCatagoryAPI(self.foodCatagoryID!)
            })
            
        } else if(textField == foodSubCategory) {
            
            PYLPickerViewController.showPickerController(self, isDatePicker: false, pickerArray: arrFoodSubCategory, position: .bottom, pickerTitle: "", preSelected: textField.text!, selected: { (value, index) in
                guard (value as! String).length > 0 else { return }
                textField.text = value as? String
                debugPrint("\(value) , \(index)")
                self.selectedSubCatIndex = index!
                let subCategoryID = (self.subCatagoryArray[index!]["food_subcategory_id"] as? String)!.getAESDecryption()
                self.foodDetailsArray.removeAll()
                self.subcatagoryID = (self.subCatagoryArray[index!]["food_subcategory_id"] as? String)!
                self.currentPageNo = 1
                self.callFoodDetailsByCatagory(self.foodCatagoryID!, subCatagoryID: subCategoryID, pageNo: "\(self.currentPageNo)")
            })
        }else if(textField == selectMenu){
            //var text = ""
            if iscollapsed == true {
                heightConstraintCategoryMenu.constant = IS_IPAD() ? 120 : 100
                //text = "    Select Menu"
                iscollapsed = false
            }else{
                iscollapsed = true
                heightConstraintCategoryMenu.constant = 0.0
                //text = "    " + self.foodCategory.text! + " > " + self.foodSubCategory.text!
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                //self.selectMenu.text = text
            })
            
        }
        return true
    }
    
    @IBAction func onSelect(_ sender: AnyObject) {
        //var text = ""
        if iscollapsed == true {
            iscollapsed = false
            heightConstraintCategoryMenu.constant = IS_IPAD() ? 120 : 100
            //text = "    Select Menu"
        }else{
            iscollapsed = true
            heightConstraintCategoryMenu.constant = 0.0
            //text = "    " + self.foodCategory.text! + " > " + self.foodSubCategory.text!
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            //self.selectMenu.text = text
        })
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        self.view.endEditing(true)
    }
    
    func loadSubCategoryDatas(_ FoodItemArray:[AnyObject]){
        self.arrFoodSubCategory.removeAll()
        for dictionary in FoodItemArray {
            let category = (dictionary["type_name"] as! String)
            let value = category.getAESDecryption()
            arrFoodSubCategory.append(value)
        }
    }
    
    func loadFoodItemsDatas(_ FoodItemArray:NSArray){
        arrTableFoodItems = FoodItemArray ;
        DispatchQueue.main.async {
            self.foodItemTable.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.foodItemTable.reloadData()
            }
        }
    }
}
