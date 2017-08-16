//
//  PYLDeliveryAddressMapViewController.swift
//  Peyala
//
//  Created by Adarsh on 14/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import MapKit
import GoogleMaps
import GooglePlacePicker
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


class PYLDeliveryAddressMapViewController: PYLBaseViewController,GMSMapViewDelegate, UITextFieldDelegate {
    
    //MARK: - Outlet Collections
    @IBOutlet weak var autocompleteTextfield: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var selectedPointAnnotation:MKPointAnnotation?
    fileprivate var dataTask:URLSessionDataTask?
    @IBOutlet var mapViewAddress: GMSMapView!
    @IBOutlet weak var buttonConfirm: UIButton!
    var latitude : String!
    var longitude : String!
    var pinmarker = GMSMarker()
    var pinPosition : CLLocationCoordinate2D!
    var addressLine1 = ""
    var addressLine2  = ""
    var city   = ""
    var zip    = ""
    var fullAdress = ""
    var arrdata : [[String : Any]]!
    let geoCoder = GMSGeocoder()
    var shouldSaveAddInDirectory = ""
    
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        getCurrentLocation{
            
//            self.pinPosition = CLLocationCoordinate2D(latitude: PYLHelper.helper.latitude!.toDouble()!, longitude: PYLHelper.helper.longitude!.toDouble()!)
//            let position = self.pinPosition
//            self.pinmarker = GMSMarker(position: position)
//            self.pinmarker.icon = UIImage(named: "OrderConfirmationPeyalaLocation")
//            self.pinmarker.map = self.mapViewAddress
//            //pinmarker.groundAnchor = CGPointMake(0.5, 0.5)
////            self.pinmarker.title = "Test Title"
////            self.pinmarker.snippet = "Test Snippet"
//            self.pinmarker.draggable = true
//            let camera = GMSCameraPosition.cameraWithLatitude(self.pinPosition.latitude, longitude: self.pinPosition.longitude, zoom: 15.0)
//            //let camera = GMSCameraPosition.cameraWithLatitude(self.pinPosition.latitude, longitude: self.pinPosition.longitude, zoom: 15.0, bearing: 90, viewingAngle: 45)
//            self.mapViewAddress.camera = camera
//            self.getAddressFromGeoCoder(self.pinmarker.position.latitude, longitude: self.pinmarker.position.longitude,completion: {(strAddress) in
//                self.pinmarker.snippet = strAddress
//            })
            
            DispatchQueue.main.async(execute: {
                self.pinPosition = CLLocationCoordinate2D(latitude: PYLHelper.helper.latitude!.toDouble()!, longitude: PYLHelper.helper.longitude!.toDouble()!)
                let position = self.pinPosition
                self.pinmarker = GMSMarker(position: position!)
                self.pinmarker.icon = UIImage(named: "OrderConfirmationPeyalaLocation")
                self.pinmarker.map = self.mapViewAddress
                //pinmarker.groundAnchor = CGPointMake(0.5, 0.5)
                //            self.pinmarker.title = "Test Title"
                //            self.pinmarker.snippet = "Test Snippet"
                self.pinmarker.isDraggable = true
                let camera = GMSCameraPosition.camera(withLatitude: self.pinPosition.latitude, longitude: self.pinPosition.longitude, zoom: 15.0)
                //let camera = GMSCameraPosition.cameraWithLatitude(self.pinPosition.latitude, longitude: self.pinPosition.longitude, zoom: 15.0, bearing: 90, viewingAngle: 45)
                self.mapViewAddress.camera = camera
                self.getAddressFromGeoCoder(self.pinmarker.position.latitude, longitude: self.pinmarker.position.longitude,completion: {(strAddress) in
                    self.pinmarker.snippet = strAddress
                })
            })
        }
        
        mapViewAddress.isMyLocationEnabled = true
        mapViewAddress.delegate = self
        configureTextField()
        handleTextFieldInterfaces()
        
        
        
