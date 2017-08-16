//
//  PYLConstants.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

//MARK: API Endpoints

let DEVICE_TOKEN_REGISTER = "/service_auth/push_notifications"
let EXISTS = "login_auth/hybridauth/exists"
let REGISTER_API = "/api/userregistration"
let SOCIAL_LOGIN = "/api/social-login"
let LOGIN = "/api/userLogin"
let IS_LOGIN = "/api/is-user-login"
let LOGOUT = "/api/logout"
let FORGOT_PASSWORD = "/api/forget-password"
let EDIT_PROFILE = "/api/edit-profile-without-image"
let EDIT_PHONE_NO = "/api/edit-profile-phoneNo"
let EDIT_PROFILE_IMAGE = "/api/edit-profile-with-image"
let COUNTRY_LIST = "/api/get-country-details"
let FAQ_LIST = "/api/get-faq"
let NOTIFICATION_LIST = "/api/notification-list"
let NOTIFICATION_SETTINGS = "/api/notification-settings"
let REGISTER_DEVICE = "/api/add-register-device"
let ABOUT_US = "/api/about-us"
let CONTACT_US = "/api/contact-us"

//MARK:- Delivery Address API Endpoints
let GET_DELIVERY_ADDRESS = "/api/get-delivery-address"
let DELETE_DELIVERY_ADDRESS = "/api/delete-delivery-address"
let GET_BRANCH_LIST = "/api/get-available-branch-according-country"
let GET_ALL_BRANCH = "/api/get-all-branch"

let ADD_EDIT_DELIVERY_ADDRESS = "/api/add-edit-delivery-address"
//let BRANCH_AT_LOCATION        = "/api/is-branch-available"
//let SEARCH_BY_KEYWORDS        = "/api/get-fooditem-search-key"
//let SEARCH_BY_FOOD            = "/api/get-search-by-foodItems"
let BRANCH_AVAILABLE_LOCATION = "/api/is-branch-available"
let BRANCH_AVAILABLE_PIN      = "/api/is-branch-available-with-pin"
let GET_ALL_FOOD_ITEMS        = "/api/get-food-item"
let GET_BANNER                = "/api/get-banner"
let GET_BRANCH_LIST_WITH_PIN = "/api/get-branch-available-with-pin"
let GET_BRANCH_DETAILS_WITH_COUNTRY = "/api/get-branch-details-with-country"
let GET_FOOD_CATAGORY = "/api/get-category"
//let GET_MY_ORDER_LIST = "/api/my-order"
let GET_MY_ORDER_LIST_NEW = "/api/my-order-app"
let GET_ORDERDETAILS_BYID = "/api/order-details-against-id"
let DEFAULT_SEARCH = "/api/get-fooditem-key"//"/api/get-fooditem-search-key"/
let SEARCH_BY_KEY = "/api/get-search-food-by-search-key"//get-search-food-by-search-key //get-search-by-foodItems
let GET_FOOD_SUB_CATAGORY = "/api/get-type-by-category"
let GET_FOOD_ITEM_LIST = "/api/get-food-item-with-catid-typeid"
let GET_FOOD_ITEM_DETAILS = "/api/get-food-detail-by-foodid"
let ADD_TO_CART = "/api/add-to-cart"
let ADD_TO_CART_COMBO = "/api/placing-add-to-cart-for-combo"
let MY_CART_DETAILS = "/api/get-mycart"
let UPDATE_CART_ITEM_QTY = "/api/food-combo-qty"
let DELETE_MYCART = "/api/delete-mycart"
let CLEAR_CART = "/api/clear-mycart"
let EDIT_CART = "/api/modify-mycart"
let PLACE_ORDER = "/api/placing-order"
let REORDER     = "/api/re-order"
let ORDER_STATUS  = "/api/order-status"
let GET_BRANCH_BY_SERVICE = "/api/get-order-branch-details-according-service"
let GET_TAX = "/api/get-tax"
let GET_TAX_BY_COUNTRY = "/api/get-tax-by-country"
let NOTIFICATION_READ = "/api/notification-read"
let REQUEST_PAYMENT = "/api/request-payment-transaction"
let CONFIRM_PAYMENT = "/api/confirm-payment-transaction"
//let REQUEST_PEYALA_CASH = "/api/my-peyala-cash"
let REQUEST_PEYALA_CASH_NEW = "/api/my-peyala-cash-app"
let REQUEST_PEYALA_STORE_CREDENTIAL = "/api/get-credentials-for-payment"
let INVITE_FRIEND = "/api/invite-friend"

// Tag
let peyalaCashTableViewTag = 939

