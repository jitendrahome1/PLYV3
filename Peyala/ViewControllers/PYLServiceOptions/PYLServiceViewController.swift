//
//  PYLServiceViewController.swift
//  Peyala
//
//  Created by Soumen Das on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

enum DeliveryOption : String{
    case DineIn = "DINE_IN"
    case TakeAway = "TAKE_AWAY"
    case Delivery = "DELIVERY"
    case None = "NONE"
}

class PYLServiceViewController: PYLBaseTableViewController,UITextFieldDelegate {
    
    // Outlet Collections
    @IBOutlet weak var tableService:            UITableView!
    @IBOutlet weak var buttonDineIn:            UIButton!
    @IBOutlet weak var buttonDelivery:          UIButton!
    @IBOutlet weak var buttonAway:              UIButton!
    @IBOutlet weak var collectionViewBanner:    UICollectionView!
    @IBOutlet weak var pageControlBanner:       UIPageControl!
    @IBOutlet weak var serviceVehicleImage: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet var constraintVechileCenter: NSLayoutConstraint!
    
    var arrBanner:[Dictionary<String, AnyObject>] = []
    var timer = Timer()
    var selectedDeliveryOption:DeliveryOption = .None
    var phoneNo = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        //callBannerApi()
        collectionViewBanner.delegate = self
        collectionViewBanner.dataSource = self
        setUpUI()
        sizeHeaderToFit(self.tableService)
        self.animateVehicle()
        presentWithAnimation()
        dineInButtonActiom(nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        presentWithAnimation()
        trackScreenForAnalyticsWithName(SERVICE_OPTION_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerView = self.tableView.tableHeaderView as! HeaderView
        headerView.scrollViewDidScroll(scrollView)
    }
    override func viewDidDisappear(_ animated: Bool) {
        if timer.isValid {
            timer.invalidate()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Defined Function
    func presentWithAnimation() {
        buttonDineIn.alpha = 0.0
        buttonAway.alpha = 0.0
        buttonDelivery.alpha = 0.0
        
        let centreLabel1 = label1.center
        let centreLabel2 = label2.center
        
        label1.center.x = -label1.frame.width/2
        label2.center.x = self.view.bounds.width + label2.frame.width/2
        
        UIView.animate(withDuration: 0.5, delay: 1.70, options: .curveEaseIn, animations: {
            self.label1.center = centreLabel1
            self.label2.center = centreLabel2
        }) { (completed) in
            self.dropMenuOptions()
        }
    }
    
    func dropMenuOptions() {
        let centerDineIn = buttonDineIn.center
        let centerTakeAway = buttonAway.center
        let centerDelivery = buttonDelivery.center
        
        buttonAway.center = centerDineIn
        buttonDelivery.center = centerTakeAway
        let timeDropping = 0.2
        UIView.animate(withDuration: timeDropping, delay: 0.0, options: .curveEaseOut, animations: {
            self.buttonDineIn.alpha = 1.0
            self.buttonDineIn.center = centerDineIn
        }) { (completed) in
            
            UIView.animate(withDuration: timeDropping, delay: 0.0, options: .curveEaseOut, animations: {
                self.buttonAway.alpha = 1.0
                self.buttonAway.center = centerTakeAway
            }) { (completed) in
                
                UIView.animate(withDuration: timeDropping, delay: 0.0, options: .curveEaseOut, animations: {
                    self.buttonDelivery.alpha = 1.0
                    self.buttonDelivery.center = centerDelivery
                }) { (completed) in
                }
            }
        }
        
    }
    
    func animateVehicle() {
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        var frame = serviceVehicleImage.frame
        let OriginalFrame = frame
        frame.origin.x = -frame.size.width
        serviceVehicleImage.frame = frame
        let triggerTime = (Int64(NSEC_PER_SEC) * (1/2))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            UIView.animate(withDuration: 1.70, animations: {
                
                frame.origin.x = self.view.bounds.size.width + frame.size.width
                self.serviceVehicleImage.frame = frame
                
            }, completion: { (true) in
                self.serviceVehicleImage.frame = OriginalFrame
                self.serviceVehicleImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.2, animations: {
                    self.serviceVehicleImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { (true) in
                    self.serviceVehicleImage.transform = CGAffineTransform.identity
                }) 
            }) 
        })
        
    }
    
    func setUpUI() {
        tableService.estimatedRowHeight = 90;
        tableService.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func setUpperNavigationItems() {
        
        self.rightLogoEnabled = true
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.title = "SERVICE OPTION"
    }
    
    func validateForPhone(_ completion: @escaping (_ isSuccess:Bool)->()) {
        if PYLHelper.helper.userModelObj!.phone.isBlank {
            let alert = UIAlertController(title: title, message: BLANK_MOBILE_NO, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .phonePad
                textField.showToolBar()
                textField.delegate = self
            }
            alert.view.tintColor = DEFAULT_COLOR
            let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) { (action) in
                //do nothing..
                completion(false)
            }
            alert.addAction(cancelAction)
            let doneAction = UIAlertAction(title: OK, style: .default) { (action) in
                if self.phoneNo.length > 0{
                PYLAPIHandler.handler.editPhoneNo(PhoneNo: self.phoneNo, success: { (response) in
                    
                    switch (response?["ResponseCode"].stringValue)! {
                    case "200":
                        PYLHelper.helper.userModelObj?.phone = self.phoneNo
                        SET_USERDEFAULT_VALUE((PYLHelper.helper.userModelObj?.dictionaryValue())! as AnyObject, forKey: USER_DEFAULT_STORED_USER_KEY)
                        completion(true)
                    case CODE_SESSION_TOKEN_MISMATCH:
                        self.logOutForSessionTokenMismatch()
                    case CODE_INACTIVE_USER:
                        self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
                    default :
                        self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                    }
                    }, failure: { (errorMsg) in
                          completion(false)
                })
                }else{
                  self.view.showToastWithMessage(BLANK_MOBILE_NO)
                  self.validateForPhone(completion)
                }
              
            }
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            completion(true)
        }
    }
    
    func callBannerApi() {
        arrBanner.append(["image":"FoodDetailsBanner" as AnyObject,"title":"Wraps are very nice" as AnyObject,"price":"280/410" as AnyObject])
        arrBanner.append(["image":"FoodDetailsBanner" as AnyObject,"title":"Egg Rolls" as AnyObject,"price":"70/150" as AnyObject])
        arrBanner.append(["image":"FoodDetailsBanner" as AnyObject,"title":"Cutlet" as AnyObject,"price":"220/740" as AnyObject])
        arrBanner.append(["image":"FoodDetailsBanner" as AnyObject,"title":"Shawarma rolls, Chicken Rolls, Veg Rolls" as AnyObject,"price":"280/410" as AnyObject])
        collectionViewBanner.reloadData()
        pageControlBanner?.numberOfPages = arrBanner.count
        pageControlBanner?.currentPage = 0
        //timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(bannerMoveNext), userInfo: nil, repeats: true)
    }
    
    //    func bannerMoveNext() {
    //        pageControlBanner!.currentPage = (pageControlBanner!.currentPage == arrBanner.count-1) ? 0 : pageControlBanner!.currentPage + 1
    //        collectionViewBanner.selectItemAtIndexPath(NSIndexPath(forItem: pageControlBanner!.currentPage, inSection: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    //    } 
    
    // MARK: Api Section
    func callPlaceOrderApi(_ takeAwayOrDeliveryTime:String, completion:@escaping (_ orderDetails : JSON?)->())
    {
        PYLAPIHandler.handler.placeOrder({ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                PYLHelper.helper.placedOrderID = (response?["order_id"].stringValue.getAESDecryption())!
                if (response?["order_id"].stringValue.getAESDecryption().length)! > 0 {
                    SET_CART_BADGE("0")
                }
                let title = response?["Responsedetails"].stringValue
                if title != "success" {
                    self.view.showToastWithMessage((response?["Responsedetails"].stringValue)!)
                }
                completion(response)
            case CODE_SESSION_TOKEN_MISMATCH:
                self.logOutForSessionTokenMismatch()
            case CODE_INACTIVE_USER:
                self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
            default :
                //                self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                self.present(UIAlertController.showSimpleAlertWith(kAppTitle, alertText: response!["Responsedetails"].stringValue, selected_: { (index) in
                    
                }), animated: true, completion: nil)
            }
        }) { (error) in
            
        }
    }
    
    // MARK: - UITableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 100
            //let aspectRatio: CGFloat = UIScreen.mainScreen().bounds.size.height/3; // assuming images is ratio is 620/350 width/height
            //return aspectRatio // * UIScreen.mainScreen().bounds.size.width // assuming that the image will stretch across the width of the screen
            
        }
        //        else if(indexPath.row == 1){
        //            return 100
        //        }
        return UITableViewAutomaticDimension
    }
    
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
    
    //MARK: TextField Delegates
    //only used for Alert textfield for DineIn/TakeAway
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard !string.containsEmoji() else { return false }
        
        var strText = String()
        if (range.length == 0){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.insert(string, at: range.location)
            strText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.deleteCharacters(in: range)
            strText = stringNew as String
        }
        if !strText.isNumber { return false }
        if (strText.length > MAX_PHONE_NO_LIMIT) { return false }
        phoneNo = strText
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func dineInButtonActiom(_ sender: AnyObject?) {
        trackButtonTapEventsForAnalytics(actionName: SERVICE_OPT_DINE_IN_EVENT, tapsRequired: "1")
        selectedDeliveryOption = .DineIn
        PYLHelper.helper.selectedServiceType = selectedDeliveryOption
        buttonDineIn.isSelected = true
        buttonAway.isSelected = false
        buttonDelivery.isSelected = false
    }
    
    @IBAction func deliveryButtonAction(_ sender: AnyObject) {
        trackButtonTapEventsForAnalytics(actionName: SERVICE_OPT_DELIVERY_EVENT, tapsRequired: "1")
        selectedDeliveryOption = .Delivery
        PYLHelper.helper.selectedServiceType = selectedDeliveryOption
        buttonDineIn.isSelected = false
        buttonAway.isSelected = false
        buttonDelivery.isSelected = true
    }
    
    @IBAction func takeAwayButtonAction(_ sender: AnyObject) {
        trackButtonTapEventsForAnalytics(actionName: SERVICE_OPT_TAKE_AWAY_EVENT, tapsRequired: "1")
        selectedDeliveryOption = .TakeAway
        PYLHelper.helper.selectedServiceType = selectedDeliveryOption
        buttonDineIn.isSelected = false
        buttonAway.isSelected = true
        buttonDelivery.isSelected = false
    }
    
    @IBAction func chooseDeliveryPressed(_ sender: UIButton?) {
        sender?.isEnabled = false
        trackButtonTapEventsForAnalytics(actionName: CHOOSE_SERVICE_OPTION_EVENT, tapsRequired: "1")
        switch selectedDeliveryOption {
            
        case .DineIn:
            validateForPhone({ isSuccess in
                guard isSuccess else {
                    sender?.isEnabled = true
                    return
                }
                self.getCurrentLocationAndFindBranch(DINE_IN,enableButton: sender!)
            })
            //            getCurrentLocationAndFindBranch(DINE_IN,enableButton: sender!)
            
        case .TakeAway:
            validateForPhone({ isSuccess in
                guard isSuccess else {
                    sender?.isEnabled = true
                    return
                }
                self.getCurrentLocationAndFindBranch(TAKE_AWAY,enableButton: sender!)
            })
            //            getCurrentLocationAndFindBranch(TAKE_AWAY,enableButton: sender!)
            
        case .Delivery:
            PYLTakeAwayServicePopUpViewController.showTakeAwayPopUp(self, branchData:[["":"" as AnyObject]], type: .kDelivery, selected: {
                // Need to persist the delivery related info here // TODO
                sender?.isEnabled = true
                guard IS_USER_LOGIN() else {
                    /*
                     PYLHelper.helper.nextViewControllerIdentifier = String(PYLDeliveryAddressChooseViewController)
                     PYLHelper.helper.nextViewControllerStoryBoard = mainStoryboard
                     self.pushToViewController(mainStoryboard, viewController: String(PYLLoginViewController))
                     */
                    self.goToLoginScreen({ (success) in
                        self.pushToViewController(mainStoryboard, viewController: String(describing: PYLDeliveryAddressChooseViewController.self))
                    })
                    return
                }
                self.pushToViewController(mainStoryboard, viewController: String(describing: PYLDeliveryAddressChooseViewController.self))
                }, dissmiss: {
                    sender?.isEnabled = true
            })
            
        default:
            self.view.showToastWithMessage("Please select one service")
            break
        }
    }
    
    func getCurrentLocationAndFindBranch(_ serviceType: String,enableButton:UIButton) {
        
        PYLCurrentLocation.sharedInstance.fetchCurrentUserLocation(onSuccess: { (latitude, longitude) in
            
            debugPrint("\(latitude) and \(longitude)")
            //TODO
            PYLHelper.helper.latitude  = "\(latitude)" //"22.5988"
            PYLHelper.helper.longitude = "\(longitude)" //"88.4319"
            PYLAPIHandler.handler.getBranchesByServiceAndAddress(preferredServiceType: serviceType, userLatitude: PYLHelper.helper.latitude!, userLongitude: PYLHelper.helper.longitude!, address: ["":""], saveAddInUserDirectory: "0", success: { (response) in
                let branchDetails = response?.dictionaryObject!["branch_details"] as? [AnyObject]
                
                switch (response?["ResponseCode"].stringValue)! { // api 202 not sending - issue
                case "200":
                    // got crash
                    guard (branchDetails?.count)! > 0 else {
                        PYLNoNearByBranchPopUpViewController.showNoNearByBranchPopUp(self, dissmiss: {
                            enableButton.isEnabled = true})
                        return
                    }
                    let branchID = (((branchDetails![0] as! [String:AnyObject])["branch_id"] as? String)!.getAESDecryption())
                    PYLHelper.helper.placeOrderObj!.branchID = branchID
                    PYLHelper.helper.branchAsPerServiceType = branchDetails!
                    
                    if serviceType == DINE_IN {
                        //                         [order_type :dine_in, take_away, delivery]
                        if PYLHelper.helper.placeOrderObj != nil {
                            PYLHelper.helper.placeOrderObj!.orderType = "dine_in"
                        }
                        
                        //Address-stuffs for place-order (dine-in)
                        PYLHelper.helper.placeOrderObj!.addressID = ""
                        PYLHelper.helper.placeOrderObj!.addressLine1 = ""
                        PYLHelper.helper.placeOrderObj!.addressLine2 = ""
                        PYLHelper.helper.placeOrderObj!.addressLandmark = ""
                        PYLHelper.helper.placeOrderObj!.addressCity = ""
                        PYLHelper.helper.placeOrderObj!.addressPin = ""
                        PYLHelper.helper.placeOrderObj!.addressPhone = ""
                        PYLGotNearByBranchPopUpViewController.showGotNearByBranchPopUp(self,serviceType: .DineIn, selected: {
                            PYLNearbyBranchPopupViewController.showNearbyBranchController(self,orderType: .kDineIn, selected: {selectedBranch in
                                
                                enableButton.isEnabled = true
                                guard IS_USER_LOGIN() else {
                                    PYLHelper.helper.nextViewControllerIdentifier = String(describing: PYLPaymentViewController.self)
                                    PYLHelper.helper.nextViewControllerStoryBoard = utilityStoryboard
                                    self.goToLoginScreen({ (success) in
                                        //TODO: send a proper takeAwayOrDeliveryTime
                                        self.callPlaceOrderApi("", completion: { orderDetails in
                                            self.goToPaymentScreen(orderDetails)
                                        })
                                    })
                                    return
                                }
                                //TODO: send a proper takeAwayOrDeliveryTime
                                self.callPlaceOrderApi("", completion: { orderDetails in
                                    self.goToPaymentScreen(orderDetails)
                                })
                                }, dismiss: {
                                    enableButton.isEnabled = true
                            })
                            }, dissmiss: {
                                enableButton.isEnabled = true
                        })
                        
                    }
                    else if serviceType == DELIVERY {
                        //                         [order_type :dine_in, take_away, delivery]
                        if PYLHelper.helper.placeOrderObj != nil {
                            PYLHelper.helper.placeOrderObj!.orderType = "delivery"
                        }
                        PYLTakeAwayServicePopUpViewController.showTakeAwayPopUp(self, branchData: branchDetails as! [[String:AnyObject]], type: .kDelivery, selected: {
                            // Need to persist the delivery related info here // TODO
                            enableButton.isEnabled = true
                            guard IS_USER_LOGIN() else {
                                /*
                                 PYLHelper.helper.nextViewControllerIdentifier = String(PYLDeliveryAddressChooseViewController)
                                 PYLHelper.helper.nextViewControllerStoryBoard = mainStoryboard
                                 self.pushToViewController(mainStoryboard, viewController: String(PYLLoginViewController))
                                 */
                                self.goToLoginScreen({ (success) in
                                    
                                    self.pushToViewController(mainStoryboard, viewController: String(describing: PYLDeliveryAddressChooseViewController.self))
                                })
                                return
                            }
                            self.pushToViewController(mainStoryboard, viewController: String(describing: PYLDeliveryAddressChooseViewController.self))
                            }, dissmiss: {
                                enableButton.isEnabled = true
                        })
                    }
                    else {
                        //                         [order_type :dine_in, take_away, delivery]
                        if PYLHelper.helper.placeOrderObj != nil {
                            PYLHelper.helper.placeOrderObj!.orderType = "take_away"
                        }
                        
                        //Address-stuffs for place-order (take-away)
                        PYLHelper.helper.placeOrderObj!.addressID = ""
                        PYLHelper.helper.placeOrderObj!.addressLine1 = ""
                        PYLHelper.helper.placeOrderObj!.addressLine2 = ""
                        PYLHelper.helper.placeOrderObj!.addressLandmark = ""
                        PYLHelper.helper.placeOrderObj!.addressCity = ""
                        PYLHelper.helper.placeOrderObj!.addressPin = ""
                        PYLHelper.helper.placeOrderObj!.addressPhone = ""
                        
                        //it's take away, show the branch list now
                        PYLGotNearByBranchPopUpViewController.showGotNearByBranchPopUp(self,serviceType: .TakeAway, selected: {
                            PYLNearbyBranchPopupViewController.showNearbyBranchController(self,orderType: .kTakeAway, selected: {selectedBranch in
                                
                                enableButton.isEnabled = true
                                PYLTakeAwayServicePopUpViewController.showTakeAwayPopUp(self, branchData: [selectedBranch] , type: .kTakeAway, selected: {
                                    
                                    guard IS_USER_LOGIN() else {
                                        /*
                                         PYLHelper.helper.nextViewControllerIdentifier = String(PYLPaymentViewController)
                                         PYLHelper.helper.nextViewControllerStoryBoard = utilityStoryboard
                                         self.pushToViewController(mainStoryboard, viewController: String(PYLLoginViewController))
                                         */
                                        self.goToLoginScreen({ (success) in
                                            //TODO: send a proper takeAwayOrDeliveryTime
                                            self.callPlaceOrderApi("", completion: { orderDetails in
                                                self.goToPaymentScreen(orderDetails)
                                            })
                                        })
                                        
                                        return
                                    }
                                    //TODO: send a proper takeAwayOrDeliveryTime
                                    self.callPlaceOrderApi("", completion: {orderDetails in
                                        self.goToPaymentScreen(orderDetails)
                                    })
                                    }, dissmiss: {
                                        enableButton.isEnabled = true
                                })
                                
                                }, dismiss: {
                                    enableButton.isEnabled = true
                                    
                            })
                            }, dissmiss: {
                                enableButton.isEnabled = true
                        })
                    }
                    debugPrint(response!["Responsedetails"].stringValue)
                    
                case CODE_SESSION_TOKEN_MISMATCH:
                    self.logOutForSessionTokenMismatch()
                case CODE_INACTIVE_USER:
                    self.inactiveUserAction(withMessage: response!["Responsedetails"].stringValue)
                    
                default:
                    debugPrint("\(response)")
                    break
                }
                },offlineBlock: {
                    enableButton.isEnabled = true
                   
                }, failure: { (error) in
                    // API calling failed // what todo?
                    enableButton.isEnabled = true
                    self.view.showToastWithMessage("something went wrong, please check your internet connectivity and try again") // temp message
                    debugPrint(error ?? "")
            })
            
        }) { (message) in // location fetching failed
            
            // check if location is turned off from settings and push the user to Native Settings Option
            guard message == LOCATION_DISABLED else {
                // location fetching failed - For any other reason. move the user to enter location manually screen or stay in this screen
                self.view.showToastWithMessage("Something went wrong")
                return
            }
            
            // location fetching failed - because user turned off the location service. move the user to settings screen or enter location manually screen
            self.present(UIAlertController.showStandardAlertWith(ALERT_TITLE_TURN_ON_LOCATION,
                alertText:      ALERT_MESSAGE_TURN_ON_LOCATION,
                cancelTitle:    ALERT_TITLE_SETTINGS,
                doneTitle:      CANCEL,
                selected_:      { (index) in
                    
                    if index == 0 {
                        let urlSCHEMES = (URL(string:"prefs:root=LOCATION_SERVICES")!)
                        if UIApplication.shared.canOpenURL(urlSCHEMES) {
                            // navigate to iPhone location Settings
                            UIApplication.shared.openURL(URL(string:"prefs:root=LOCATION_SERVICES")!)
                        } else {
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        }
                    }
                    
            }), animated: true, completion: nil)
            
            debugPrint("location error - \(message)")
        }
    }
    
    func goToPaymentScreen(_ OrderDetails : JSON!)  {
        
        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLPaymentViewController.self)) as? PYLPaymentViewController
        viewController?.orderDetails = OrderDetails
        viewController?.isDeliveryType = false
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController!, animated: true)
    }
}

