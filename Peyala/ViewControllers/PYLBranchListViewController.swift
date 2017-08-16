//
//  PYLBranchListViewController.swift
//  Peyala
//
//  Created by Soumen Das on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLBranchListViewController: PYLBaseViewController {
    
    enum vCType {
        case kCurrentLoc
        case kManuallyLoc
    }
    
    //MARK: - Outlet Collection
    @IBOutlet weak var branchListTable: UITableView!
    
    var previousVcType: vCType = vCType.kCurrentLoc
    var manuallyLocValue :(countryId: String, pinCode: String)?
    var branchListArray = [AnyObject]()
    var arrAllBranches = [AnyObject]()
    var fetchAllBranchList: Bool = false
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        branchListTable.defaultSetup()
        branchListTable.estimatedRowHeight = 140    //116
        if fetchAllBranchList {
            callGetAllBranchAPI()
        } else {
            //callBranchListAvailabilityApi()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        branchListTable.dataSource = nil
        branchListTable.delegate = nil
        trackScreenForAnalyticsWithName(BRANCH_LIST_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func viewDidLayoutSubviews() {
        branchListTable.dataSource = self
        branchListTable.delegate = self
        //branchListTable.reloadData()
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
        self.menuButtonEnabled = true
        self.title = "BRANCH LIST"
    }
    
    //MARK: - API Section
    
    func callGetAllBranchAPI() {
        PYLAPIHandler.handler.getAllBranch({ (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskGetAllBranchAPI(response!)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
            
            }) { (error) in
                
        }
    }
    
//    func callBranchListAvailabilityApi() {
//        if previousVcType == vCType.kCurrentLoc {
//            let tupleUserLoc = GET_USERLOC()
//            PYLAPIHandler.handler.getBranchesAvailability(userLatitude: tupleUserLoc.latitude, userLongitude: tupleUserLoc.longitude, success: { (response) in
//                self.successTaskBranchListAvailability(response)
//                }, failure: { (error) in
//            })
//        }else {
//            PYLAPIHandler.handler.getBranchesAvailability(countryId: manuallyLocValue!.countryId, pinCode: manuallyLocValue!.pinCode, success: { (response) in
//                self.successTaskBranchListAvailability(response)
//                }, failure: { (error) in
//                    
//            })
//        }
//    }
    
//    func getBranchListWithPinWebService() {
//        //        countryId: manuallyLocValue!.countryId, pinCode: manuallyLocValue!.pinCode, //todo
//        PYLAPIHandler.handler.getBranchListWithPin(countryId: "", pinCode: "", success: { (response) in
//            switch (response["ResponseCode"]) {
//            case "200":
//                self.successTaskBranchListWithPinApi(response)
//            default :
//                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
//            }
//            }, failure: { (error) in
//                
//        })
//    }
    
    //MARK: - Fetch Value From API

    func successTaskGetAllBranchAPI(_ response: JSON) {
        let responseDict =  response.dictionaryObject!
        self.arrAllBranches  = responseDict["branch_details"] as! [AnyObject]
        self.branchListArray = buildDatasource((self.arrAllBranches as? [[String : AnyObject]])!)
        if self.branchListArray.count > 0{
          //NSSortDescriptor * SearchDescriptor = []
            //sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
          self.branchListArray  = (self.branchListArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "Key", ascending: true)]) as! [[String:AnyObject]] as [AnyObject]
            self.branchListTable.reloadData()
        }else{
            self.view.showToastWithMessage(NO_RESULT_FOUND)
        }
    }
    
//    func successTaskBranchListWithPinApi(response: JSON) {
//        let responseDict =  response.dictionaryObject!
//        self.branchListArray  = responseDict["branch_details"] as! [AnyObject]
//        if self.branchListArray.count > 0{
//            self.branchListTable.reloadData()
//        }else{
//            self.view.showToastWithMessage(NO_RESULT_FOUND)
//        }
//    }
    
//    func successTaskBranchListAvailability(response: JSON) {
//        let isBranchAvailable = (response["isAvailable"].stringValue.getAESDecryption() == "True") ? true : false
//        guard isBranchAvailable else {
//            return
//        }
//        
//        //call branch list api here
//        if previousVcType == vCType.kCurrentLoc {
//            
//        }else {
//            self.getBranchListWithPinWebService()
//        }
//    }
}

func buildDatasource(_ fromArray:[[String : AnyObject]]) -> [AnyObject] {
    var resultArray = [AnyObject]()
    var keyGroup = [String]()
    for item in fromArray {
        keyGroup.append(item["branch_country"] as! String)
    }
   let uniqueKeys = Array(Set(keyGroup))
    for key in uniqueKeys {
        var intermidiateArray = [AnyObject]()
        for item in fromArray {
            if (item["branch_country"] as! String) == key {
               intermidiateArray.append(item as AnyObject)
            }
        }
        resultArray.append(["Value":intermidiateArray,"Key":"\(key.getAESDecryption())"] as AnyObject)
    }
    return resultArray
}


extension PYLBranchListViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return branchListArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = branchListArray[section] as? [String : AnyObject]
        if data != nil {
            return (data!["Value"] as! [AnyObject]).count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return IS_IPAD() ? 45 : 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let data = branchListArray[section] as! [String : AnyObject]
        var vw : UIControl!
        vw = Bundle.main.loadNibNamed("MenuSectionHeader", owner: self, options: nil)?[1] as! UIControl
        vw.backgroundColor = DEFAULT_COLOR
        vw.tag = section
        let title = vw.viewWithTag(12) as? UILabel

        if title != nil {
            title?.text = (data["Key"] as? String)!
            title?.font = UIFont.init(name: FONT_BOLD, size: IS_IPAD() ? 21 : 17)
            title?.textColor = UIColor.white
        }
        return vw
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLBranchListTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLBranchListTableViewCell.self)) as! PYLBranchListTableViewCell
        
        //let lastRowIndex = tableView.numberOfRowsInSection(tableView.numberOfSections-1)
        let data = branchListArray[indexPath.section] as? [String : AnyObject]
        cell.datasource = (data!["Value"] as! [AnyObject])[indexPath.row]
        let dataArr = branchListArray[indexPath.section] as? [String : AnyObject]
        cell.datasource = (dataArr!["Value"] as! [AnyObject])[indexPath.row]
        cell.showMapOnTap = { (lat,long,name,address) in
            let requiredData = [["branch_name":name, "branch_address":address, "branch_latitude":lat, "branch_longitude":long]]
            let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLBranchLocatorMapViewController.self)) as? PYLBranchLocatorMapViewController
            viewController?.mapData = requiredData as [AnyObject]
            viewController?.allBranchPinListArray = dataArr!["Value"] as! [AnyObject] as NSArray
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
        }
        
        cell.callOnTap = { number in
            let url = URL(string: "telprompt://" + number!)
            if url != nil{
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(url!)) {
                    application.openURL(url!);
                }else{
                    self.view.showToastWithMessage("Not available")
                }
            }
        }
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

