//
//  PYLMyProfileViewController.swift
//  Peyala
//
//  Created by Adarsh on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

let LabelTag = 100
let HeightProfileImageCell = 188.0
let HeightHeaderCell = IS_IPAD() ?70.0:56.0
let HeightAddressTextViewCell = 100.0
let HeightAddressCell = 77.0
let HeightNotificationEnableCell = 71.0

class PYLMyProfileViewController: PYLBaseViewController {
    
    enum attributeType: Int {
        case kGender
        case kDob
        case kPinCode
        case kPhone
        case kFirstName
        case kLastName
        case kAddress
        case kEmail
    }
    
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var buttonEditProfile: UIButton!
    
    var arrData:[[String:AnyObject]] = []
    var isProfileImageChanged = false
    var viewFooter = UIView()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(MY_PROFILE_SCREEN, isGoogle: true, isFB: true)
    }
    
    // MARK: - User Defined Function
    func setUpperNavigationItems() {
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = true
        self.cartButtonEnabled = true
        self.title = "MY PROFILE"
    }
    
    func setupUI() {
        populateDataArray()
        tableViewProfile.reloadData()
        
        viewFooter = UIView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: 70))
        viewFooter.backgroundColor = UIColor.clear
        let buttonSubmit = UIButton(frame: CGRect(x: 0,y: 0,width: viewFooter.bounds.width*0.6,height: viewFooter.bounds.height*0.55))
        buttonSubmit.center = viewFooter.center
        buttonSubmit.backgroundColor = DEFAULT_COLOR
        buttonSubmit.setTitle("Update Profile", for: .normal)
        buttonSubmit.addTarget(self, action: #selector(PYLMyProfileViewController.submitBtnAction(_:)), for: .touchUpInside)
        buttonSubmit.layer.cornerRadius = 5.0
        viewFooter.addSubview(buttonSubmit)
        showFooterInTableView(false)
    }
    
    func showFooterInTableView(_ shouldShow:Bool) {
        if (shouldShow) {
            tableViewProfile.tableFooterView = viewFooter
        } else {
            tableViewProfile.tableFooterView = UIView()
        }
    }
    
    func enableProfileEditableMode(shouldEnable:Bool) {
        self.view.endEditing(!shouldEnable)
        let textFieldSectionIndex = 1
        var i = 0
        for var dictRow in arrData[textFieldSectionIndex]["value"] as! Array<Dictionary<String,AnyObject>> {
            dictRow["isEnabled"] = shouldEnable ? "1" as AnyObject? : "0" as AnyObject?
            var valueArray:[AnyObject] = self.arrData[textFieldSectionIndex]["value"] as! [AnyObject]
            valueArray[i] = dictRow as AnyObject
            self.arrData[textFieldSectionIndex]["value"] = valueArray as AnyObject?
            i += 1
        }
        debugPrint(self.arrData[textFieldSectionIndex]["value"] ?? "")
        tableViewProfile.reloadData()
        //        self.view.endEditing(!shouldEnable)
        showFooterInTableView(shouldEnable)
    }
    
    func populateDataArray() {
        arrData = []
        let image = #imageLiteral(resourceName: "PeyalaLogo")
        let arrSectionUserImage: [[String:AnyObject]] = [["name":((PYLHelper.helper.userModelObj?.firstName)! as String + " " + (PYLHelper.helper.userModelObj?.lastName)!) as AnyObject,"imageURL":PYLHelper.helper.userModelObj!.profileImageUrl as AnyObject,"image":image,"cellId":String(describing: PYLProfileImageCell.self) as String as AnyObject]]
        arrData.append(["sectionName":"User Image" as AnyObject,"value":arrSectionUserImage as AnyObject])
        
        let addressCellID = String(describing: PYLAddressCell.self)
        let strDob = PYLHelper.helper.userModelObj!.dob.isBlank ? "" : PYLHelper.helper.userModelObj!.dob.ConvertDateToFormat(LOCAL_DATE_FORMAT, fromFormat:SERVER_DATE_FORMAT)
        let arrSectionProfileDetails = [["attribute":"Profile Details","cellId":"PYLHeaderCell"],
                                        ["attribute":"First Name", "value":PYLHelper.helper.userModelObj!.firstName,"isAddress":"0","isEnabled":"0", "cellId":addressCellID,"attributeType":NSNumber(value: attributeType.kFirstName.rawValue)],
                                        ["attribute":"Last Name", "value":PYLHelper.helper.userModelObj!.lastName,"isAddress":"0","isEnabled":"0", "cellId":addressCellID,"attributeType":NSNumber(value: attributeType.kLastName.rawValue)],
                                        ["attribute":"Address", "value":PYLHelper.helper.userModelObj!.address,"isAddress":"1","isEnabled":"0", "cellId":"PYLAddressTextViewCell","attributeType":NSNumber(value: attributeType.kAddress.rawValue)],
                                        ["attribute":"Phone No", "value":PYLHelper.helper.userModelObj!.phone,"isAddress":"0","isEnabled":"0","isNumber":"1", "cellId":addressCellID,"attributeType":NSNumber(value: attributeType.kPhone.rawValue)],
                                        ["attribute" : "Email ID", "value" : PYLHelper.helper.userModelObj!.email,"isAddress":"0","isEnabled":"0", "cellId" : addressCellID,"attributeType":NSNumber(value: attributeType.kEmail.rawValue)],
                                        ["attribute":"Gender", "value":PYLHelper.helper.userModelObj!.gender,"isAddress":"0","isEnabled":"0", "cellId": addressCellID,"attributeType":NSNumber(value: attributeType.kGender.rawValue)],
                                        ["attribute":"Date of Birth", "value":strDob,"isAddress":"0","isEnabled":"0", "cellId": addressCellID,"attributeType":NSNumber(value: attributeType.kDob.rawValue)],
                                        ["attribute":"Postal Code", "value":PYLHelper.helper.userModelObj!.zipCode,"isAddress":"0","isEnabled":"0","isNumber":"1", "cellId": addressCellID,"attributeType":NSNumber(value: attributeType.kPinCode.rawValue)]]
        arrData.append(["sectionName":"Profile details" as AnyObject,"value":arrSectionProfileDetails as AnyObject])
        
        //section-3
        let arrSectionSettings = [["attribute":"Settings","cellId":"PYLHeaderCell"],
                                  ["attribute":"Notification","value":GET_NOTIFICATION_STATUS(),"cellId":String(describing: PYLNotificationEnableCell.self)]]
        arrData.append(["sectionName":"Settings" as AnyObject,"value":arrSectionSettings as AnyObject])
    }
    
    func validateFields(_ firstName: String, lastName: String, phone: String,  email: String, gender: String, dob: String, postalCode: String) -> Bool {
        //        !firstName.isBlank && !lastName.isBlank && !address.isBlank && !phone.isBlank && !email.isBlank && !gender.isBlank && !dob.isBlank && !postalCode.isBlank
        var validate = true
        if firstName.isBlank {
            validate = false
            self.view.showToastWithMessage("First Name"+LEFT_BLANK)
        }
        else if lastName.isBlank {
            validate = false
            self.view.showToastWithMessage("Last Name"+LEFT_BLANK)
        }
        else if phone.isBlank {
            validate = false
            self.view.showToastWithMessage("Phone No."+LEFT_BLANK)
        }
        else if email.isBlank {
            validate = false
            self.view.showToastWithMessage("Email"+LEFT_BLANK)
        }
        else if gender.isBlank {
            validate = false
            self.view.showToastWithMessage("Gender"+LEFT_BLANK)
        }
        else if dob.isBlank {
            validate = false
            self.view.showToastWithMessage("DOB"+LEFT_BLANK)
        }
        else if postalCode.isBlank {
            validate = false
            self.view.showToastWithMessage("Postal Code"+LEFT_BLANK)
        }
        
        return validate
    }
    
    func showPeyalaCash(_ sender:UIButton) {
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLMyPeyalaCashViewController.self)) as! PYLMyPeyalaCashViewController
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - API section
    
    func callEditProfileApi()
    {
        let arrSectionOne = arrData[0]["value"] as! [[String:AnyObject]]
        let profileImage:UIImage? = isProfileImageChanged ? arrSectionOne[0]["image"] as? UIImage : nil
        
        let arrSectionTwo = arrData[1]["value"] as! [[String:AnyObject]]
        let firstName = arrSectionTwo[1]["value"] as! String
        let lastName = arrSectionTwo[2]["value"] as! String
        let address = arrSectionTwo[3]["value"] as! String
        let phone = arrSectionTwo[4]["value"] as! String
        let email = arrSectionTwo[5]["value"] as! String
        let gender = arrSectionTwo[6]["value"] as! String
        let dob = arrSectionTwo[7]["value"] as! String
        let postalCode = arrSectionTwo[8]["value"] as! String
        
        //        guard !firstName.isBlank && !lastName.isBlank && !address.isBlank && !phone.isBlank && !email.isBlank && !gender.isBlank && !dob.isBlank && !postalCode.isBlank else {
        //            self.view.showToastWithMessage(ANY_FIELD_BLANK)
        //            return
        //        }
        
        guard validateFields(firstName, lastName: lastName, phone: phone, email: email, gender: gender, dob: dob, postalCode: postalCode) else {
            return
        }
        
        PYLAPIHandler.handler.editProfile(firstname: firstName, lastname: lastName, gender: gender, dob: dob, email: email, phone_no: phone, zipcode: postalCode, address: address, imageFile: profileImage, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTaskEditProfileApi(response!)
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
            
        }) { (errorMsg) in
            self.view.showToastWithMessage(errorMsg)
        }
    }
    
    func callNotificationSettingsApi(_ isEnable:Bool, success:@escaping (_ response:JSON)->())
    {
        PYLAPIHandler.handler.setNotificationSettings(isEnable, success: { (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                success(response!)
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
            }
            
        }) { (error) in
            //self.view.showToastWithMessage(error.description)
        }
        
    }
    
    
    func successTaskEditProfileApi(_ response: JSON) {

        self.view.showToastWithMessage(response["Responsedetails"].stringValue)
        buttonEditProfile.isSelected = !buttonEditProfile.isSelected
        enableProfileEditableMode(shouldEnable:buttonEditProfile.isSelected)
        PYLHelper.helper.userModelObj = ModelUser(userID: response["Userid"].stringValue.getAESDecryption(), firstName: response["firstname"].stringValue.getAESDecryption(), lastName: response["lastname"].stringValue.getAESDecryption(), email: response["email"].stringValue.getAESDecryption(), address: response["address"].stringValue.getAESDecryption(), profileImageUrl: response["profile_image_url"].stringValue.getAESDecryption(),phone:response["phone_no"].stringValue.getAESDecryption(),zipCode:response["zip_code"].stringValue.getAESDecryption(),gender:response["gender"].stringValue.getAESDecryption(),dob:response["dob"].stringValue.getAESDecryption(),loyaltypoint : "loyaltypoint",loyaltypercentage : "loyaltypercentage", loyaltycash: "loyaltycash",loyaltyunitvalue: "loyaltyunitvalue")
        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
        populateDataArray()
        tableViewProfile.reloadData()
    }
    
    //MARK: - ACTIONS
    func submitBtnAction(_ sender: UIButton) {
        trackButtonTapEventsForAnalytics(actionName: EDIT_PROFILE_EVENT, tapsRequired: "1")
        callEditProfileApi()
    }
    @IBAction func editProfileBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        enableProfileEditableMode(shouldEnable:sender.isSelected)
    }
}

