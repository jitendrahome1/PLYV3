//
//  PYLGlobals.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import AlamofireImage

let ENCRYPTION_KEY = "1234567890"
let API_KEY = "1234567890"
//let USER_DEFAULT_USER_LOGIN_KEY = "pyl_user_login"
let USER_DEFAULT_USER_LOCATION_KEY = "pyl_user_location"
let USER_DEFAULT_STORED_USER_KEY = "pyl_stored_user"
let USER_DEFAULT_SESSION_ID_KEY = "pyl_session_id"
let USER_DEFAULT_NOTIFICATION_STATUS_KEY = "pyl_notification_status_id"
let BADGE_NOTIFICATION = "pyl_badge_notification"
let BADGE_CART         = "pyl_badge_cart"
let NETWORK_REACHABILITY         = "pyl_network_reachability"
let NOTIFICATION_BADGE_UPDATE         = "pyl_update_notification_badge"
let DEVICE_TOKEN         = "pyl_device_token"
let APP_RUN_COUNT         = "pyl_app_run_count"


class PYLGlobals: NSObject {
    var NotificationBannerTapped:Bool
    static let globals = PYLGlobals()
    fileprivate override init() {
        NotificationBannerTapped  = false
    }
}

let photoCache = AutoPurgingImageCache(
    memoryCapacity: 500 * 1024 * 1024,
    preferredMemoryUsageAfterPurge: 200 * 1024 * 1024
)
//MARK: = Image Caching

func cacheImage(_ image: Image, urlString: String) {
    photoCache.add(image, withIdentifier: urlString)
}

func cachedImage(_ urlString: String) -> Image? {
    return photoCache.image(withIdentifier:urlString)
}


func GET_USERDEFAULT_VALUE(_ key: String) -> AnyObject?{
    guard UserDefaults.standard.value(forKey: key) != nil else{
        return nil
    }
    return UserDefaults.standard.value(forKey: key) as AnyObject?
}

func REMOVE_USERDEFAULT_VALUE(_ key: String) {
    UserDefaults.standard.removeObject(forKey: key)
    UserDefaults.standard.synchronize()
}

func SET_USERDEFAULT_VALUE(_ value:AnyObject,forKey key: String) {
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}
func SET_APP_RUN_COUNT(_ count:Int) {
    UserDefaults.standard.set("\(count)", forKey: APP_RUN_COUNT)
    UserDefaults.standard.synchronize()
}
func SET_NOTIFICATION_BADGE(_ badgecount:String) {
    UserDefaults.standard.set(badgecount, forKey: BADGE_NOTIFICATION)
    UserDefaults.standard.synchronize()
}
func SET_DEVICE_TOKEN(_ tokenString:String) {
    UserDefaults.standard.set(tokenString, forKey: DEVICE_TOKEN)
    UserDefaults.standard.synchronize()
}
func SET_CART_BADGE(_ badgecount:String) {
    UserDefaults.standard.set(badgecount, forKey: BADGE_CART)
    UserDefaults.standard.synchronize()
}

func SET_NOTIFICATION_STATUS(_ status:String) {
    UserDefaults.standard.set(status, forKey: USER_DEFAULT_NOTIFICATION_STATUS_KEY)
    UserDefaults.standard.synchronize()
}



func GET_NOTIFICATION_BADGE()-> NSString {
    guard UserDefaults.standard.value(forKey: BADGE_NOTIFICATION) != nil else{
        return "0"
    }
    let badge = UserDefaults.standard.value(forKey: BADGE_NOTIFICATION) as! String
//    return (Int)(badge) > 99 ? "99+" : "\(badge)"
    return "\(badge)" as NSString
}

func GET_CART_BADGE()-> NSString {
    guard UserDefaults.standard.value(forKey: BADGE_CART) != nil else{
        return "0"
    }
    let badge = UserDefaults.standard.value(forKey: BADGE_CART) as! String
    //return (Int)(badge) > 99 ? "99+" : "\(badge)"
    return "\(badge)" as NSString
}
func GET_NOTIFICATION_STATUS()-> NSString {
    guard UserDefaults.standard.value(forKey: USER_DEFAULT_NOTIFICATION_STATUS_KEY) != nil else{
        return ""
    }
    let status = UserDefaults.standard.value(forKey: USER_DEFAULT_NOTIFICATION_STATUS_KEY) as! String
    return status as NSString
}
func GET_DEVICE_TOKEN()-> String {
    guard UserDefaults.standard.value(forKey: DEVICE_TOKEN) != nil else{
        return ""
    }
    let status = UserDefaults.standard.value(forKey: DEVICE_TOKEN) as! String
    return status
}
func GET_APP_RUN_COUNT()-> String {
    guard UserDefaults.standard.value(forKey: APP_RUN_COUNT) != nil else{
        return ""
    }
    let status = UserDefaults.standard.value(forKey: APP_RUN_COUNT) as! String
    return status
}

