////
//  PYLBranchLocatorMapViewController.swift
//  Peyala
//
//  Created by Soumen Das on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import GoogleMaps

class PYLBranchLocatorMapViewController: PYLBaseViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Outlet Collection
    
    
    
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var branchMap: GMSMapView!
    
    //    var mapData: AnyObject?
    //    var arrBranchList : [AnyObject]!
    
    var mapData =  [AnyObject]()
    var allBranchPinListArray:NSArray = []
    var filteredData = [AnyObject]()
    var selectedData = [String]()
    var searchText = ""
    var currentPageNo = 1
    var pageCount = 10
    let nearbyRadius = 5.0
    var moreDataAvailable:Bool = false
    var originCoordinate = CLLocation(latitude: 0.0, longitude: 0.0)
    
    @IBOutlet weak var branchMapPin: UIButton!
    
    
    @IBOutlet weak var branchDeatilsTable: UITableView!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        textFieldLocation.delegate = self
        textFieldLocation.isUserInteractionEnabled = true
        branchMap.delegate = self
        branchDeatilsTable.delegate = self
        branchDeatilsTable.dataSource = self
        
        //test //TODO
        if mapData.count == 0 {
            let requiredData = [[
                "branch_address" : "Oxley Rd at Graceville State School, stop 50, Graceville QLD 4075, Australia",
                "branch_longitude" : "152.9792375625",
                "branch_name" : "Peyala Australia 1",
                "branch_latitude" : "-27.5179117553343"
                ]]
            
            mapData = requiredData as [AnyObject]
        }
        
        //test //TODO
        if self.mapData.count == 1 {
            textFieldLocation.text = ((self.mapData[0] as! [String:AnyObject])["branch_address"] as? String)
        }else{
            //   self.setMultipleAnnotations()
        }
        branchMap.isMyLocationEnabled = true
        branchMap.isUserInteractionEnabled = true
        let brownViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 1.0))
        brownViewFooter.backgroundColor = .clear
        branchDeatilsTable.tableFooterView = brownViewFooter
        branchDeatilsTable.backgroundColor = .clear
        branchDeatilsTable.isHidden = true
        debugPrint(JSON(allBranchPinListArray))
        self.view.isUserInteractionEnabled = true
        originCoordinate = CLLocation(latitude: Double(((self.mapData[0] as! [String:AnyObject])["branch_latitude"] as! String))!, longitude: Double(((self.mapData[0] as! [String:String])["branch_longitude"])!)!)
        nearbyMultipleAnnotation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(BRANCH_MAPVIEW_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    func reloadTableForSearchText() {
        if (searchText.length>0){
            branchDeatilsTable.isHidden = false
            filteredData = self.allBranchPinListArray.filter({ (dict) -> Bool in
                let branchName = ((dict as! [String:String])["branch_name"])!.getAESDecryption()
                let branchAddress = ((dict as! [String:String])["branch_address"])!.getAESDecryption()
                if branchName.lowercased().contains(searchText.lowercased()) || branchAddress.lowercased().contains(searchText.lowercased()) {
                    return true
                } else{
                    return false
                }
            }) as [AnyObject]
        }
        else {
            filteredData = []
            branchDeatilsTable.isHidden = true
        }
        branchDeatilsTable.reloadData()
    }
    
    //MARK: - Button Pin Action Function
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //delegate method
        textField.resignFirstResponder()
        //showPinForAddress()
        return true
    }
    
    
    //MARK: - TextField Delegates for filtering datas
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if (range.length == 0){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.insert(string, at: range.location)
            searchText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.deleteCharacters(in: range)
            searchText = stringNew as String
        }
        reloadTableForSearchText()
        // btnPinAction(searchText as AnyObject)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
    }
    
    
    //MARK: - Button Pin Action Function
    
    //    func textFieldShouldReturn(textField: UITextField) -> Bool {
    //        //delegate method
    //        textField.resignFirstResponder()
    //        showPinForAddress()
    //        return true
    //    }
    
    @IBAction func btnPinAction(_ sender: AnyObject)
    {
        
        showPinForAddress()
        self.view.endEditing(true)
    }
    
    
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.searchButtonEnabled = false
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.title = "BRANCH MAPVIEW"
    }
    
    //MARK: - Tableview Delegates and datasource
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = branchDeatilsTable.dequeueReusableCell(withIdentifier: "PYLAnnotationCell", for: indexPath)
        let datasource = filteredData[indexPath.row] as! [String:AnyObject]
        let labelName = cell.viewWithTag(LabelTag + 2) as! UILabel
        let labelAddress = cell.viewWithTag(LabelTag + 4) as! UILabel
        if let branchName = datasource["branch_name"] as? String  {
            labelName.text = branchName.getAESDecryption()
        }
        if let branchAddress =  datasource["branch_address"] as? String {
            labelAddress.text = branchAddress.getAESDecryption()
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        originCoordinate = CLLocation(latitude: Double((self.filteredData[indexPath.row]["branch_latitude"] as! String).getAESDecryption())!, longitude: Double((self.filteredData[indexPath.row]["branch_longitude"] as! String).getAESDecryption())!)
        branchMap.clear()
        nearbyMultipleAnnotation()
        self.textFieldLocation.text = (self.filteredData[indexPath.row]["branch_address"] as? String)!.getAESDecryption()
        branchDeatilsTable.isHidden = true
        
        self.view.endEditing(true)
    }
    
    
    func showPinForAddress()
    {
        
        let address = String(format: "\(textFieldLocation.text!)")
        print(address)
        let geocoder = CLGeocoder()
        
        //branchMapPin.enabled = false
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                //self.view.showToastWithMessage(LOCATION_PIN_ADDRESS)
                return
            }
            //            if let placemark = placemarks?.first {
            //                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
            //                debugPrint(coordinates)
            //                self.nearbyMultipleAnnotation()
            //            }
        })
        //branchMapPin.enabled = true
        
    }
    
    func nearbyMultipleAnnotation()
    {
        
        let arrFrom = allBranchPinListArray as [AnyObject]
        let camera = GMSCameraPosition.camera(withLatitude: originCoordinate.coordinate.latitude, longitude:
            originCoordinate.coordinate.longitude, zoom:15)
        branchMap.camera = camera
        let path = GMSMutablePath()
        for (indx) in 0..<arrFrom.count
            
        {
            let pinPosition = CLLocationCoordinate2D(latitude: ((arrFrom[indx] as! [String:AnyObject]) ["branch_latitude"] as! String).getAESDecryption().toDouble()!,longitude: ((arrFrom[indx] as! [String:AnyObject])["branch_longitude"] as! String).getAESDecryption().toDouble()!)
            let destination = CLLocation.init(latitude:pinPosition.latitude, longitude:pinPosition.longitude )
            let distanceFromCurrentLocation:CLLocationDistance = destination.distance( from: originCoordinate)/1000.0 as Double!
            
            if distanceFromCurrentLocation <= nearbyRadius
            {
                debugPrint(distanceFromCurrentLocation)
                let position = pinPosition
                let pinmarker = GMSMarker(position: position)
                pinmarker.title = (arrFrom[indx]["branch_name"] as? String)!.getAESDecryption()
                pinmarker.snippet = (arrFrom[indx]["branch_address"] as? String)!.getAESDecryption()
                pinmarker.icon = distanceFromCurrentLocation == 0.0 ? UIImage(named: "OrderConfirmationPeyalaLocation") : UIImage(named: "OrderConfirmationPeyalaLocation")
                pinmarker.map = self.branchMap
                //pinmarker.appearAnimation = GMSMarkerAnimation
                
                
                if distanceFromCurrentLocation == 0.0 {
                    branchMap.selectedMarker = pinmarker
                }
            }
            
        }
        
        let bounds = GMSCoordinateBounds(path: path)
        self.branchMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 10.0))
        //self.view.endEditing(true)
    }
    
}


/*
 func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
 
 if !(annotation is MKPointAnnotation) {
 return nil
 }
 var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("viewIdentifier")
 if annotationView == nil {
 annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "viewIdentifier")
 annotationView!.canShowCallout = true
 }
 else {
 annotationView!.annotation = annotation
 }
 annotationView!.image = UIImage(named: "OrderConfirmationPeyalaLocation")
 
 return annotationView
 }
 */


extension PYLBranchLocatorMapViewController : GMSMapViewDelegate {
}


