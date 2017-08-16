//
//  PYLSearchPopUpViewController.swift
//  Peyala
//
//  Created by Adarsh on 15/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLSearchPopUpViewController: PYLBaseViewController {
    
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var tableViewData: UITableView!
    @IBOutlet weak var buttonBack: UIButton!
    
    var searchKeyArray = [String]()
    var filteredData = [AnyObject]()
    var dismissPopupAction:(()->())!
    var chosenOptionAction:((AnyObject)->())!
    var sourceViewController: UIViewController?
    
    var searchText = ""
    var currentPageNo = 1
    var pageCount = 10
    var moreDataAvailable:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        callCusineApi()
    }
    
    func setupUI() {
        
        //        let headerHeight = IS_IPAD() ? CGFloat(20.0) : CGFloat(10.0)
        //        let brownViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: headerHeight))
        //        brownViewHeader.backgroundColor = BG_CREAM_COLOR
        //        let brownViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: headerHeight))
        //        brownViewFooter.backgroundColor = BG_CREAM_COLOR
        //        tableViewData.tableHeaderView = brownViewHeader
        //        tableViewData.tableFooterView = brownViewFooter
        tableViewData.isHidden = true
        resetValues()
    }
    
    func callCusineApi()
    {
        if PYLHelper.helper.searchKeyArray.count > 0 {
            let temKeyArray :[String] = PYLHelper.helper.searchKeyArray 
            for index in 0..<temKeyArray.count {
                self.searchKeyArray.append(temKeyArray[index].getAESDecryption())
            }
            self.filteredData = self.searchKeyArray as [AnyObject]
            tableViewData.reloadData()
        }else {
            self.callDefaultSearchAPI()
        }
    }
    
    //MARK: API CALL
    func callDefaultSearchAPI()
    {
        PYLAPIHandler.handler.defaultSearchList({ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successDefaultSearchResponse(response!)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
            
        }) { (error) in
            
        }
    }
    
    func callSearchByKeyAPI(_ searchKey:String,pageNo:Int,PageCount:Int)
    {
        PYLAPIHandler.handler.searchByKey(searchKey, page:"\(pageNo)", pagecontent: "\(PageCount)", success: { (response) in
//            DispatchQueue.main.async {
//                self.textFieldSearch.becomeFirstResponder()
//            }
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successSearchByKeyResponse(response!)
            default :
                break
                //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
//            DispatchQueue.main.async {
//                self.textFieldSearch.becomeFirstResponder()
//            }
        }
    }
    
    //MARK: Fetch Response
    func successDefaultSearchResponse(_ response: JSON) {
        let responseDict =  response.dictionaryObject!
        let searchKeyArray: [String] = responseDict["search_key_list"] as! [String]
        debugPrint(searchKeyArray)
        PYLHelper.helper.searchKeyArray = searchKeyArray
        
        self.searchKeyArray.append(contentsOf: searchKeyArray)
//        for index in 0..<searchKeyArray.count {
//            self.searchKeyArray.append(searchKeyArray[index].getAESDecryption())
//        }
        self.filteredData = self.searchKeyArray as [AnyObject]
        self.tableViewData.reloadData()
    }
    
    func successSearchByKeyResponse(_ response: JSON) {
        debugPrint(response)
        let fooditems = response["food_item"].arrayObject
        //        let responseDict =  response.dictionaryObject!
        //        let searchKeyArray: [String] = responseDict["search_key_list"] as! [String]
        //        debugPrint(searchKeyArray)
        //        PYLHelper.helper.searchKeyArray = searchKeyArray
        //        for index in 0..<searchKeyArray.count {
        //            self.searchKeyArray.append(searchKeyArray[index].getAESDecryption())
        //        }
        for (_,item) in (fooditems?.enumerated())! {
            //            if let foodname = item["food_name"] as? String{
            //                
            //            }
            filteredData.append(item as AnyObject)
        }
        fooditems?.count == pageCount ? (moreDataAvailable = true) : (moreDataAvailable = false)
        self.tableViewData.reloadData()
    }
    
    internal class func showSearchPopup(_ sourceViewController: UIViewController, selectedOption:@escaping (AnyObject)->(), dismiss:@escaping ()->()) {
        
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLSearchPopUpViewController.self)) as! PYLSearchPopUpViewController
        viewController.sourceViewController = sourceViewController
        viewController.chosenOptionAction = selectedOption
        viewController.dismissPopupAction = dismiss
        viewController.presentSearchPopupWith(sourceViewController)
    }
    
    func presentSearchPopupWith(_ sourceController: UIViewController)  {
        //        self.view.frame = sourceController.view.bounds
        //        sourceController.view.addSubview(self.view)
        //        sourceController.addChildViewController(self)
        //        sourceController.view.bringSubviewToFront(self.view)
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25) {
            self.view.transform = .identity
        }
    }
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }) { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
        }
    }
    
    func reloadTableForSearchText() {
        if (searchText.length>0){
            tableViewData.isHidden = false
            filteredData = self.searchKeyArray.filter({(strings) -> Bool in
                let nameStr = strings
                if nameStr.lowercased().contains(searchText.lowercased()) {
                    return true
                } else{
                    return false
                }
            }) as [String] as [AnyObject]
        }
        else {
            filteredData = []
            tableViewData.isHidden = true
        }
        tableViewData.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismissAnimate()
        if dismissPopupAction != nil {
            dismissPopupAction()
        }
    }

    @IBAction func textValueChanged(_ sender: Any) {
        
        // to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CallAPI), object: nil)
        searchText = (sender as! UITextField).text!
        guard searchText.length > 0 else { return }
        self.perform(#selector(PYLSearchPopUpViewController.CallAPI), with: nil, afterDelay: 0.7)
    }
    
    func CallAPI() {
//        self.view.endEditing(true)
        resetValues()
        self.filteredData.removeAll()
        if searchText.isEmpty == true{
            self.filteredData = self.searchKeyArray as [AnyObject]
            //reloadTableForSearchText()
        }else{
            self.callSearchByKeyAPI(searchText,pageNo: currentPageNo,PageCount: pageCount)
        }
        self.tableViewData.reloadData()
    }
}