func IS_USER_LOGIN() -> Bool{
    //    guard NSUserDefaults.standardUserDefaults().valueForKey(USER_DEFAULT_USER_LOGIN_KEY) != nil else{
    //        return false
    //    }
    //    return NSUserDefaults.standardUserDefaults().valueForKey(USER_DEFAULT_USER_LOGIN_KEY) as! String == "0" ? false : true
    
    guard UserDefaults.standard.value(forKey: USER_DEFAULT_STORED_USER_KEY) != nil else{
        return false
    }
    return true
}

func SAVE_USERLOC(_ latitude: String,longitude: String) {
    SET_USERDEFAULT_VALUE(["latitude":latitude,"longitude":longitude] as AnyObject, forKey: USER_DEFAULT_USER_LOCATION_KEY)
}

func GET_USERLOC() -> (latitude: String,longitude: String, didGet: Bool){
    guard UserDefaults.standard.value(forKey: USER_DEFAULT_USER_LOCATION_KEY) != nil else{
        return (latitude:"",longitude:"",didGet:false)
    }
    let dict = UserDefaults.standard.value(forKey: USER_DEFAULT_USER_LOCATION_KEY) as! Dictionary<String,String>
    return (latitude:dict["latitude"]!,longitude:dict["longitude"]!,didGet:true)
}

func contentTypeForImageData(_ data:Data) -> String {
    
    var c = [UInt8](repeating: 0, count: 1)
    (data as NSData).getBytes(&c, length: 1)
    
    switch (c[0]) {
    case 0xFF:
        return "image.jpeg"
    case 0x89:
        return "image.png"
    case 0x47:
        return "image.gif"
    case 0x49: break
    case 0x4D:
        return "image.tiff"
    default: break
    }
    return ""
}

func systemVersion() -> Float {
    return (UIDevice.current.systemVersion as NSString).floatValue
}

// Get Current Location
func getCurrentLocation(_ completion:@escaping ()->()) {
    
    PYLCurrentLocation.sharedInstance.fetchCurrentUserLocation(onSuccess: { (latitude, longitude) in
        debugPrint("\(latitude) and \(longitude)")
        PYLHelper.helper.latitude = String(latitude)
        PYLHelper.helper.longitude = String(longitude)
        completion()
    }) { (message) in // location fetching failed
        debugPrint("location error - \(message)")
    }
}

//Resizing the image
func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func showNoNetworkView() {
    removeNoNetworkView()
    let noNetworkView = getViewFromNib("PYLMyOrderHeader", tag: 404, owner: nil)
//    noNetworkView.frame = CGRectMake(0, -40, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 40)
    let heightNavAndStatus = PYLNavigationHelper.helper.navigationController.navigationBar.frame.size.height + 20
    noNetworkView.frame = CGRect(x: 0, y: heightNavAndStatus, width: UIApplication.shared.keyWindow!.frame.width, height: 40)
    UIApplication.shared.keyWindow!.addSubview(noNetworkView)
    UIApplication.shared.keyWindow!.bringSubview(toFront: noNetworkView)
    noNetworkView.alpha = 0.0
    
    UIView.transition(with: noNetworkView, duration: 0.3, options: .transitionFlipFromTop, animations: {
        noNetworkView.alpha = 1.0
//        let heightNavAndStatus = PYLNavigationHelper.helper.navigationController.navigationBar.frame.size.height + 20
//        noNetworkView.frame = CGRectMake(0, heightNavAndStatus, CGRectGetWidth(UIApplication.sharedApplication().keyWindow!.frame), 40)
    }) { (true) in
    }
}

func animateNoNetworkViewIfPresent() {
    var viewNoNetwork: UIView?
    for _views in UIApplication.shared.keyWindow!.subviews as [UIView] {
        if _views.tag == 404 {
            viewNoNetwork = _views
            break
        }
    }
    guard (viewNoNetwork != nil) && !viewNoNetwork!.isHidden else { return }
    viewNoNetwork!.alpha = 0.0;
    viewNoNetwork!.blinkAnimate(forTimes: 2)
}


func removeNoNetworkView() {
    for _views in UIApplication.shared.keyWindow!.subviews as [UIView] {
        if _views.tag == 404 {
            _views.isHidden = true
            _views.removeFromSuperview()
            break
        }
    }
}