//func callBranchApiWithServiceType() {
//    
//    PYLAPIHandler.handler.getBranchDetailsListWithCountry(countryId: PYLHelper.helper.userCountryID!, takeAwayServiceAvilability: "false",deliveryServiceAvilability: "true", success: { (response) in
//        switch (response["ResponseCode"]) {
//        case "200":
//            successTaskBranchListWithCountryApi(response)
//        default:
//            break
//            //view.showToastWithMessage(response!["Responsedetails"].stringValue)
//        }
//        }, failure: { (error) in
//            
//    })
//}

func successTaskBranchListWithCountryApi(_ response: JSON) {
    
    _ =  response.dictionaryObject!
}

//func getNearByBranchList(success:(branchAvailable: Bool! , branchs: NSArray!)->()) {
//    
//    let longitude = PYLHelper.helper.longitude ?? ""
//    let latitude =  PYLHelper.helper.latitude ?? ""
//    if (longitude.isEmpty || latitude.isEmpty) {
//        UIApplication.sharedApplication().windows.first?.rootViewController?.view.showToastWithMessage(LOCATION_FETCH_FAILED)
//    }else{
//        PYLAPIHandler.handler.getBranchesAvailability(userLatitude: latitude, userLongitude:longitude , success: { (response) in
//            let isAvailable = response["isAvailable"].stringValue.getAESDecryption()
//            success(branchAvailable: isAvailable.toBool(),branchs: nil)
//        }) { (error) in
//        }
//    }
//}

extension PYLServiceViewController: UICollectionViewDelegate {
    
    //    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    //        
    //        guard scrollView == collectionViewBanner else { return }
    //        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    //        pageControlBanner!.currentPage = Int(pageNumber)
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return collectionViewBanner(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    // MARK: - Banner
    func collectionViewBanner(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewBanner.bounds.width,height: collectionViewBanner.bounds.height)
    }
}

extension PYLServiceViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionViewBanner(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionViewBanner(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // MARK: Banner
    func collectionViewBanner(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  1//arrBanner.count
    }
    
    func collectionViewBanner(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PYLBannerCollectionCell.self), for: indexPath) as! PYLBannerCollectionCell
        //cell.datasource = arrBanner[indexPath.row]
        return cell
    }
}
