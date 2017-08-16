//
//  PYLLocationViewController.swift
//  Peyala
//
//  Created by Soumen Das on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import CoreLocation

class PYLLocationViewController: PYLBaseViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        presentWithAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - User Defined Function
    
    func presentWithAnimation() {
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Float(M_PI * 2.0 * 2 * 0.5) as Float) //[NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
        rotationAnimation.duration = 0.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 1000
        
        self.locationImage.layer.add(rotationAnimation, forKey:"rotationAnimation")
        
        var frame1 = label1.frame
        let OriginalFrame1 = frame1
        frame1.origin.x = 0
        frame1.origin.x = -frame1.size.width
        label1.frame = frame1
        
        var frame2 = label2.frame
        let OriginalFrame2 = frame2
        frame2.origin.x = self.view.bounds.size.width
        label2.frame = frame2
        
      
            /*
            UIView.animateWithDuration(0.5, animations: {
                
                self.label1.frame = OriginalFrame1
                self.label2.frame = OriginalFrame2
                
            }) { (true) in
                self.locationImage.layer.removeAnimationForKey("rotationAnimation")
            }
            */
            UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options:UIViewAnimationOptions.curveEaseIn, animations: {
                self.label1.frame = OriginalFrame1
                self.label2.frame = OriginalFrame2
                }, completion: { (true) in
                 self.locationImage.layer.removeAnimation(forKey: "rotationAnimation")
            })
   
    }
    
    func getCountryImage(_ image:UIImage!, imageName:String!) {
        
        // Define the specific path, image name
        let myImageName = imageName //"countryName"
        let imagePath = fileInDocumentsDirectory(myImageName!)
        
        if image != nil {
            saveImage(image, path: imagePath)
        } else { print("some error message") }
        
        if let loadedImage = loadImageFromPath(imagePath) {
            print(" Loaded Image: \(loadedImage)")
        } else { print("some error message 2") }
    }
    
    func setUpperNavigationItems() {
        
        self.menuButtonEnabled = false //TODO //it should be false here //testing purpose
        self.rightLogoEnabled = false
        self.title = "CURRENT LOCATION"
      
    }
    
    func isDuplicateFile(_ fileName: String!, success:()->()) {
        
        //let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        //let url = NSURL(fileURLWithPath: path)
        //instead of above two line below line of code is sufficient
        let fileURL = getDocumentsURL().appendingPathComponent(fileName)
        let filePath = fileURL.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
        }
    }
    
    func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    func saveImage (_ image: UIImage, path: String ) {
        
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        _ = (try? pngImageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
    }
    
    func loadImageFromPath(_ path: String) -> UIImage? {
        
        let image = UIImage(contentsOfFile: path)
        
        if image == nil {
            
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
    }
    
    //MARK: - Button Action
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        
        sender.isEnabled = false
        PYLSpinner.show()
        PYLCurrentLocation.sharedInstance.fetchCurrentUserLocation(onSuccess: { (latitude, longitude) in
            PYLSpinner.hide()
            debugPrint("\(latitude) and \(longitude)")
            PYLHelper.helper.latitude = "\(latitude)" //"22.5685934725169 and 88.4317852081094"
            PYLHelper.helper.longitude = "\(longitude)"
            
            guard PYLHelper.helper.isNetworkOn else {
                self.view.showToastWithMessage(NO_NETWORK)
                sender.isEnabled = true
                return
            }
            PYLAPIHandler.handler.getBranchesAvailability(userLatitude: "\(latitude)", userLongitude: "\(longitude)", success: { (response) in
                
                switch (response?["ResponseCode"].stringValue)! {
                case "200":
                    let avalability = response?["isAvailable"].stringValue.getAESDecryption()
                    if avalability?.toBool() == true {
                        
                        PYLHelper.helper.userCountryID = response?["country_id"].stringValue.getAESDecryption()
                        PYLHelper.helper.selectedCountryFlagURL = (response?["country_flag_img_url"].stringValue.getAESDecryption())!
                        //self.pushToViewController(servicesStoryboard, viewController: String(PYLDashBoardViewController))
                        
                        // imageeeeeeeee downloaddd
                        PYLSpinner.show()
                        if let url = NSURL(string: PYLHelper.helper.selectedCountryFlagURL) {
                            let request = NSURLRequest(url: url as URL)
                            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main, completionHandler: { (response: URLResponse?, data: Data?, error: Error?) in
                                //got crash
                                PYLSpinner.hide()
                                guard data != nil else { return }
                                
                                if (data?.count)! > 0 {
                                    PYLHelper.helper.selectedCountryFlagImage = UIImage(data: data!)!
                                }
                                self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLDashBoardViewController.self))
                            })
                        }
                        
                        /*
                         let testImage = UIImageView()
                         testImage.af_setImageWithURL(
                         NSURL(string: PYLHelper.helper.selectedCountryFlagURL)!,
                         placeholderImage: nil,
                         filter: nil,
                         imageTransition: .CrossDissolve(0.5),
                         completion: { response in
                         debugPrint(response.result.value)
                         debugPrint(response.result.error)
                         if response.result.isSuccess {
                         
                         //self.getCountryImage(response.result.value!, imageName: countryName)
                         
                         //self.pushToViewController(servicesStoryboard, viewController: String(PYLDashBoardViewController))
                         }
                         }
                         )
                         self.pushToViewController(servicesStoryboard, viewController: String(PYLDashBoardViewController))
                         */
                        
                    } else {
                        sender.isEnabled = false
                        sender.backgroundColor = UIColorRGB(182, g: 182, b: 182)
                        PYLNoNearByBranchPopUpViewController.showNoNearByBranchPopUp(self, dissmiss: {
                            
                        })
                        return
                    }
                    sender.isEnabled = true
                    if response!["Responsedetails"].stringValue != "success" {
                        self.view.showToastWithMessage(response!["Responsedetails"].stringValue)
                    }
                    
                default:
                    debugPrint("\(response)")
                    sender.isEnabled = true
                    break
                }
                }, failure: { (error) in
                    // API calling failed // what todo?
                    sender.isEnabled = true
                    //                    self.view.showToastWithMessage("something went wrong, please check you internet connectivity and try again") // temp message ////ch - adarsh , commented as failure message is already shown by ApiManager.
                    debugPrint(error ?? "")
            })
            
            //Tax tasks
            self.callTaxApi()
        }) { (message) in // location fetching failed
            PYLSpinner.hide()
            sender.isEnabled = true
            // check if location is turned off from settings and push the user to Native Settings Option
            
            if message == LOCATION_DISABLED {
                
                // location fetching failed - because user turned off the location service. move the user to settings screen or enter location manually screen
                self.present(UIAlertController.showStandardAlertWith(ALERT_TITLE_TURN_ON_LOCATION, alertText: ALERT_MESSAGE_TURN_ON_LOCATION, cancelTitle: ALERT_TITLE_SETTINGS, doneTitle: CANCEL, selected_: { (index) in
                    
                    if index == 0 {
                        
                        let urlSCHEMES = (URL(string:"prefs:root=LOCATION_SERVICES")!)
                        if UIApplication.shared.canOpenURL(urlSCHEMES) {
                            // navigate to iPhone location Settings
                            UIApplication.shared.openURL(URL(string:"prefs:root=LOCATION_SERVICES")!)
                        } else {
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        }
                    } else {
                        // stay on this page
                    }
                    
                }), animated: true, completion: nil)
                
            } else {
                
                // location fetching failed - For any other reason. move the user to enter location manually screen or stay in this screen
                self.present(UIAlertController.showStandardAlertWith(LOCATION_FETCH_FAILED, alertText: ALERT_MESSAGE_ENTER_MANUALLY, cancelTitle: CANCEL, doneTitle: ALERT_TITLE_ENTER_MANUALLY, selected_: { (index) in
                    
                    if index == 0 {
                        // cancel actiom
                    } else {
                        guard PYLHelper.helper.isNetworkOn else {
                            self.view.showToastWithMessage(NO_NETWORK)
                            return
                        }
                        self.pushToViewController(servicesStoryboard, viewController: (String(describing: PYLAddLocationManuallyViewController.self)))
                    }
                    
                }), animated: true, completion: nil)
            }
            
            debugPrint("location error - \(message)")
            //self.pushToViewController(servicesStoryboard, viewController: (String(PYLAddLocationManuallyViewController)))
        }
    }
    
    @IBAction func getLocationManually(_ sender: UIButton) {
        guard PYLHelper.helper.isNetworkOn else {
            self.view.showToastWithMessage(NO_NETWORK)
            return
        }
        self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLAddLocationManuallyViewController.self))
    }
    
    //MARK: - Api section
    func callTaxApi()
    {
        PYLAPIHandler.handler.getTax(userLatitude: PYLHelper.helper.latitude!, userLongitude: PYLHelper.helper.longitude!, success:{ (response) in
            switch (response?["ResponseCode"].stringValue)! {
            case "200":
                self.successTasksGetTaxApi(response!)
            default :
                break
            }
        }) { (error) in
            
        }
    }
    
    func successTasksGetTaxApi(_ response: JSON) {
        //        {
        //            "tax_details" : [
        //            {
        //            "tax_name" : "hw8akfb15LvGQIY1eZJbgw==",
        //            "tax_percentage" : "KDjeKtaPsHkM14qyQ3m\/tQ=="
        //        },
        //        {
        //            "tax_name" : "PN0qceSq4pjIQogw9TD6fg==",
        //            "tax_percentage" : "a\/33viCjRrNpylX1jXZ5NQ=="
        //        }
        //        ],
        //        "ResponseCode" : "200",
        //        "Responsedetails" : "success"
        
        PYLHelper.helper.arrTax = [ModelTax]()
        for dict in response["tax_details"].arrayObject! {
            let dictTax = dict as! [String:String]
            let taxObj = ModelTax()
            taxObj.taxName = String.getSafeString(dictTax["tax_name"] as AnyObject?).getAESDecryption()
            taxObj.taxPercentage = String.getSafeString(dictTax["tax_percentage"] as AnyObject?).getAESDecryption()
            PYLHelper.helper.arrTax.append(taxObj)
        }
    }
}
