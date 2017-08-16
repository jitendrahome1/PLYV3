//
//  APIFire.swift
//  SwiftDelegateAndClosure
//
//  Created by Priyam Dutta on 13/06/16.
//  Copyright © 2016 Indus Net Technologies. All rights reserved.
//

import UIKit
import Alamofire
import SystemConfiguration
import Reqres


let TIMEOUT_TIME = 30


var global_ShallShowHudForThisCall = true

func +=<K, V> (left: inout [K : V], right: [K : V]) {
    for (k, v) in right {
        left[k] = v
    }
}


class PYLAPIManager: Alamofire.SessionManager {
    
    //     static let sharedManager: PYLAPIManager = {
    //        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    //        configuration.timeoutIntervalForRequest = TIMEOUT_TIME
    //        configuration.timeoutIntervalForResource = TIMEOUT_TIME
    //        let
    //        //NetworkReachabilityManager()?.startListening()
    //        return manager
    //    }()
    
    static let sharedManager: PYLAPIManager = {
        
        var manager: PYLAPIManager?
//        #if DEBUG
//            let configuration = Reqres.defaultSessionConfiguration()
//            //configuration.HTTPAdditionalHeaders = manager.defaultHTTPHeaders
//            manager = PYLAPIManager(configuration: configuration)
//        #else
//            manager = PYLAPIManager()
//        #endif
//
//        configuration.timeoutIntervalForRequest = TIMEOUT_TIME
//        configuration.timeoutIntervalForResource = TIMEOUT_TIME
        
        // During Archiving //
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = (TimeInterval)(TIMEOUT_TIME)
        configuration.timeoutIntervalForResource = TimeInterval(TIMEOUT_TIME)
        manager = PYLAPIManager(configuration: configuration)
         // During Archiving //
        
        return manager!
    }()
    
    //todo
    // ******* Client Server ******* //
    //    private var baseURL   = "http://121.200.242.147:8080/peyala"
    
    // ******* IndusNet Server ******* //
    //private var baseURL = "http://peyala.indusnettechnologies.com:8080/peyala"
    
//    fileprivate var baseURL = "http://162.243.173.94:8080/peyala"
    
    // ******* Local Server ******* //
    //    private var baseURL = "http://10.0.8.84:8080/peyala"
       // private var baseURL = "http://10.0.8.85:8089/peyala"
    private var baseURL = "http://10.0.8.85:8089/peyala"
//    private var baseURL = "http://10.0.8.86:8080/peyala"
    
    fileprivate static let apiKey = ""
    fileprivate let parameterEncoding: ParameterEncoding = URLEncoding.queryString
    internal var header: [String:String] = ["Content-Type": "application/x-www-form-urlencoded"]
    let network = NetworkReachabilityManager()
    
    //MARK: Reachability Check
    internal func isReachable() -> (Bool) {
        if  network?.isReachable ?? false {
            if ((network?.isReachableOnEthernetOrWiFi) != nil) {
                return true
            }else if(network?.isReachableOnWWAN)! {
                return true
            }
        }
        else {
            return false
        }
        return false
    }
    