extension PYLMyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0.0
        let cellID = ((arrData[indexPath.section]["value"] as! Array<Dictionary<String,AnyObject>>)[indexPath.row])["cellId"] as! String
        switch cellID {
        case String(describing: PYLProfileImageCell.self):
            height = HeightProfileImageCell
            
        case "PYLHeaderCell":
            height = HeightHeaderCell
            
        case String(describing: PYLAddressCell.self):
            height = HeightAddressCell
            
        case "PYLAddressTextViewCell":
            height = HeightAddressTextViewCell
            
        case String(describing: PYLNotificationEnableCell.self):
            height = HeightNotificationEnableCell
            
        default:
            break
        }
        return CGFloat(height)
    }
}

extension PYLMyProfileViewController: UITableViewDataSource {
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
        case String(describing: PYLProfileImageCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLProfileImageCell.self), for: indexPath) as! PYLProfileImageCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.changeImageBtnTapped = {
                PYLImagePicker.showImagePickerOn(self, belowView:cell.buttonChange, selectedImageCompletion: { (image) in
                    if let img = image {
                        self.isProfileImageChanged = true
                        var dict = cell.datasource as! Dictionary<String,AnyObject>
                        dict["image"] = img
                        dict["imageURL"] = "" as AnyObject?
                        var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                        valueArray[indexPath.row] = dict as AnyObject
                        self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                        //                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        tableView.reloadData()
                        //below 2 lines is done make the whole form editable again on choosing the image.
                        self.buttonEditProfile.isSelected = true
                        self.enableProfileEditableMode(shouldEnable:self.buttonEditProfile.isSelected)
                    }
                })
            }
            cellGlobal = cell
            
        case "PYLHeaderCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PYLHeaderCell", for: indexPath)
            let datasource = ((arrData[indexPath.section] as [String:AnyObject])["value"] as! [[String:AnyObject]])[indexPath.row]
            let labelHeader = cell.viewWithTag(LabelTag+1) as! UILabel
            labelHeader.text = datasource["attribute"] as? String
            
            let buttonPeyalaCash = cell.viewWithTag(ButtonBaseTag+33) as! UIButton
            
            if labelHeader.text! == "Profile Details" {
                buttonPeyalaCash.isHidden = false
                buttonPeyalaCash.isEnabled = true
                buttonPeyalaCash.addTarget(self, action: #selector(PYLMyProfileViewController.showPeyalaCash(_:)), for: .touchUpInside)
            }
            else {
                buttonPeyalaCash.isHidden = true
            }
            cellGlobal = cell
            
        case String(describing: PYLAddressCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLAddressCell.self), for: indexPath) as! PYLAddressCell
            cell.datasource = ((arrData[indexPath.section] )["value"] as! Array)[indexPath.row]
            cell.textFieldEndedEditing = { (fieldValue) in
                var dict = cell.datasource as! Dictionary<String,AnyObject>
                dict["value"] = fieldValue as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            cell.textFieldBeginEditing = { (fieldValue,attributeTypeValue) in
                var dict = cell.datasource as! Dictionary<String,AnyObject>
                dict["value"] = fieldValue as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            //UI
            if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1)  {
                cell.constraintCurveViewTxtFldBottom.constant = 4.0 //correct value
                cell.viewLineGray.isHidden = true
            }
            else {
                cell.constraintCurveViewTxtFldBottom.constant = 20.0 //this number can be anything, but should be quite greater than 4.
                cell.viewLineGray.isHidden = false
            }
            cellGlobal = cell
            
        case "PYLAddressTextViewCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PYLAddressTextViewCell", for: indexPath) as! PYLAddressCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.textViewEndedEditing = { (fieldValue) in
                var dict = cell.datasource as! Dictionary<String,AnyObject>
                dict["value"] = fieldValue as AnyObject?
                var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                valueArray[indexPath.row] = dict as AnyObject
                self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                debugPrint(self.arrData)
            }
            cellGlobal = cell
            
            
        case String(describing: PYLNotificationEnableCell.self):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLNotificationEnableCell.self), for: indexPath) as! PYLNotificationEnableCell
            cell.datasource = (arrData[indexPath.section]["value"] as! Array)[indexPath.row]
            cell.notificationTapped = { (enable) in
                
                self.callNotificationSettingsApi(enable, success: { (response) in
                    if(response["ResponseCode"] == "200")
                    {
                        var dict = cell.datasource as! Dictionary<String,AnyObject>
                        dict["value"] = enable ? "1" as AnyObject? : "0" as AnyObject?
                        SET_NOTIFICATION_STATUS("\(dict["value"])")
                        var valueArray:[AnyObject] = self.arrData[indexPath.section]["value"] as! [AnyObject]
                        valueArray[indexPath.row] = dict as AnyObject
                        self.arrData[indexPath.section]["value"] = valueArray as AnyObject?
                        tableView.reloadData()
                    }
                    
                })
            }
            cellGlobal = cell
            
        default:
            break
        }
        cellGlobal.backgroundColor = UIColor.clear
        
        return cellGlobal
    }
}
