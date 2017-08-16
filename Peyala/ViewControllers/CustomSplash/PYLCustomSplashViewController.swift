//
//  PYLCustomSplashViewController.swift
//  Peyala
//
//  Created by Soumen Das on 08/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import Alamofire

class PYLCustomSplashViewController: UIViewController {
    
    //MARK: - Outlet Connection
    @IBOutlet weak var customSplashImageView: UIImageView!
    
    //MARK: - Varriable Declaration
    let network = NetworkReachabilityManager()
    var isNetConnectionLostFirstTime = true
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //For iPhone 4S image is getting streched that's why image has been placed by code
        if UIScreen.main.nativeBounds.height <= 960 {
            customSplashImageView.image = UIImage(named: "customSplash4S")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Defined Function
    func initializeViewController() {
        
        if ((network?.isReachable) == true) {
            isNetConnectionLostFirstTime = false
            self.callInitialAPIs()
            let frontViewController = utilityStoryboard.instantiateViewController(withIdentifier: (String(describing: PYLLocationViewController.self))) as! PYLLocationViewController
            self.setUpRootViewController(frontViewController)
        }
        else {
            if !IS_USER_LOGIN() {
                isNetConnectionLostFirstTime = true
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(callInitialAPIs),
                    name: NSNotification.Name(rawValue: NETWORK_REACHABILITY),
                    object: nil)
                
                self.present(UIAlertController.showSimpleAlertWith("Connection Failed", alertText: CONNECTION_STATUS, selected_: { (index) in
                    
                }), animated: true, completion: nil)
            }
            else {
                
                // here we need to persist previous data like country/lat-long/search keyword etc
                let frontViewController = servicesStoryboard.instantiateViewController(withIdentifier: (String(describing: PYLDashBoardViewController.self))) as! PYLDashBoardViewController
                self.setUpRootViewController(frontViewController)
            }
        }
    }
    
    func setUpRootViewController(_ frontViewController: UIViewController!) {
        
        let mainViewController = servicesStoryboard.instantiateViewController(withIdentifier: "DashboardNavigationController") as! UINavigationController
        let leftViewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLMenuViewController.self)) as! PYLMenuViewController
        
        mainViewController.viewControllers = [frontViewController]
        
        let slideMenuController = PYLSlideMenuController(mainViewController:mainViewController, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = leftViewController
        
        PYLNavigationHelper.helper.navigationController = mainViewController
        UIApplication.shared.windows.first!.rootViewController = slideMenuController
        UIApplication.shared.windows.first!.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
    }
    
    func callInitialAPIs() {
        //Search keyword API
        self.callDefaultSearchAPI{
        }
        //Fetch Country List
        self.callCountryListApi{
        }
        //Get current location
        getCurrentLocation{
        }
        if isNetConnectionLostFirstTime {
            initializeViewController()
        }
    }
    
    //MARK: - API Section
    //Get Country List
    func callCountryListApi(_ success:@escaping ()->()) {
        
        PYLAPIHandler.handler.getCountryList({ (response) in
            
            self.offlineOrSuccessResponseHandleCountryListApi(response!, success: success)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleCountryListApi(response!, success: success)
        }) { (error) in
            debugPrint("\(error)")
        }
    }
    
    //Get Searck Key list
    func callDefaultSearchAPI(_ success:@escaping ()->()) {
        
        PYLAPIHandler.handler.defaultSearchList({ (response) in
            let responseDict =  response?.dictionaryObject!
            if  let searchKeyArray = responseDict?["search_key_list"] as? [AnyObject] {
                debugPrint(searchKeyArray)
                PYLHelper.helper.searchKeyArray = searchKeyArray as! [String]
            }
            success()
        }) { (error) in
            
        }
    }
    
    //Register device for push
    func callRegisterDeviceAPI() {
        
        guard GET_DEVICE_TOKEN().isBlank else { return }
        
        PYLAPIHandler.handler.registerDevice({ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                SET_DEVICE_TOKEN(PYLHelper.helper.deviceID!)
                break
            case "206":
                //Device already registered
                SET_DEVICE_TOKEN(PYLHelper.helper.deviceID!)
                break
            default :
                break
            }
        }) { (error) in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.callRegisterDeviceAPI()
            }
        }
    }
    
    func offlineOrSuccessResponseHandleCountryListApi(_ response: JSON, success:()->()) {
        
        if let getArray = response["country_list"].arrayObject {
            
            if getArray.count > 0 {
                
                PYLHelper.helper.countryArrayDetails = getArray as [AnyObject]
                for (index, _) in getArray.enumerated() {
                    PYLHelper.helper.countryNameArray.append((((getArray[index] as! [String:String])["country_name"]!)).getAESDecryption())
                }
            }
        }
        success()
    }
}