    func startMonitoring() {
        
        network?.startListening()
        network!.listener = { status in
            if status == .notReachable {
                //toast delay time non-functional
                //UIApplication.sharedApplication().keyWindow!.showToastWithMessage(NO_NETWORK, delayTime: 3.0)
                showNoNetworkView()
                PYLHelper.helper.isNetworkOn = false
            } else if status == .unknown {
                PYLHelper.helper.isNetworkOn = false
                
            }
            else { //means reachable
                removeNoNetworkView()
                PYLHelper.helper.isNetworkOn = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NETWORK_REACHABILITY), object: nil)
            }
        }
    }
    
    //MARK: API Callings
    /************************** General Requests ***************************/
    /**
     POST REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    //    func postRequestJSON(endPoint: String, parameters:[String: AnyObject]?, headers:[String: String]?,OfflineStorage:String? = nil, success:(response: JSON!)->(), failure:(error: NSError!)->()) {
    //        defer {
    //            print("POST REQUEST for endpoint \(endPoint) successfully executed")
    //        }
    //        if isReachable() {
    //            debugPrint("show loader")
    //            dispatch_async(dispatch_get_main_queue()) {
    //                PYLSpinner.show()
    //            }
    //
    //            if headers != nil {
    //                header += headers!
    //            }
    //
    //            //            if (endPoint == ADD_TO_CART_COMBO) || (endPoint == ADD_TO_CART) {
    //            //                baseURL = baseURLLocal
    //            //            }
    //
    //            //            if (endPoint == PLACE_ORDER) {
    //            //                baseURL = baseURLLocal
    //            //            }
    //
    //
    //            PYLAPIManager.sharedManager.request(.POST, baseURL + endPoint, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
    //                debugPrint("hide loader")
    //                dispatch_async(dispatch_get_main_queue()) {
    //                    PYLSpinner.hide()
    //                }
    //
    //                guard response.result.isSuccess else {
    //                    failure(error: response.result.error)
    //                    self.showError(error: (response.result.error as NSError?)!)
    //                    return
    //                }
    //                if let value = response.result.value {
    //                    if OfflineStorage != nil{
    //                        JSON(value).storeJSONtoFile(OfflineStorage!)
    //                    }
    //                    success(response: JSON(value))
    //                }
    //            }
    //        } else {
    //            debugPrint("No Network.")
    //            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
    //            if OfflineStorage != nil{
    //                if (JSON.getJSONFromFile(OfflineStorage!) != nil) {
    //                    success(response: JSON.getJSONFromFile(OfflineStorage!))
    //                }
    //            }
    //        }
    //    }
    
    func postRequestJSON(_ endPoint: String, parameters:[String: AnyObject]?, headers:[String: String]?,OfflineStorage:String? = nil, success:@escaping (_ response: JSON?)->(), offlineBlock:((_ response: JSON?)->())? = nil, failure:@escaping (_ error: NSError?)->()) {
        defer {
            print("POST REQUEST for endpoint \(endPoint) successfully executed")
        }
        if isReachable() {
            debugPrint("show loader")
            DispatchQueue.main.async {
                
                if(global_ShallShowHudForThisCall) {
                    PYLSpinner.show()
                }
                global_ShallShowHudForThisCall = true
            }
            //PYLSpinner.show()
            
            if headers != nil {
                header += headers!
            }
            
            //            if (endPoint == ADD_TO_CART_COMBO) || (endPoint == ADD_TO_CART) {
            //                baseURL = baseURLLocal
            //            }
            //            if (endPoint == PLACE_ORDER) {
            //                baseURL = baseURLLocal
            //            }
            
            let totalUrl = (baseURL + endPoint)
            //let  param = ((parameters == nil) ? nil : parameters!)
           
            PYLAPIManager.sharedManager.request(totalUrl, method: .post, parameters: parameters!, encoding: parameterEncoding, headers: headers).validate().responseJSON(completionHandler: { (response) in
                
                
                if (endPoint == GET_DELIVERY_ADDRESS) {
                    // As this particular API is working too fast, tis spinner is getting hide too fast as its displaying as flick effect. Just to overcome this some delay has been added for that particular API.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                          PYLSpinner.hide()
                    }
                    
                } else {
                    DispatchQueue.main.async( execute: {
                        PYLSpinner.hide()
                    })
                    
                }
                debugPrint(endPoint)
                //PYLSpinner.hide()
                
                guard response.result.isSuccess else {
                    failure(response.result.error as NSError?)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                if let value = response.result.value {
                    if OfflineStorage != nil{
                        JSON(value).storeJSONtoFile(OfflineStorage!)
                    }
                    success(JSON(value))
                }
            
            })
            
            /*
            PYLAPIManager.sharedManager.request(.POST,totalUrl , parameters: parameters, encoding: JSONEncoding(options: []), headers: header).validate().responseJSON { (response) in
                debugPrint("hide loader")
                
                if (endPoint == GET_DELIVERY_ADDRESS) {
                    // As this particular API is working too fast, tis spinner is getting hide too fast as its displaying as flick effect. Just to overcome this some delay has been added for that particular API.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        PYLSpinner.hide()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        PYLSpinner.hide()
                    }
                }
                debugPrint(endPoint)
                //PYLSpinner.hide()
                
                guard response.result.isSuccess else {
                    failure(error: response.result.error)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                if let value = response.result.value {
                    if OfflineStorage != nil{
                        JSON(value).storeJSONtoFile(OfflineStorage!)
                    }
                    success(response: JSON(value))
                }
            }*/
        } else {
            debugPrint("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
            //            animateNoNetworkViewIfPresent()       //noNetwork animate
            if OfflineStorage != nil{
                if (JSON.getJSONFromFile(OfflineStorage!) != nil) {
                    offlineBlock!(JSON.getJSONFromFile(OfflineStorage!))
                }
            }
        }
    }
    
    
    func postRequestJSONWithoutHUD(_ endPoint: String, parameters:[String: AnyObject]?, headers:[String: String]?, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        defer {
            print("POST REQUEST for endpoint \(endPoint) successfully executed")
        }
        if isReachable() {
            
            if headers != nil {
                header += headers!
            }
            
            //            if (endPoint == ADD_TO_CART_COMBO) || (endPoint == ADD_TO_CART) {
            //                baseURL = baseURLLocal
            //            }
            
            //            if (endPoint == PLACE_ORDER) {
            //                baseURL = baseURLLocal
            //            }
            let totalUrl = (baseURL + endPoint)
            PYLAPIManager.sharedManager.request(totalUrl, method: .post, parameters: parameters, encoding: parameterEncoding, headers: headers).validate().responseJSON(completionHandler: { (response) in
                
                guard response.result.isSuccess else {
                    failure(response.result.error as NSError?)
                    if (endPoint != GET_TAX) { ////ch - adarsh
                        self.showError(error: (response.result.error as NSError?)!)
                    }
                    //                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                if let value = response.result.value {
                    success(JSON(value))
                }
            })
            /*
            PYLAPIManager.sharedManager.request(.POST, baseURL + endPoint, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
                
                guard response.result.isSuccess else {
                    failure(error: response.result.error)
                    if (endPoint != GET_TAX) { ////ch - adarsh
                        self.showError(error: (response.result.error as NSError?)!)
                    }
                    //                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                if let value = response.result.value {
                    success(response: JSON(value))
                }
            }*/
        } else {
            debugPrint("No Network.")
            //            animateNoNetworkViewIfPresent()   //noNetwork animate
        }
    }
    
    /**
     GET REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    func getRequestJSON(_ endPoint: String, parameters:[String: AnyObject]?, headers:[String: String]?, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        defer {
            print("GET REQUEST for endpoint \(endPoint) successfully executed")
        }
        if isReachable() {
            debugPrint("show loader")
            DispatchQueue.main.async {
                PYLSpinner.show()
            }
            if headers != nil {
                header += headers!
            }
            //            if endPoint == GET_FOOD_CATAGORY{
            //                baseURL = baseURLLocal
            //            }
            
            let totalUrl = (baseURL + endPoint)
            PYLAPIManager.sharedManager.request(totalUrl, method: .get, parameters: parameters, encoding: parameterEncoding, headers: headers).validate().responseJSON(completionHandler: { (response) in
                debugPrint("hide loader")
                DispatchQueue.main.async( execute: {
                    PYLSpinner.hide()
                })
                guard response.result.isSuccess else {
                    failure(response.result.error as NSError?)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                
                if let value = response.result.value {
                    success(JSON(value))
                }
            })
            
                /*
            PYLAPIManager.sharedManager.request(.GET, baseURL + endPoint, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
                debugPrint("hide loader")
                dispatch_async(dispatch_get_main_queue()) {
                    PYLSpinner.hide()
                }
                guard response.result.isSuccess else {
                    failure(error: response.result.error)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                
                if let value = response.result.value {
                    success(response: JSON(value))
                }
            }*/
            
        } else {
            debugPrint("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
        }
    }
    
    /**
     PUT REQUEST
     
     - parameter endPoint:   to be appended to base url
     - parameter parameters: to be send to body
     - parameter headers:    to be send in request headers
     - parameter success:    callback on success
     - parameter failure:    callback on failure
     */
    func putRequestJSON(_ endPoint: String, parameters:[String: AnyObject]?, headers:[String: String]?, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ error: NSError?)->()) {
        defer {
            print("PUT REQUEST for endpoint \(endPoint) successfully executed")
        }
        if isReachable() {
            debugPrint("show loader")
            DispatchQueue.main.async {
                PYLSpinner.show()
            }
            if headers != nil {
                header += headers!
            }
            let totalUrl = (baseURL + endPoint)
            PYLAPIManager.sharedManager.request(totalUrl, method: .put, parameters: parameters, encoding: parameterEncoding, headers: headers).validate().responseJSON(completionHandler: { (response) in
                debugPrint("hide loader")
                
                DispatchQueue.main.async( execute: {
                    PYLSpinner.hide()
                })
                guard response.result.isSuccess else {
                    failure(response.result.error as NSError?)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
      
                if let value = response.result.value {
                    success(JSON(value))
                }
            })
                /*
            PYLAPIManager.sharedManager.request(.PUT, baseURL + endPoint, parameters: parameters, encoding: parameterEncoding, headers: header).validate().responseJSON { (response) in
                
                debugPrint("hide loader")
                
                dispatch_async(dispatch_get_main_queue()) {
                    PYLSpinner.hide()
                }
                guard response.result.isSuccess else {
                    failure(error: response.result.error)
                    self.showError(error: (response.result.error as NSError?)!)
                    return
                }
                
                
                
                if let value = response.result.value {
                    success(response: JSON(value))
                }
            }*/
        } else {
            debugPrint("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
        }
    }
    
    /*---------------------Uploading---------------------*/
    
    /**
     Uploading Without Multipart
     
     - parameter endPoint:      to be appended to base url
     - parameter headers:       to be send in request headers
     - parameter file:          file to be uploaded in binary format
     - parameter progressBlock: callback for progress updation
     - parameter success:       callback on success
     - parameter failure:       callback on failure
     */
    func uploadFile(_ endPoint: String, headers:[String: String]?, file: Data, progressBlock:@escaping (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ bytesExpectedToWrite: Int64) -> (),success:@escaping (_ response: AnyObject?)->(), failure:@escaping (_ error: NSError?) -> ()) {
        
        if isReachable() {
            if headers != nil {
                header += headers!
            }
            
            let totalUrl = (baseURL + endPoint)
            PYLAPIManager.sharedManager.uploadFile(totalUrl, headers: headers, file: file, progressBlock: { (bytesWritten, totalBytesWritten, bytesExpectedToWrite) in
                DispatchQueue.main.async(execute: {
                    progressBlock(bytesWritten, totalBytesWritten, bytesExpectedToWrite)
                })
            }, success: { (response) in
               success(response)
                
            }, failure: { (error) in
                failure(error)
            })
                /*
            PYLAPIManager.sharedManager.upload(.POST, baseURL + endPoint, headers: header, data: file).progress { (bytesWritten, totalBytesWritten, bytesExpectedToWrite) in
                DispatchQueue.main.async(execute: {
                    progressBlock(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, bytesExpectedToWrite: bytesExpectedToWrite)
                })
                }.validate().responseJSON { (response) in
                    guard response.result.isSuccess else {
                        failure(error: response.result.error)
                        return
                    }
                    if let value = response.result.value {
                        success(response: value)
                    }
            }*/
        } else {
            debugPrint("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
        }
    }
    
    /**
     Uploading using Multipart
     
     - parameter endPoint: to be appended to base url
     - parameter headers:  to be send in request headers
     - parameter file:     file to be uploaded in binary format
     - parameter fileName: file name to be set
     - parameter success:  callback on success
     - parameter failure:  callback on failure
     */
    func uploadFileMultipartFormData(_ endPoint: String, headers:[String: String]?, file:[Data]?, fileName:[String]?, success:(_ response: AnyObject) -> (), failure:(_ error: NSError?) -> ()){
        
        if isReachable() {
            if headers != nil {
                header += headers!
            }
            let totalUrl = (baseURL + endPoint)
            
            PYLAPIManager.sharedManager.upload(multipartFormData: { (MultipartFormData) in
                for (index, value) in (file?.enumerated())!{
                    MultipartFormData.append(value, withName: fileName![index], mimeType: "image/jpeg")
                }
            }, to: totalUrl, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    UIApplication.shared.windows.first?.showToastWithMessage(PROBLEM_OCCOURED)
                }
            })
            
            /*
            PYLAPIManager.sharedManager.upload(.POST, baseURL+endPoint, multipartFormData: { (MultipartFormData) in
                
                for (index, value) in (file?.enumerate())!{
                    MultipartFormData.appendBodyPart(data: value, name: fileName![index], mimeType: "image/jpeg")
                }
                
                }, encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        UIApplication.sharedApplication().windows.first?.showToastWithMessage(PROBLEM_OCCOURED)
                    }
            })*/
        } else {
            debugPrint("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
        }
    }
    
    /**
     Uploading using Multipart
     
     - parameter endPoint: to be appended to base url
     - parameter headers:  to be send in request headers
     - parameter file:     file to be uploaded in binary format
     - parameter fileName: file name to be set
     - parameter success:  callback on success
     - parameter failure:  callback on failure
     */
    func uploadFileMultipartFormDataWithParams(_ endPoint: String, headers:[String: String]?, file:Data?, fileName:String?, parameters:[String: AnyObject]?, success:@escaping (_ response: JSON?)->(), failure:@escaping (_ errorMsg: String)->()) {
        
        if isReachable() {
            if headers != nil {
                header += headers!
            }
            DispatchQueue.main.async {
                PYLSpinner.show()
            }
            let totalUrl = (baseURL + endPoint)
            PYLAPIManager.sharedManager.upload(multipartFormData: { (MultipartFormData) in
                
                MultipartFormData.append(file!, withName: "image_file", fileName: fileName!, mimeType: "image/png")
                
                if let params = parameters {
                    for (key, val) in params {
                        MultipartFormData.append(val.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, withName: key)
                    
                    }
                }
                
                
            }, usingThreshold: 20, to: totalUrl, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        DispatchQueue.main.async( execute: {
                            PYLSpinner.hide()
                        })
                        if let value = response.result.value {
                            success(JSON(value))
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    DispatchQueue.main.async( execute: {
                        PYLSpinner.hide()
                    })
                    failure("Failure")
                    UIApplication.shared.windows.first?.showToastWithMessage(PROBLEM_OCCOURED)
                    
                }
                
            })
            
            /*
            PYLAPIManager.sharedManager.upload(.POST, baseURL+endPoint, multipartFormData: { (MultipartFormData) in
                
                /*
                 // For Multiple Image with Image Name Upload
                 for (index, value) in (file?.enumerate())!{
                 MultipartFormData.appendBodyPart(data: value, name: fileName![index], mimeType: "image/jpeg")
                 }
                 */
                // Here image_file is the name of the folder where Image has been saved in the back end server. It should provide by the backend developer.
                MultipartFormData.appendBodyPart(data: file!, name: "image_file", fileName: fileName!, mimeType: "image/png")
                
                if let params = parameters {
                    for (key, val) in params {
                        MultipartFormData.appendBodyPart(data:val.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :key)
                    }
                }
                
            }, headers: header, encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            dispatch_async(dispatch_get_main_queue()) {
                                PYLSpinner.hide()
                            }
                            if let value = response.result.value {
                                success(response: JSON(value))
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        dispatch_async(dispatch_get_main_queue()) {
                            PYLSpinner.hide()
                        }
                        failure(errorMsg: "Failure")
                        UIApplication.sharedApplication().windows.first?.showToastWithMessage(PROBLEM_OCCOURED)
                        
                    }
            })*/
        } else {
            DispatchQueue.main.async {
                PYLSpinner.hide()
            }
            debugPrint("No Network.")
            failure("No Network.")
            //            UIApplication.sharedApplication().windows.first?.showToastWithMessage(NO_NETWORK)
        }
    }
    
    
    /*---------------------Downloading---------------------*/
    
    func showError(error: NSError) {
        if error.code == -1001 {
            UIApplication.shared.windows.first?.showToastWithMessage(error.localizedDescription)
        }else{
        //UIApplication.sharedApplication().keyWindow!.makeToast(String(htmlEncodedString: message), duration: 1.0, position: CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT-75))
        UIApplication.shared.windows.first?.showToastWithMessage(PROBLEM_OCCOURED)
        }
    }
}