        //        let addressCoordinates = CLLocationCoordinate2DMake(40.4375, -3.6818)
        //        
        //        let coder = GMSGeocoder()
        //        coder.reverseGeocodeCoordinate(addressCoordinates) { (results, error) in
        //            if error != nil {
        //                
        //            } else {
        //                let address:GMSAddress = (results?.firstResult())!
        //                debugPrint("country \(address.country)")
        //                debugPrint("locality %@",address.locality);
        //                debugPrint("postalCode %@",address.postalCode);
        //            }
        //        }
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
     //Google place picker controller
     @IBAction func pickPlace() {
     
     let center = pinPosition
     let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
     let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
     let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
     let config = GMSPlacePickerConfig(viewport: viewport)
     placePicker = GMSPlacePicker(config: config)
     placePicker.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
     if let error = error {
     print("Pick Place error: \(error.localizedDescription)")
     return
     }
     
     if let place = place {
     print("Place name \(place.name)")
     print("Place address \(place.formattedAddress)")
     print("Place attributions \(place.attributions)")
     } else {
     print("No place selected")
     }
     })
     }
     */
    
    // MARK: - User Defined Function
    func setUpperNavigationItems() {
        
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.title = "DELIVERY ADDRESS"
    }
    
    fileprivate func configureTextField(){
        autocompleteTextfield.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autocompleteTextfield.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        autocompleteTextfield.autoCompleteCellHeight = 35.0
        autocompleteTextfield.maximumAutoCompleteCount = 20
        autocompleteTextfield.hidesWhenSelected = true
        autocompleteTextfield.hidesWhenEmpty = true
        autocompleteTextfield.enableAttributedText = true
        autocompleteTextfield.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autocompleteTextfield.autoCompleteAttributes = attributes
        autocompleteTextfield.textAlignment = .left
        autocompleteTextfield.autocorrectionType = .no
        autocompleteTextfield.modifyClearButtonWithImage(UIImage(named: "CloseIcon")!)
        
        autocompleteTextfield.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
        let image = UIImage(named: "HeaderGreenSearchIcon")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        autocompleteTextfield.leftView = imageView
        
    }
    
    
    fileprivate func handleTextFieldInterfaces(){
        autocompleteTextfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        autocompleteTextfield.onSelect = {[weak self] text, utilityDictObj, indexpath in
            self?.view.endEditing(true)
            let placeID = utilityDictObj["placeID"] as! String
            let place = GMSPlacesClient()
            place.lookUpPlaceID(placeID) { (placeObj, error) in
                //                placeObj!.coordinate
                debugPrint(placeObj!.coordinate)
                self?.addAnnotation(placeObj!.coordinate, address: text)
                let camera = GMSCameraPosition.camera(withLatitude: placeObj!.coordinate.latitude, longitude: placeObj!.coordinate.longitude, zoom: 15.0)
                self?.mapViewAddress.camera = camera
            }
        }
    }
    
    //MARK: - Private Methods
    fileprivate func addAnnotation(_ coordinate:CLLocationCoordinate2D, address:String?){
        pinPosition = coordinate
        pinmarker.position = pinPosition
        //let camera = GMSCameraPosition.cameraWithLatitude(pinPosition.latitude, longitude: pinPosition.longitude, zoom: 15.0)
        //mapViewAddress.camera = camera
        self.view.endEditing(true)
        
        getAddressFromGeoCoder(coordinate.latitude, longitude: coordinate.longitude,completion: {(strAddress) in
            self.pinmarker.snippet = strAddress
        })
        
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleAPIKey)&input=\(keyword)"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"]! as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? [Any]{
                                        var locations = [String]()
                                        var arrPlaceDict = [[String:AnyObject]]()
                                        for dict in predictions as! [NSDictionary]{
                                            locations.append(dict["description"] as! String)
                                            arrPlaceDict.append(["placeID":dict["place_id"]! as AnyObject])
                                            debugPrint(dict)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.autocompleteTextfield.autoCompleteStrings = locations
                                            self.autocompleteTextfield.autoCompleteUtilityObjects = arrPlaceDict
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.autocompleteTextfield.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
    func getAddressFromGeoCoder(_ latitude: Double, longitude: Double, completion:@escaping (_ strAddress:String)->()) {
        
        let addressCoordinates = CLLocationCoordinate2DMake(latitude, longitude)
        geoCoder.reverseGeocodeCoordinate(addressCoordinates) { (results, error) in
            if error == nil {
                if results != nil {
                    let address:GMSAddress = (results?.firstResult())!
                    
                    debugPrint("\ncoordinate.latitude=\(address.coordinate.latitude)")
                    debugPrint("coordinate.longitude=\(address.coordinate.longitude)")
                    //debugPrint("thoroughfare=\(address.thoroughfare)")
                    //debugPrint("locality=\(address.locality)") // this is city
                    //debugPrint("subLocality=\(address.subLocality)")
                    //debugPrint("administrativeArea=\(address.administrativeArea)") // this is state
                    //debugPrint("country=\(address.country)")
                    debugPrint("postalCode=\(address.postalCode)")
                    debugPrint("lines=\(address.lines)")
                    self.zip = ""
                    self.fullAdress = ""
                    
                    if let zipCode = address.postalCode {
                        self.zip = zipCode
                    }
                    if let addressArray = address.lines {
                        if addressArray.count > 0 {
                            for i in 0..<addressArray.count {
                                self.fullAdress = self.fullAdress + addressArray[i]
                            }
                        }
                    }
                    //self.autocompleteTextfield.text = address.lines?.first
                    //completion(strAddress: self.fullAdress)
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let addressArray = address.lines {
                            if addressArray.count > 0 {
                                let firstText = addressArray[0]
                                if firstText.length > 0 {
                                    self.autocompleteTextfield.text = address.lines?.first
                                } else {
                                    if addressArray.count >= 1 {
                                        self.autocompleteTextfield.text = addressArray[1]
                                    }
                                }
                            }
                        }
                    })
                    completion(self.fullAdress)
                    
                } else {
                    // show message accordingly
                }
            }
            else {
                // show message accordingly
            }
        }
    }
    
    func validateAddressForBranchAvailability() {
        
        //        fullAdress = "hyygqe uhgudgwdf dbhguydwgfed kjgahusdg kjgusad sdjmkbguidagc askubgdcas dmbaskudas dmjbjkASBXCd acxjbgsa dasjdbguas d jhdbaw kjabqdwe qekjbdjq dqhjbdqebd jqwed jqwbd b djwbdwn bjsqdb jmnbdjsw dnws bbd dhjnwbdw  jbsn dn swbd hwvdw hvw dhnvbw dhnwd v wdbhvw dwh d"
        self.arrdata = [["attribute":"Delivery Address" as AnyObject,"cellId":"PYLHeaderCell" as AnyObject],
                        ["attribute":"Flat No." as AnyObject,"attributeText":"Flat no./House no./Apt Name" as AnyObject,"value":"" as AnyObject,"isAddress":"0" as AnyObject,"cellId":String(describing:PYLDeliveryEnterTextCell.self) as AnyObject],
                        ["attribute":"Landmark" as AnyObject,"attributeText":"Landmark" as AnyObject,"value":"" as AnyObject,"isAddress":"0","cellId":String(describing: PYLDeliveryEnterTextCell.self)],
                        ["attribute":"Address","attributeText":"Address details","value":"\(fullAdress)","isAddress":"1","cellId":"PYLDeliveryEnterTextCellAddress"],
                        ["attribute":"Postal Code","attributeText":"Postal Code","value":"\(self.zip)","isAddress":"0","cellId":String(describing: PYLDeliveryEnterTextCell.self)],
                        ["attribute":"Phone No.","attributeText":"Phone No.","value":PYLHelper.helper.userModelObj!.phone,"isAddress":"0","cellId":"PYLDeliveryEnterTextCell"],
                        ["attribute":"OK","cellId":"PYLDeliveryButtonCell"]]
        
        self.checkServiceOptionAvailable({ (isAvailable , addressID) in
            if isAvailable == true {
                DispatchQueue.main.async {
                    let viewController = self.storyboard!.instantiateViewController( withIdentifier: String(describing: PYLNewDeliveryAddressViewController.self)) as! PYLNewDeliveryAddressViewController
                    viewController.shouldSaveAddressInDirectory = self.shouldSaveAddInDirectory
                    viewController.arrData = self.arrdata as [Dictionary<String, AnyObject>]
                    viewController.latLong = ("\(self.pinPosition.latitude)" ,"\(self.pinPosition.longitude)")
                    viewController.addressID = addressID
                    PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
                }
            }else{
                
            }
        })
    }
    