// Social Link
let peyalaFaceBookLink = "https://www.facebook.com/peyalabd/"
let peyalaInstaLink = "https://www.instagram.com/instapeyala/"

//MARK: - Google API URL
let googleBaseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
let googleAPIKey = "AIzaSyDAHiODmRMtFhuEe6KM5EEtU7CkthafiDk"

//MARK: - Crittercism
let CRITTERCISM_APP_ID = "9aeb89413dde46ccacbbbbc20fed291300555300"

let SYSTEM_VERSION = UIDevice.current.systemVersion
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let DEVICE_TYPE = "IOS"
let REG_LOGIN_TYPE = "Mobile"
//let DEFAULT_COLOR: UIColor = UIColorRGB(32, g: 72, b: 23)
let DEFAULT_COLOR: UIColor = UIColorRGB(11, g: 140, b: 60)
let BG_CREAM_COLOR: UIColor = UIColor(red: 244.0/255.0, green: 234.0/255.0, blue: 211.0/255.0, alpha: 1.0)
let popupRedCrossButtonPadding = IS_IPAD() ? CGFloat(15.0) : CGFloat(6.0)
let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
let servicesStoryboard: UIStoryboard = UIStoryboard(name: "Services", bundle: nil)
let utilityStoryboard: UIStoryboard = UIStoryboard(name: "Utility", bundle: nil)
let otherStoryboard: UIStoryboard = UIStoryboard(name: "Other", bundle: nil)

let FONT_REGULAR   = "Calibri-Light"
let FONT_SEMI_BOLD = "Calibri"
let FONT_BOLD      = "Calibri-Bold"
let FONT_REGULAR_CASH = "AxureHandwriting"
let FONT_REGULAR_BOLD_CASH = "AxureHandwriting-Bold"
let FONT_SEMI_CASH = "AxureHandwriting-BoldItalic"
let FONT_ITALIC_CASH = "AxureHandwriting-Italic"

let SERVER_DATE_FORMAT = "dd-MM-yyyy"
let LOCAL_DATE_FORMAT = "dd/MM/yyyy"

let JSONFILE_COUNTRYLIST = "countrylist.json"
let KEY_SERVICE_TAX = "Service Tax"

let GOOGLE_API_KEY = ""

let CODE_SUCCESS = "200"
let CODE_INACTIVE_USER = "205"
let CODE_SESSION_TOKEN_MISMATCH = "202"

let MAXIMUM_CART_COUNT = "99+"
func IS_IPAD() -> Bool {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:        // It's an iPhone
        return false
    case .pad:          // It's an iPad
        return true
    case .unspecified:  // undefined
        return false
    default:
        return false
    }
}
func loadStoryBoardWithName(_ stroryboardName:String) -> UIStoryboard {
    return UIStoryboard(name: stroryboardName, bundle: nil)
}

func currentViewController() -> UIViewController {
    return PYLNavigationHelper.helper.navigationController.viewControllers.last!
}

func SWIFT_CLASS_STRING(_ className: String) -> String? {
    return "\(Bundle.main.infoDictionary!["CFBundleName"] as! String).\(className)";
}


func SET_OBJ_FOR_KEY(_ obj : AnyObject, key : String) {
    UserDefaults.standard.set(obj, forKey: key)
}

func OBJ_FOR_KEY(_ key : String) -> AnyObject {
    return UserDefaults.standard.object(forKey: key)! as AnyObject
}

func SET_INTEGER_FOR_KEY(_ integer : Int, key : String) {
    UserDefaults.standard.set(integer, forKey: key)
}

func INTEGER_FOR_KEY(_ key : String) -> Int {
    return UserDefaults.standard.integer(forKey: key)
}

func SET_BOOL_FOR_KEY(_ bool : Bool, key : String) {
    UserDefaults.standard.set(bool, forKey: key)
}

func BOOL_FOR_KEY(_ key : String) -> Bool {
    return UserDefaults.standard.bool(forKey: key)
}

func UIColorRGB(_ r : CGFloat, g : CGFloat, b : CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

func UIColorRGBA(_ r : CGFloat, g : CGFloat, b : CGFloat, a : CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func kWindowView() -> AnyObject {
    return UIApplication.shared.windows.first!
}

func appdelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func generateUniqueTransactionID(_ withkey : String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    let date = dateFormatter.string(from: Date())
    let uniqueKey = "\(withkey)\(date)"
    return uniqueKey
}


/*
 if #available(iOS 9.0, *)
 {
 //System version is more than 9.0
 }
 else
 {
 
 }
 */
