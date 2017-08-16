
//
//  PYLAPIHandler.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
class PYLAPIHandler: NSObject {
    
    static let handler = PYLAPIHandler()
    fileprivate override init() {}
    
    //MARK: Registration
    func registerAccount(_ firstname: String, lastname: String, gender: String, dob: String, email: String,phone_no: String,password: String,zipcode: String, referralCode: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
//        let params = ["firstname" : firstname.setAESEncription(),
//                      "lastname"  : lastname.setAESEncription(),
//                      "gender"    : gender.setAESEncription(),
//                      "dob"       : dob.ConvertDateToFormat(SERVER_DATE_FORMAT, fromFormat:LOCAL_DATE_FORMAT).setAESEncription(),
//                      "email"     : email.setAESEncription(),
//                      "phone_no"  :phone_no.setAESEncription(),
//                      "password"  :password.setAESEncription(),
//                      "zipcode"   :zipcode.setAESEncription(),
//                      "device_type": DEVICE_TYPE.setAESEncription(),
//                      "login_type": REG_LOGIN_TYPE.setAESEncription(),
//                      "device_token":(PYLHelper.helper.deviceID != nil) ? PYLHelper.helper.deviceID!.setAESEncription() : "Simulator"]
        
        let params = ["firstname" : firstname.setAESEncription(),
                      "lastname"  : lastname.setAESEncription(),
                      "gender"    : gender.setAESEncription(),
                      "dob"       : dob.ConvertDateToFormat(SERVER_DATE_FORMAT, fromFormat:LOCAL_DATE_FORMAT).setAESEncription(),
                      "email"     : email.setAESEncription(),
                      "phone_no"  :phone_no.setAESEncription(),
                      "password"  :password.setAESEncription(),
                      "zipcode"   :zipcode.setAESEncription(),
                      "referral_code"   :referralCode.setAESEncription(),
                      "device_type": DEVICE_TYPE.setAESEncription(),
                      "login_type": REG_LOGIN_TYPE.setAESEncription(),
                      "device_token":(PYLHelper.helper.deviceID != nil) ? PYLHelper.helper.deviceID!.setAESEncription() : "Simulator"]
        
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["userRegistrationValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(REGISTER_API, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Normal Login
    func login(_ username: String?, password: String?, success:@escaping (_ response: JSON?)->(), failure:(_ error: NSError?)->()) {
        
        let params = ["username": username!.setAESEncription(),
                      "password": password!.setAESEncription(),
                      "device_type": DEVICE_TYPE.setAESEncription(),
                      "device_token":(PYLHelper.helper.deviceID != nil) ? PYLHelper.helper.deviceID!.setAESEncription() : "Simulator"]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["userLoginValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(LOGIN, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
        }
    }
    
    //MARK: is-User-Login
    func isUserlogin(_ userId: String?, success:@escaping (_ response: JSON?)->(), failure:(_ error: NSError?)->()) {
        
        let params = ["userid": userId!.setAESEncription(),
                      "status": "YES".setAESEncription(),
                      "device_type": DEVICE_TYPE.setAESEncription(),
                      "device_token":(PYLHelper.helper.deviceID != nil) ? PYLHelper.helper.deviceID!.setAESEncription() : "Simulator"]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["isUserLogin" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(IS_LOGIN, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
        }
    }
    
    //MARK:- Social Facebook Login
    func socialLogin(_ socialID:String? , email: String?, firstName:String?,lastName:String?,gender:String?,dob:String,fbImageURL:String?,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["first_name" : firstName!.setAESEncription(),
                      "last_name"  : lastName!.setAESEncription(),
                      "gender"    : gender!.setAESEncription(),
                      "dob"       :dob.length > 0 ? dob.ConvertDateToFormat(SERVER_DATE_FORMAT, fromFormat:"MM/DD/YYYY").setAESEncription():"",
                      "email"     : email!.setAESEncription(),
                      "social_id"     : socialID!.setAESEncription(),
                      "fb_image_url"     : fbImageURL!.setAESEncription(),
                      "device_type": DEVICE_TYPE.setAESEncription(),
                      //"login_type": REG_LOGIN_TYPE.setAESEncription(),
                      "device_token":(PYLHelper.helper.deviceID != nil) ? PYLHelper.helper.deviceID!.setAESEncription() : "Simulator"]
        
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["socialLoginDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(SOCIAL_LOGIN, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Forgot Password
    func resetPasswordwith(_ type:String , emailORphone:String, success:@escaping (_ response: JSON?)->(), failure:(_ error: NSError?)->()) {
        
        let params = ["type": type.setAESEncription(),
                      "emailorphone": emailORphone.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["forgetPasswordDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(FORGOT_PASSWORD, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
        }
    }
    
    //MARK:- Logout API
    func logout(_ success:@escaping (_ response: JSON?)->(), failure:(_ error: NSError?)->()) {
        // got crash here
        let userDict = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
        let session_id = GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String
        let userID =  userDict!["userID"] as! String
        let params :[String :String] = ["user_id": userID.setAESEncription(),
                                        "session_id": session_id]
        
        PYLAPIManager.sharedManager.postRequestJSON(LOGOUT, parameters: [:], headers: params, success: { (response) in
            success(response)
        }) { (error) in
            /*
             debugPrint("Print: \(error)")
             if let userInfo = error?.userInfo {
             if let errorCode = userInfo["StatusCode"] as? NSNumber {
             if errorCode == 406{
             print(error.userInfo["StatusCode"]!)
             success(response: JSON([true]))
             }
             }
             }
             */
        }
    }
    
    //MARK: Get notification settings (Profile page)
    func setNotificationSettings(_ isEnable:Bool, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let decision = isEnable ? "YES" : "NO"
        let params = ["device_token": PYLHelper.helper.deviceID!.setAESEncription(),
                      "user_id": PYLHelper.helper.userModelObj!.userID.setAESEncription(),
                      "is_notification": decision.setAESEncription()]
        
        let JsonFormattedData = JSON(params).rawString()!
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let postData = ["settings_details" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(NOTIFICATION_SETTINGS, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Edit Profile
    func editProfile(firstname: String, lastname: String, gender: String, dob: String, email: String, phone_no: String, zipcode: String, address: String, imageFile: UIImage?, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ errorMsg:String)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let params = ["user_id": PYLHelper.helper.userModelObj!.userID.setAESEncription(),
                      "firstname": firstname.setAESEncription(),
                      "lastname": lastname.setAESEncription(),
                      "gender": gender.setAESEncription(),
                      "dob": dob.ConvertDateToFormat(SERVER_DATE_FORMAT, fromFormat:LOCAL_DATE_FORMAT).setAESEncription(),
                      "email": email.setAESEncription(),
                      "phone_no": phone_no.setAESEncription(),
                      "zipcode": zipcode.setAESEncription(),
                      "address": address.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["userEditProfile" : JsonFormattedData]
        
        if imageFile == nil {
            PYLAPIManager.sharedManager.postRequestJSON(EDIT_PROFILE, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
                success(response)
                
                }, failure: { (error) in
                    failure((error?.localizedDescription)!)
            })
            
        } else {
            var imageData = Data()
            var imageNameWithExtenSion = "image.png"
            if let image = imageFile {
                imageData = UIImageJPEGRepresentation(image, 0.1)!
                imageNameWithExtenSion = contentTypeForImageData(imageData)
            }
            
            PYLAPIManager.sharedManager.uploadFileMultipartFormDataWithParams(EDIT_PROFILE_IMAGE, headers: headers, file:imageData, fileName: imageNameWithExtenSion, parameters: postData as [String : AnyObject]?, success: { (response) in
                success(response)
                
            }) { (errorMessage) in
                failure(errorMessage)
            }
        }
    }
    
    //MARK:- Edit Phone No.
    func editPhoneNo(PhoneNo phone_no: String , success:@escaping (_ response: JSON?)->(), failure:@escaping (_ errorMsg:String)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let params = ["user_id": PYLHelper.helper.userModelObj!.userID.setAESEncription(),
                      "phone_no": phone_no.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["userEditProfile" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(EDIT_PHONE_NO, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
            }, failure: { (error) in
                failure((error?.localizedDescription)!)
        })
    }
    
    //MARK:- CountryList API
    func getCountryList(_ success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(COUNTRY_LIST, parameters: [:], headers: nil,OfflineStorage: "CountryList", success: { (response) in
            success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Branch List By Country
    func getBranchesByCountry(_ countryID: String, success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(),failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["country_id": countryID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData:[String:AnyObject] = ["fetchBranchLIst" : JsonFormattedData as AnyObject]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_BRANCH_LIST, parameters: postData, headers: nil,OfflineStorage: countryID, success: { (response) in
            success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: - Get All Branch
    func getAllBranch(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_ALL_BRANCH, parameters: [:], headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Get My Delivery Address
    func getMyDeliveryAddress(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userDict = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
        let userID =  userDict!["userID"] as! String
        let params = ["user_id": userID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["user_id" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_DELIVERY_ADDRESS, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Delete Delivery Address
    func deleteDeliveryAddress(_ address:[String], success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userDict = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
        let userID =  userDict!["userID"] as! String
        let params = ["user_id": userID.setAESEncription(),
                      "address_ids": address] as [String : Any]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["deletedeliveryAddress" : JsonFormattedData]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        
        PYLAPIManager.sharedManager.postRequestJSON(DELETE_DELIVERY_ADDRESS, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Add / Edit Delivery Address
    func addOrEditDeliveryAddress(_ addressID:String!,addressLine1:String!,addressLine2:String!,Landmark:String!,City:String!,Pincode:String,PhoneNo:String!, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userDict = GET_USERDEFAULT_VALUE(USER_DEFAULT_STORED_USER_KEY)
        let userID =  userDict!["userID"] as! String
        let params = ["user_id": userID.setAESEncription(),
                      "address_id":addressID.setAESEncription(),
                      "address_line1":addressLine1.setAESEncription(),
                      "address_line2":addressLine2.setAESEncription(),
                      "landmark":Landmark.setAESEncription(),
                      "city":City.setAESEncription(),
                      "pin_code":Pincode.setAESEncription(),
                      "phone_no":PhoneNo.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["deliveryAddress" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(ADD_EDIT_DELIVERY_ADDRESS, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK:- FAQ List API
    func getFAQList(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(FAQ_LIST, parameters: [:], headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Banner API
    func getBanner(_ success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_BANNER, parameters: [:], headers: nil,OfflineStorage: "Banner", success: { (response) in
                success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK: Get branch availability - according to user current location.
    func getBranchesAvailability(userLatitude latitude: String, userLongitude longitude: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["user_latitude": latitude.setAESEncription(), "user_longitude": longitude.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["userLocationDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(BRANCH_AVAILABLE_LOCATION, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
                success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Get branch availability - according to user's current location and Service Type
    func getBranchesByServiceAndAddress(preferredServiceType service: String, userLatitude latitude: String, userLongitude longitude: String,address:[String:String], saveAddInUserDirectory:String, success:@escaping (_ response: JSON?)->(), offlineBlock:(()->())? = nil, failure:@escaping (_ error: NSError?)->()) {
        
        guard PYLHelper.helper.isNetworkOn else {
            offlineBlock!()
            return
        }
        
        let currentTime = Date().currentTime24()
        let params = ["user_latitude":latitude.setAESEncription(),
                      "user_longitude":longitude.setAESEncription(),
                      "user_id":PYLHelper.helper.userModelObj!.userID.setAESEncription(),
                      "delivery_time_span":PYLHelper.helper.selectedSlot.setAESEncription(),
                      "address":address,
                      "branch_service_type": service.setAESEncription(),
                      "current_time" : "\(currentTime.Hour):\(currentTime.Minute)".setAESEncription(),
                      "saveInUserDirectory" : saveAddInUserDirectory.setAESEncription()] as [String : Any]
        let headers: [String:String] = ["session_id": PYLHelper.helper.sessionID!]
        let JsonFormattedData = JSON(params).rawString()!
        let postdata = ["inputDetails": JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_BRANCH_BY_SERVICE, parameters: postdata as [String : AnyObject]?, headers: headers, success: { (response) in
                success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Get all food items
    func getAllFoodItemsFrom(timeStamp:String, day : String,success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:(_ error: NSError?)->()) {
        
        let params = ["timeStamp": timeStamp.setAESEncription(),
                      "day": day.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["getForFoodItemsDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_ALL_FOOD_ITEMS, parameters: postData as [String : AnyObject]?, headers: nil,OfflineStorage:"AllFoodItems" , success: { (response) in
                success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
        }
    }
    
    //MARK: Get notification list
    func getNotificationList(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userId = PYLHelper.helper.userModelObj != nil ? PYLHelper.helper.userModelObj!.userID.setAESEncription() : ""
        let sessionID = GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) != nil ? GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String : ""
        let params = ["device_token": PYLHelper.helper.deviceID!.setAESEncription(), "user_id": userId]
        let JsonFormattedData = JSON(params).rawString()!
        let headers: [String:String] = ["session_id": sessionID]
        let postData = ["notification_details" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(NOTIFICATION_LIST, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Notification Read
    func notificationRead(notificationID: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {

        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(), "notification_id": notificationID.setAESEncription(),"device_token":PYLHelper.helper.deviceID!.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["notification_details" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(NOTIFICATION_READ, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Register Device Token
    func registerDevice(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["device_token": PYLHelper.helper.deviceID!.setAESEncription(), "deviceType": DEVICE_TYPE.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["deviceRegisterValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSONWithoutHUD(REGISTER_DEVICE, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
                success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: Get Tax
    func getTax(userLatitude latitude: String, userLongitude longitude: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["user_latitude":latitude.setAESEncription(),
                      "user_longitude":longitude.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postdata = ["taxDetails": JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSONWithoutHUD(GET_TAX, parameters: postdata as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    func getTax(_ countryID: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {

        let params = ["country_id":countryID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postdata = ["taxDetails": JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_TAX_BY_COUNTRY, parameters: postdata as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Food Catagory List API
    func getFoodCatagoryList(_ success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_FOOD_CATAGORY, parameters: [:], headers: nil,OfflineStorage: "foodCat", success: { (response) in
            success(response)
            }, offlineBlock: { (response) in
                offlineBlock(response)
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- My Order List API
    func getMyOrderList(_ success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {

        if let userId = PYLHelper.helper.userModelObj?.userID {
            
            let params = ["user_id": userId.setAESEncription()]
            let JsonFormattedData = JSON(params).rawString()!
            let postData = ["myOrderDetails" : JsonFormattedData]
            let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]

            PYLAPIManager.sharedManager.postRequestJSON(GET_MY_ORDER_LIST_NEW, parameters: postData as [String : AnyObject]?, headers: headers, OfflineStorage: "MyOrderList", success: { (response) in
                    success(response)
              
                }, offlineBlock: { (response) in
                    offlineBlock(response)
           
            }) { (error) in
                failure(error)
            }
        }
    }
    
    //MARK:- My Order Details By ID
    func getOrderDetailsbyID(_ ID : String, success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        if let userId = PYLHelper.helper.userModelObj?.userID {
            
            let params = ["user_id": userId.setAESEncription(),
                          "order_id": ID.setAESEncription()]
            let JsonFormattedData = JSON(params).rawString()!
            let postData = ["orderDetailsAgainstId" : JsonFormattedData]
            let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
            
            PYLAPIManager.sharedManager.postRequestJSON(GET_ORDERDETAILS_BYID, parameters: postData as [String : AnyObject]?, headers: headers, OfflineStorage: "MyOrderDetails", success: { (response) in
                success(response)
                
                }, offlineBlock: { (response) in
                    offlineBlock(response)
                    
            }) { (error) in
                failure(error)
            }
        }
    }
    
    
    //MARK:- Default Search List API
    func defaultSearchList(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLAPIManager.sharedManager.postRequestJSON(DEFAULT_SEARCH, parameters: ["":"" as AnyObject], headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Search By Key API
    func searchByKey(_ searchKey:String,page:String,pagecontent:String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let params = ["search_key": searchKey.setAESEncription(),
                      "day":Date().dayOfTheWeek()!.uppercased().setAESEncription(),
                      "page_no" : page.setAESEncription(),
                      "page_content" : pagecontent.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["getSearchkeyDetails" : JsonFormattedData]

        PYLAPIManager.sharedManager.postRequestJSON(SEARCH_BY_KEY, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- get food sub catagory API
    func getFoodSubCatagory(_ catagoryID:String, success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        let params = ["food_category_id": catagoryID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["fetchFoodSubcategory" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_FOOD_SUB_CATAGORY, parameters: postData as [String : AnyObject]?, headers: nil,OfflineStorage: "\(catagoryID)subCat", success: { (response) in
                success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- get food details by catagory API
    func getFoodItemByCatagory(_ catagoryID: String, subCatagoryID: String,pageNo : String, pageContent:String,success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        let params = ["food_category_id": catagoryID.setAESEncription(),
                      "food_subcategory_id": subCatagoryID.setAESEncription(),
                      "timestamp": "",
                      "day": Date().dayOfTheWeek()!.uppercased().setAESEncription(),
                      "page_no": pageNo.setAESEncription(),
                      "page_content": pageContent.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["getForFoodItemsDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_FOOD_ITEM_LIST, parameters: postData as [String : AnyObject]?, headers: nil,OfflineStorage: "\(catagoryID)\(subCatagoryID)\(pageNo)", success: { (response) in
            success(response)
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- get food details by catagory API
    func getFoodDetails(_ foodID: String,success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        let params = ["food_id": foodID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["foodItemsDetail" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(GET_FOOD_ITEM_DETAILS, parameters: postData as [String : AnyObject]?, headers: nil,OfflineStorage:"foodID\(foodID)" , success: { (response) in
            success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- add to cart API
    func addToCart(_ foodID:String, note:String, foodItemQty:String, foodSizeID:String, totalPrice:String, defaultAddOnArray: [[String:String]], extraAddOnArray: [[String:String]],success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "note": note.setAESEncription(),
                      "food_id": foodID.setAESEncription(),
                      "qty": foodItemQty.setAESEncription(),
                      "food_size_id": foodSizeID.setAESEncription(),
                      "total_price": totalPrice.setAESEncription(),
                      "default_addon_details": defaultAddOnArray,
                      "extra_addon_details": extraAddOnArray] as [String : Any]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["addToCartPlacingValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(ADD_TO_CART, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- add to cart with Combo, API
    func addToCartWithCombo(_ addToCartID:String, comboTakingOrNot:Bool, totalPrice:String, foodDetailsArray: [[String:AnyObject]], comboDetailsArray: [[String:AnyObject]],success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let strComboTakingOrNot = comboTakingOrNot ? "true" : "false"
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "add_to_cart_id": addToCartID,
                      "comboTakingOrNot": strComboTakingOrNot.setAESEncription(),
                      "total_price": totalPrice.setAESEncription(),
                      "food_details": foodDetailsArray,
                      "combo_details": comboDetailsArray] as [String : Any]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["addToCartComboPlacingValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(ADD_TO_CART_COMBO, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK:  About Us
    func getAboutUsDetails(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        PYLAPIManager.sharedManager.postRequestJSON(ABOUT_US, parameters: [:], headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    //MARK:-  Contact Us
    func getContactUsDetails(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        PYLAPIManager.sharedManager.postRequestJSON(CONTACT_US, parameters: [:], headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK: - CART
    //MARK:- get my cart details
    func getMyCartDetails(_ success:@escaping (_ response: JSON?)->(), offlineBlock:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        // got crash during logout
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id":userID!.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["mycart" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(MY_CART_DETAILS, parameters: postData as [String : AnyObject]?, headers: headers, OfflineStorage: "MyCart", success: { (response) in
                success(response)
            
            }, offlineBlock: { (response) in
                offlineBlock(response)
                
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK: update cart item quantity api
    func updateCartItemQuantity(_ foodUniqueID:String, comboUniqueID:String,totalPrice:String, quantity:String,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id":userID!.setAESEncription(),
                      "food_unique_id":foodUniqueID.setAESEncription(),
                      "combo_unique_id":comboUniqueID.setAESEncription(),
                      "total_price":totalPrice.setAESEncription(),
                      "qty":quantity.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["updateFoodComboQty" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(UPDATE_CART_ITEM_QTY, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- delete single food-item from cart
    func deleteFoodItemFromCart(_ foodUniqueID:String, comboUniqueID:String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id":userID!.setAESEncription(),
                      "food_unique_id":foodUniqueID.setAESEncription(),
                      "combo_unique_id":comboUniqueID.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["deleteFromMyCart" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(DELETE_MYCART, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- clear whole cart
    func clearCart(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id":userID!.setAESEncription(),
                      "session_id":""]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["clearMycart" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(CLEAR_CART, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- edit cart API
    func editCart(_ dictFoodDetails: [String:AnyObject], dictComboDetails: [String:AnyObject],success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "food_details": dictFoodDetails,
                      "combo_details": dictComboDetails,
                      ] as [String : Any]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["modifyMycart" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(EDIT_CART, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- place order
    func placeOrder(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        PYLHelper.helper.placeOrderObj!.branchID = PYLHelper.helper.placeOrderObj!.branchID.isBlank ? "1" : PYLHelper.helper.placeOrderObj!.branchID
        let addressDict = ["address_id":PYLHelper.helper.placeOrderObj!.addressID.setAESEncription(),
                           "address_line1":PYLHelper.helper.placeOrderObj!.addressLine1.setAESEncription(),
                           "address_line2":PYLHelper.helper.placeOrderObj!.addressLine2.setAESEncription(),
                           "landmark":PYLHelper.helper.placeOrderObj!.addressLandmark.setAESEncription(),
                           "city":PYLHelper.helper.placeOrderObj!.addressCity.setAESEncription(),
                           "pin":PYLHelper.helper.placeOrderObj!.addressPin.setAESEncription(),
                           "phone_no":PYLHelper.helper.placeOrderObj!.addressPhone.setAESEncription()]
        let params = ["user_id":PYLHelper.helper.userModelObj!.userID.setAESEncription(),
                      "day":Date().dayOfTheWeek()!.uppercased().setAESEncription(),
                      "total_price":PYLHelper.helper.placeOrderObj!.totalPrice.setAESEncription(),
                      "price_without_Vat":PYLHelper.helper.placeOrderObj!.totalPriceWithOutVat.setAESEncription(),
                      "receive_peyala_cash":PYLHelper.helper.placeOrderObj!.totalReceivablePeyalaCash.setAESEncription(),
                      "order_type":PYLHelper.helper.placeOrderObj!.orderType.setAESEncription(),
                      "branch_id":PYLHelper.helper.placeOrderObj!.branchID.setAESEncription(),
                      "take_away_or_delivery_time":PYLHelper.helper.selectedSlot.setAESEncription(),
                      "total_tax" : PYLHelper.helper.placeOrderObj!.tax.setAESEncription(),
                      "allergy_note" : PYLHelper.helper.placeOrderObj!.allergyNotes.setAESEncription(),
                      "address":addressDict,
                      "current_time":(Date().dateToStringWithCustomFormat("yyyy-MM-dd HH:mm:ss.SS")).setAESEncription()] as [String : Any]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["orderPlacingValue" : JsonFormattedData]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        
        PYLAPIManager.sharedManager.postRequestJSON(PLACE_ORDER, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Re-Order API
    func reOrder(_ orderID:String!,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "order_id": orderID.setAESEncription()]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["orderPlacingValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(REORDER, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Track Order (Order Status)
    func checkOrderStatus(_ orderID:String!,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "order_id": orderID.setAESEncription()]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["orderId" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(ORDER_STATUS, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Payment Process
    func requestPaymentTransaction(_ TransactionType: String , OrderID: String, PayByPeyalaCash:String, OrderPrice:String,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "transaction_id": generateUniqueTransactionID(userID!).setAESEncription(),
                      "transaction_type": TransactionType.setAESEncription(),
                      "order_id": OrderID.setAESEncription(),
                      "payby_peyala_cash": PayByPeyalaCash.setAESEncription(),
                      "order_price":OrderPrice.setAESEncription(),
                      "current_time":(Date().dateToStringWithCustomFormat("yyyy-MM-dd HH:mm:ss.SS")).setAESEncription()]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["requestPaymentTransaction" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(REQUEST_PAYMENT, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    func confirmPaymentTransaction(_ transactionDetails : String , orderID : String,transactionID : String,status : String,amount : String,cardNo : String,transactionDate : String, sessionKey:String ,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {

        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "transaction_id": transactionID.setAESEncription(),
                      "order_id": orderID.setAESEncription(),
                      "status": status.setAESEncription(),
                      "transaction_details": transactionDetails.setAESEncription(),
                      "amount": amount.setAESEncription(),
                      "card_no": cardNo.setAESEncription(),
                      "sessionkey": sessionKey.setAESEncription(),
                      "tran_date": transactionDate.setAESEncription(),
                      "current_time":(Date().dateToStringWithCustomFormat("yyyy-MM-dd HH:mm:ss.SS")).setAESEncription()]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["confirmPaymentTransaction" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(CONFIRM_PAYMENT, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- REQUEST PEYALA CASH
    func requestMyPeyalaCash(_ success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription()]
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["myCashDetails" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(REQUEST_PEYALA_CASH_NEW, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- GET PEYALA STORE CREDENTIAL
    func requestMyPeyalaStoreCredential(_ runInTestMode: String, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        // runInTestMode = 0 for Live Account Credential
        // runInTestMode = 1 for Test Account Credential
        let params = ["runInTestMode": runInTestMode.setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["paymentCredentials" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(REQUEST_PEYALA_STORE_CREDENTIAL, parameters: postData as [String : AnyObject]?, headers: nil, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
    
    //MARK:- Invite friend API
    func inviteFriend(_ emailID:String?, mobile:String?,success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        
        let headers: [String:String] = ["session_id": GET_USERDEFAULT_VALUE(USER_DEFAULT_SESSION_ID_KEY) as! String]
        let userID = PYLHelper.helper.userModelObj?.userID
        let params = ["user_id": userID!.setAESEncription(),
                      "email_id": (emailID ?? "").setAESEncription(),
                      "mobile_no": (mobile ?? "").setAESEncription()]
        let JsonFormattedData = JSON(params).rawString()!
        let postData = ["friendDetailsValue" : JsonFormattedData]
        
        PYLAPIManager.sharedManager.postRequestJSON(INVITE_FRIEND, parameters: postData as [String : AnyObject]?, headers: headers, success: { (response) in
            success(response)
            
        }) { (error) in
            failure(error)
        }
    }
}