//    func getAddressForLatLng(latitude: String, longitude: String) {
//        
//        PYLSpinner.show()
//        let url = "\(googleBaseUrl)latlng=\(latitude),\(longitude)&key=\(googleAPIKey)"
//        //url "https://maps.googleapis.com/maps/api/geocode/json?latlng=19.0176147,72.8561644&key=AIzaSyDAHiODmRMtFhuEe6KM5EEtU7CkthafiDk"
//        // https://maps.googleapis.com/maps/api/geocode/json?latlng=22.5988,88.4319&key=AIzaSyDAHiODmRMtFhuEe6KM5EEtU7CkthafiDk
//        PYLAPIManager.sharedManager.request(.GET, url, parameters: nil, encoding: .URL, headers: nil).validate().responseJSON { (response) in
//            debugPrint("hide loader")
//            PYLSpinner.hide()
//            
//            if let result = response.result.value!["results"] as? [[String:AnyObject]] {
//                //var number = ""
//                self.addressLine1 = ""
//                self.addressLine2  = ""
//                self.city   = ""
//                self.zip    = ""
//                for resultDic:[String:AnyObject] in result{
//                    let key = (resultDic["types"] as! [String])[0]
//                    if key == "political"{
//                        
//                        self.addressLine2 = (resultDic["formatted_address"] as? String)!
//                        for dicAddressComp:[String:AnyObject] in (resultDic["address_components"] as? [[String:AnyObject]])!{
//                            let key = (dicAddressComp["types"] as! [String])[0]
//                            let Value = dicAddressComp["long_name"] as! String
//                            if key == "postal_code"{
//                                self.zip = Value
//                            }else if key == "country"{
//                                
//                            }
//                            else if (dicAddressComp["types"] as! Array).contains("sublocality_level_1") {//sublocality_level_1
//                                self.addressLine1 = dicAddressComp["long_name"] as! String
//                            }
//                            else if key == "administrative_area_level_2"{
//                                self.city = Value
//                            }
//                        }
//                    }
//                }
//                
//                var addressStr = self.addressLine2
//                if addressStr.length > 0 {
//                    
//                } else {
//                    addressStr = self.addressLine1
//                }
//                
//                if addressStr.length <= 2 {
//                    addressStr = self.autocompleteTextfield.text!
//                }
//                if addressStr.length == 0{
//                    self.view.showToastWithMessage("No Peyala branch available near you", delayTime: 2)
//                }else{
//                    self.arrdata = [["attribute":"Delivery Address","cellId":"PYLHeaderCell"],
//                        ["attribute":"Flat No.","attributeText":"Flat no./House no./Apt Name","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                        ["attribute":"Landmark","attributeText":"Landmark","value":"","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                        ["attribute":"Address","attributeText":"Address details","value":"\(addressStr)","isAddress":"1","cellId":"PYLDeliveryEnterTextCellAddress"],
//                        ["attribute":"Postal Code","attributeText":"Postal Code","value":"\(self.zip)","isAddress":"0","cellId":String(PYLDeliveryEnterTextCell)],
//                        ["attribute":"Phone No.","attributeText":"Phone No.","value":"","isAddress":"0","cellId":"PYLDeliveryEnterTextCell"],
//                        ["attribute":"OK","cellId":"PYLDeliveryButtonCell"]]
//                    
//                    self.checkServiceOptionAvailable({ (isAvailable , addressID) in
//                        if isAvailable == true {
//                            dispatch_async(dispatch_get_main_queue()) {
//                                let viewController = self.storyboard!.instantiateViewControllerWithIdentifier( String(PYLNewDeliveryAddressViewController)) as! PYLNewDeliveryAddressViewController
//                                viewController.arrData = self.arrdata
//                                viewController.latLong = ("\(self.pinPosition.latitude)" ,"\(self.pinPosition.longitude)")
//                                viewController.addressID = addressID
//                                PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
//                            }
//                        }else{
//                            
//                        }
//                    })
//                    
//                }
//            }
//        }
//    }
    
    //MARK: - Button Action
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        if autocompleteTextfield.text?.length > 0 {
            validateAddressForBranchAvailability()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addAnnotation(coordinate, address: "")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        addAnnotation(marker.position, address: "")
    }
    
    func checkServiceOptionAvailable(_ isServiceAvailable: @escaping (Bool,_ addressId:String)->()){
        let deliveryOption = PYLHelper.helper.selectedServiceType
        
        let addressToPost = [
            "address_id"   :  "",
            "address_line1": (arrdata[1]["value"] as! String).setAESEncription(),
            "address_line2": (arrdata[3]["value"] as! String).setAESEncription(),
            "landmark"     : (arrdata[2]["value"] as! String).setAESEncription(),
            "city"         : "".setAESEncription(),
            "pin"          : (arrdata[4]["value"] as! String).setAESEncription()
            
            ,
            "phone_no"     : (arrdata[5]["value"] as! String).setAESEncription()
        ]
        
        
        PYLAPIHandler.handler.getBranchesByServiceAndAddress(preferredServiceType: (deliveryOption?.rawValue)!, userLatitude: "\(pinPosition.latitude)", userLongitude: "\(pinPosition.longitude)", address: addressToPost, saveAddInUserDirectory: "0", success: { (response) in
            
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                if let branches = response?[ "branch_details"].arrayObject{
                    if branches.count > 0 {
                        PYLHelper.helper.placeOrderObj!.branchID =  (branches.count > 0 ?  (response?[ "branch_details"][0]["branch_id"].stringValue.getAESDecryption())! : "")
                        branches.count > 0 ? isServiceAvailable(true,(response?[ "address_id"].stringValue.getAESDecryption())!): isServiceAvailable(false,"")
                        
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
}
