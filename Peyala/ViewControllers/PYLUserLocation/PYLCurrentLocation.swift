//
//  PYLCurrentLocation.swift
//  Peyala
//
//  Created by Adarsh on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import MapKit

class PYLCurrentLocation: NSObject,CLLocationManagerDelegate {
    
    var successFetching:((_ latitude: Double, _ longitude: Double)->())!
    var failureFetching:((_ message:String)->())!
    var isLocationProvided = false
    let locationManager = CLLocationManager()
    
    static let sharedInstance: PYLCurrentLocation = {
        let obj = PYLCurrentLocation()
        return obj
    }()
    
    override init() {
        super.init()
        
        //mandatory settings to be done
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self;
    }
    
    //Call this method from outside to fetch current location
    func fetchCurrentUserLocation(onSuccess success:@escaping (_ latitude: Double, _ longitude: Double)->(), failure:@escaping (_ message:String)->()) {
        successFetching = success
        failureFetching = failure
        isLocationProvided = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .denied: //NotDetermined, .Restricted
                 failureFetching(LOCATION_DISABLED)
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            default:
                break
            }
        } else {
            failureFetching(LOCATION_DISABLED)
        }

        /*
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        else{
            failureFetching(message: LOCATION_DISABLED)
        }
        */
    }
}

extension PYLCurrentLocation {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isLocationProvided else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        let userLocation:CLLocation = locations.last! // Get the user location in CLLocation object
        successFetching(userLocation.coordinate.latitude,userLocation.coordinate.longitude)
        isLocationProvided = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failureFetching(LOCATION_FETCH_FAILED)
        
    }
}