extension PYLSearchPopUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.callSearchByKeyAPI(textField.text!,pageNo:currentPageNo,PageCount: pageCount)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableViewData.isHidden = false
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if (range.length == 0){
//            let stringNew = NSMutableString(string: textField.text!)
//            stringNew.insert(string, at: range.location)
//            searchText = stringNew as String
//        }
//        else if(range.length == 1){
//            let stringNew = NSMutableString(string: textField.text!)
//            stringNew.deleteCharacters(in: range)
//            searchText = stringNew as String
//        }
//        resetValues()
//        self.filteredData.removeAll()
//        if searchText.isEmpty == true{
//            self.filteredData = self.searchKeyArray as [AnyObject]
//            //reloadTableForSearchText()
//        }else{
//            self.callSearchByKeyAPI(searchText,pageNo: currentPageNo,PageCount: pageCount)
//        }
//        self.tableViewData.reloadData()
//        return true
//    }
    
   
    
    func resetValues() {
        self.currentPageNo = 1
        self.pageCount = 10
        self.moreDataAvailable = false
    }
    
    
}


extension PYLSearchPopUpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return IS_IPAD() ? 52.0 : 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let datasource = filteredData[indexPath.row]
        //self.callSearchByKeyAPI(datasource,pageNo: currentPageNo,PageCount: pageCount)
        let datasource:AnyObject = filteredData[indexPath.row] as AnyObject
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }) { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if self.chosenOptionAction != nil {
                self.chosenOptionAction(datasource)
            }
        }
    }
}


extension PYLSearchPopUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewData.dequeueReusableCell(withIdentifier: "PYLSearchCell", for: indexPath as IndexPath)
        let datasource = filteredData[indexPath.row]
        let labelName = cell.viewWithTag(LabelTag + 1) as! UILabel
        if let foodname = datasource["food_name"] as? String{
            labelName.text = foodname.getAESDecryption()
        }else if let keyname = datasource as? String{
            labelName.text = keyname
        }
        
        if indexPath.row == filteredData.count - 1 && moreDataAvailable == true{
            currentPageNo += 1
            callSearchByKeyAPI(searchText, pageNo: currentPageNo, PageCount: pageCount)
        }
        return cell
    }
}
