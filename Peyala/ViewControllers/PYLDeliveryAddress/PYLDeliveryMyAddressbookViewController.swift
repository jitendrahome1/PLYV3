//
//  PYLDeliveryMyAddressbookViewController.swift
//  Peyala
//
//  Created by Adarsh on 14/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let HeightAddressbookHeaderCell = 62.0
let HeightRadioButtonCell = IS_IPAD() ? 69.0 : 51.0


class PYLDeliveryMyAddressbookViewController: PYLBaseViewController {
    
    // MARK: - Outlet Connections
    
    @IBOutlet weak var tableViewData: UITableView!
    @IBOutlet weak var buttonAddNewAddress: UIButton!
    
    var arrData:[Dictionary<String,AnyObject>] = []
    var Address = [AnyObject]()
    var deleteIndexpath: NSIndexPath?
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        self.view.layoutIfNeeded()

        buttonAddNewAddress.imageTitleCenteringwithSpacing(50)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         getMySavedAddress()
    }
    // MARK: - User Defined Function
    
    func setupUI() {
        tableViewData.backgroundColor = UIColor.clear
    }
    
    
    func setUpperNavigationItems() {
        
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.title = "DELIVERY ADDRESS"
    }
    
    func populateDataArray(_ address:AnyObject!) {
        tableViewData.hideNoDataLabel()
        arrData = [["attribute":"My Addressbook" as AnyObject,"cellId":"PYLHeaderCell" as AnyObject]]
        if  let addressArr = address as? Array<[String:String]> {
            if addressArr.count>0 {
                for (item) in addressArr {
                  //arrData.append(["attribute":item["address_line2"]!.getAESDecryption() + ", " + item["city"]!.getAESDecryption(),"isSelected":"0","cellId":"PYLRadioButtonCell"])
                    arrData.append(["attribute":item["address_line2"]!.getAESDecryption() as AnyObject,"isSelected":"0" as AnyObject,"cellId":"PYLRadioButtonCell" as AnyObject])
                }
            }else{
                tableViewData.showNodataLabelWithText("No saved address")
                //arrData.append(["attribute":"No address found","isSelected":"0","cellId":"PYLRadioButtonCell"])
               // arrData.append(["attribute":"Faridpur","isSelected":"1","cellId":"PYLRadioButtonCell"])
            }
        }
        tableViewData.reloadData()
    }
    
    func getMySavedAddress() {
        PYLAPIHandler.handler.getMyDeliveryAddress({ (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                let address = response?["address_details"].arrayObject
                self.populateDataArray(address as AnyObject!)
                self.Address = address! as [AnyObject]
                
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                break
                //self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
        }) { (error) in
                
        }
    }
    
    // MARK: - Button actions
    @IBAction func addNewAddressBtnAction(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueNewAddress") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let VC = segue.destination as! PYLDeliveryAddressMapViewController
            VC.shouldSaveAddInDirectory = "1"
        }
    }
    
    func deleteDeliveryAddress(_ addressID: String) {
        
        PYLAPIHandler.handler.deleteDeliveryAddress([addressID], success: { (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                _ = response?["address_details"].arrayObject
                //self.tableViewData.reloadData()
                self.Address.remove(at: (self.deleteIndexpath?.row)!)
                self.populateDataArray(self.Address as AnyObject!)
                //self.tableViewData.beginUpdates()
                //self.tableViewData.deleteRowsAtIndexPaths([self.deleteIndexpath!], withRowAnimation: .Fade)
                //elf.tableViewData.endUpdates()

            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage((response!["Responsedetails"].stringValue), delayTime: 2)
            }
        }) { (error) in
            
        }
    }
}

extension PYLDeliveryMyAddressbookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellID = arrData[indexPath.row]["cellId"] as! String
        switch cellID {
        case "PYLRadioButtonCell":
            for i in 1...(arrData.count - 1) {
                var dataSource = arrData[i]
                dataSource["isSelected"] = (i == indexPath.row) ? "1" as AnyObject? : "0" as AnyObject?
                arrData[i] = dataSource
            }
            tableViewData.reloadData()
        default:
            break
        }
        
        navigateToEditAddress(self.Address[indexPath.row - 1])
    }
    
    func navigateToEditAddress(_ address:AnyObject!){

        let viewController = self.storyboard!.instantiateViewController( withIdentifier: String(describing: PYLNewDeliveryAddressViewController.self)) as! PYLNewDeliveryAddressViewController
        viewController.EditAddress = address
        viewController.shouldSaveAddressInDirectory = "1"
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0.0
        let cellID = arrData[indexPath.row]["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            height = HeightAddressbookHeaderCell
            
        case "PYLRadioButtonCell":
            height = HeightRadioButtonCell
            
        default:
            break
        }
        return CGFloat(height)
    }
    
    @objc(tableView:canEditRowAtIndexPath:) func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @nonobjc func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let alertController = UIAlertController.showStandardAlertWith("", alertText: "Do you want to delete this address from your address book?", cancelTitle: "", doneTitle: "", selected_: { (index) in
                
                if index == 1 {
                    self.deleteIndexpath = IndexPath(row:indexPath.row-1, section: 0) as NSIndexPath?
                    self.deleteDeliveryAddress((self.Address[indexPath.row-1]["address_id"] as? String)!)
                }
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PYLDeliveryMyAddressbookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellGlobal = UITableViewCell()
        let cellID = arrData[indexPath.row]["cellId"] as! String
        switch cellID {
        case "PYLHeaderCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            cell.isUserInteractionEnabled = false
            cellGlobal = cell
            
        case "PYLRadioButtonCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
            let dataSource = arrData[indexPath.row]
            let buttonOk = cell.viewWithTag(ButtonBaseTag+1) as! UIButton
            buttonOk.isSelected = (dataSource["isSelected"] as! String) == "1"
            let buttonAttribute = cell.viewWithTag(ButtonBaseTag+2) as! UIButton
            buttonAttribute.setTitle(dataSource["attribute"] as? String, for: .normal)
            cellGlobal = cell
            
            
        default:
            break
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
