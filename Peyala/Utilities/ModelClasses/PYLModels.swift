//
//  PYLModels.swift
//  Peyala
//
//  Created by Adarsh on 22/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import Foundation

class ModelUser {
    
    var userID:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var email:String = ""
    var address:String = ""
    var profileImageUrl:String = ""
    var phone:String = ""
    var zipCode:String = ""
    var gender:String = ""
    var dob:String = ""
    var loyaltypoint = ""
    var loyaltypercentage = ""
    var loyaltycash = ""
    var loyaltyunitvalue = ""
    
    init(userID:String?, firstName:String?, lastName:String?, email:String?, address:String?, profileImageUrl:String?, phone:String?, zipCode:String?, gender:String?, dob:String? , loyaltypoint : String? , loyaltypercentage : String? , loyaltycash : String? ,loyaltyunitvalue:String?) {
        
        if let str = userID {
            self.userID = str
        }
        if let str = firstName {
            self.firstName = str
        }
        if let str = lastName {
            self.lastName = str
        }
        if let str = email {
            self.email = str
        }
        if let str = address {
            self.address = str
        }
        if let str = profileImageUrl {
            self.profileImageUrl = str
        }
        if let str = phone {
            self.phone = str
        }
        if let str = zipCode {
            self.zipCode = str
        }
        if let str = gender {
            self.gender = str
        }
        if let str = dob {
            self.dob = str
        }
        if let str = loyaltypercentage {
            self.loyaltypercentage = str
        }
        if let str = loyaltypoint {
            self.loyaltypoint = str
        }
        if let str = loyaltycash {
            self.loyaltycash = str
        }
        if let str = loyaltyunitvalue {
            self.loyaltyunitvalue = str
        }
    }
    
    func dictionaryValue() -> [String:String] {
        
        return ["userID":userID,
                "firstName":firstName,
                "lastName":lastName,
                "email":email,
                "address":address,
                "profileImageUrl":profileImageUrl,
                "phone":phone,
                "zipCode":zipCode,
                "gender":gender,
                "dob":dob,
                "loyaltypercentage":loyaltypercentage,
                "loyaltypoint": loyaltypoint ,
                "loyaltycash" : loyaltycash ,
                "loyaltyunitvalue":loyaltyunitvalue]
    }
}

class ModelPlaceOrder {
    
    var totalPrice:String = ""
    var totalPriceWithOutVat:String = ""
    var totalReceivablePeyalaCash:String = ""
    var orderType:String = ""
    var branchID:String = ""
    var takeAwayOrDeliveryTime:String = ""
    var tax:String = ""
    var allergyNotes:String = ""
    var addressID:String = ""
    var addressLine1:String = ""
    var addressLine2:String = ""
    var addressLandmark:String = ""
    var addressCity:String = ""
    var addressPin:String = ""
    var addressPhone:String = ""
    var transactionId = ""
    
    //    { "address_id": "", "address_line1": "LCpisgeRXFiMmA9NOC9OQQ==", "address_line2": "LCpisgeRXFiMmA9NOC9OQQ==", "landmark": "LCpisgeRXFiMmA9NOC9OQQ==", "city": "LCpisgeRXFiMmA9NOC9OQQ==", "pin": "LCpisgeRXFiMmA9NOC9OQQ==", "phone_no": "LCpisgeRXFiMmA9NOC9OQQ==" }
}

class ModelTax {
    
    var taxName:String = ""
    var taxPercentage:String = "0.0"
}