//Get view from Xib
func getViewFromNib(_ NibNamed:String , tag : NSInteger ,owner:UIViewController? = nil) -> UIView{
    var vw : UIView!
    let ArrayView =  Bundle.main.loadNibNamed(NibNamed, owner: owner, options: nil) as! [UIView]
    for desiredView in ArrayView {
        if desiredView.tag == tag {
            vw = desiredView
        }
    }
    return vw
}

//Analytics:  screen-wise, google and FB.
func trackScreenForAnalyticsWithName(_ screenName: String, isGoogle: Bool, isFB: Bool) {
    if isGoogle {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        
        let builder : GAIDictionaryBuilder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    if isFB {
        FBSDKAppEvents.logEvent(screenName)
    }
}

//Analytics:  Purchases, google and FB.
func trackPurchaseForAnalytics(_ orderID: String, transactionID: String, strPrice: String) {
    
    //Google stuffs
    let product = GAIEcommerceProduct()
    product.setId(orderID)
    product.setPrice(NSNumber(value: Double(strPrice)!))
    
    let productAction = GAIEcommerceProductAction()
    productAction.setAction(kGAIPAPurchase)
    productAction.setTransactionId(transactionID)
    
    let builder : GAIDictionaryBuilder  = GAIDictionaryBuilder.createEvent(withCategory: "Revenue", action: "Purchase", label: nil, value: nil)
    // Add the transaction data to the event.
    builder.setProductAction(productAction)
    builder.add(product)
    // Send the transaction data with the event.
    let tracker = GAI.sharedInstance().defaultTracker
    tracker?.send(builder.build()  as [NSObject: AnyObject])
    
    //FB stuffs
    FBSDKAppEvents.logPurchase(Double(strPrice)!, currency: "Taka", parameters: [FBSDKAppEventParameterNameContentID:orderID])
}

//Analytics:  Events, google and FB.
func trackEventsForAnalytics(_ categoryName: String, actionName: String, labelName: String, valueStr: String?, isGoogle: Bool, isFB: Bool) {
    
    //Google stuffs
    if isGoogle {
        var valueTemp:NSNumber?
        if valueStr != nil {
            valueTemp = NSNumber(value: Int(valueStr!.toDoubleWithRoundOfUpToTwoDecimal()!) as Int)
        }
        let builder = GAIDictionaryBuilder.createEvent(withCategory: categoryName, action: actionName, label: labelName, value: valueTemp).build() as [NSObject : AnyObject]
        
        // Send the transaction data with the event.
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(builder)
    }
    
    if isFB {
        //FB stuffs
        let strTempValue = valueStr != nil ? "_\(valueStr!)" : ""
        FBSDKAppEvents.logEvent("\(categoryName)_\(actionName)_\(labelName)\(strTempValue)")
    }
}

//track specifically button tap events.
func trackButtonTapEventsForAnalytics(actionName: String, tapsRequired: String) {
    trackEventsForAnalytics("ButtonTap", actionName: actionName, labelName: "TapsRequired", valueStr: tapsRequired, isGoogle: true, isFB: true)
}

//Analytics:  AddedToCart, google and FB.
func trackAddedToCartForAnalytics(foodID: String,price: Double) {
    
    //Google stuffs
    trackEventsForAnalytics("Food", actionName: "AddedToCart", labelName: foodID, valueStr: "\(price)", isGoogle: true, isFB: false)
    
    //FB stuffs
    FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart, valueToSum: price, parameters: [FBSDKAppEventParameterNameCurrency:"Taka", FBSDKAppEventParameterNameContentType:"Food", FBSDKAppEventParameterNameContentID:foodID])
}

//Analytics:  search, google and FB.
func trackSearchForAnalyticsWithName(_ searchString: String, isSearchSuccess: Bool, isGoogle: Bool, isFB: Bool) {
    if isGoogle {
        let strSearchSuccess = isSearchSuccess ? "1" : "0"
        trackEventsForAnalytics("Food", actionName: "Search", labelName: searchString, valueStr: strSearchSuccess, isGoogle: true, isFB: false)
    }
    
    if isFB {
        let strSearchSuccess = isSearchSuccess ? FBSDKAppEventParameterValueYes : FBSDKAppEventParameterValueNo
        FBSDKAppEvents.logEvent(FBSDKAppEventNameSearched, parameters: [FBSDKAppEventParameterNameContentType:"Food",FBSDKAppEventParameterNameSearchString:searchString,FBSDKAppEventParameterNameSuccess:strSearchSuccess])
    }
}

