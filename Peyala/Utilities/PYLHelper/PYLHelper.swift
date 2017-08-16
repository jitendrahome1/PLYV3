//
//  PYLHelper.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
class PYLHelper: NSObject {
    static let helper = PYLHelper()
    fileprivate override init() {}
    
    var deviceID: String?
    var sessionID: String!
    var userModelObj: ModelUser?
    var placeOrderObj: ModelPlaceOrder?
    var countryNameArray = [String]()
    var countryArrayDetails = [AnyObject]()
    var selectedCountryFlagURL: String = ""
    var selectedCountryFlagImage = UIImage()
    var searchKeyArray = [String]()
    var latitude:String?
    var longitude:String?
    var selectedServiceType:DeliveryOption!
    var selectedSlot:String  = ""
    var userCountryID: String?
    var branchAsPerServiceType = [AnyObject]()
    var arrFoodCategory = [AnyObject]()
    var arrTax = [ModelTax]()
    var placedOrderID = ""
    var LogginStatusChanged : Bool = false
    var isNetworkOn = false
    
    var nextViewControllerIdentifier: String = "PYLDashBoardViewController"
    var nextViewControllerStoryBoard: UIStoryboard = servicesStoryboard
}
