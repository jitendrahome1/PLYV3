//
//  PYLOrderConfirmationViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import GoogleMaps

class PYLOrderConfirmationViewController: PYLBaseViewController {
    
    //MARK:- Outlet Connections
    @IBOutlet weak var mapOrder: GMSMapView!
    @IBOutlet weak var labelOrderId: UILabel!
    @IBOutlet weak var labelCafeDetails: UILabel!
    @IBOutlet weak var buttonViewOrderDetails: UIButton!
    
    var orderDetails : JSON!
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        labelOrderId.text = "Order ID: \(PYLHelper.helper.placedOrderID)"
        SET_CART_BADGE("\(0)")
        labelCafeDetails.text = "\(orderDetails["branch_name"].stringValue.getAESDecryption()), \(orderDetails["branch_address"].stringValue.getAESDecryption()) will serve you shortly."
        let branchLat = orderDetails["branch_latitude"].stringValue.getAESDecryption()
        let branchLong = orderDetails["branch_longitude"].stringValue.getAESDecryption()
        
        let pinPosition = CLLocationCoordinate2D(latitude:branchLat.toDouble()!, longitude:branchLong.toDouble()!)
        let position = pinPosition
        let pinmarker = GMSMarker(position: position)
        pinmarker.title = orderDetails["branch_name"].stringValue.getAESDecryption()
        pinmarker.snippet = orderDetails["branch_address"].stringValue.getAESDecryption()
        let boldText:String  = pinmarker.title!
        let attributedString = NSMutableAttributedString(string:boldText)
        let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
        let boldString = NSMutableAttributedString(string:boldText, attributes:attrs)
        attributedString.append(boldString)
        //Add more attributes here
        
        //Apply to the label
        // pinmarker.title = myMutableString as? String
        pinmarker.icon = UIImage(named: "OrderConfirmationPeyalaLocation")
        pinmarker.map = self.mapOrder
        let camera = GMSCameraPosition.camera(withLatitude: pinPosition.latitude, longitude: pinPosition.longitude, zoom: 15.0)
        self.mapOrder.camera = camera
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Defined Function

    func setUpperNavigationItems() {
        
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = true
        self.backButtonEnabled = false
        self.title = "ORDER CONFIRMATION"
    }
    
    //MARK:- Button Actions
    @IBAction func viewOrderDetailsAction(_ sender: UIButton!) {
        
        self.navigateToOrderDetailsWithOrder(PYLHelper.helper.placedOrderID)
    }
    
    func navigateToOrderDetailsWithOrder(_ orderID:String) {
        
        let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLOrderDetailsViewController.self)) as! PYLOrderDetailsViewController
        viewController.orderID = orderID
        PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
    }
    
    @IBAction func trackOrderDetailsAction(_ sender: UIButton!) {
        debugPrint("Track your order tapped")
        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLTrackOrderViewController.self)) as! PYLTrackOrderViewController
        viewController.orderID = PYLHelper.helper.placedOrderID
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
}
