//
//  PYLContactUsViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import GoogleMaps
import MessageUI

class PYLContactUsViewController: PYLBaseViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

    //MARK: - Outlet Collection
    
    
    var mapData = [AnyObject]()

    @IBOutlet weak var contactUsMapView: GMSMapView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var contactUsTable: UITableView!
    
    var contactUsData = [String:AnyObject]()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        self.setUpperNavigationItems()
        super.viewDidLoad()
        innerView.layer.cornerRadius = 5.0
        innerView.clipsToBounds = true
        innerView.layer.borderWidth = 0.5
        innerView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        if mapData.count == 0 {
            let requiredData = [[
                "branch_address" : "Gulshan Avenue, Gulshan 2 DCC Super Market, 1212 Dhaka, Bangladesh",
                "branch_longitude" : "90.415332",
                "branch_name" : "Peyala Cafe Coffee Shop" ,
                "branch_latitude" :"23.793587"
                ]]
            
            mapData = requiredData as [AnyObject]
        }
        
        //test //TODO
        if self.mapData.count == 1 {
            let pinPosition = CLLocationCoordinate2D(latitude: (((self.mapData[0] as! [String:AnyObject])["branch_latitude"] as? String)?.toDouble())!, longitude: (((self.mapData[0] as! [String:AnyObject])["branch_longitude"] as? String)?.toDouble())!)
            let position = pinPosition
            let pinmarker = GMSMarker(position: position)
            pinmarker.title = ((self.mapData[0] as! [String:AnyObject])["branch_name"] as? String)
            pinmarker.snippet =  ((self.mapData[0] as! [String:AnyObject])["branch_address"] as? String)
            pinmarker.groundAnchor = CGPoint(x: 0.5,y: 0.5)
//            pinmarker.icon = UIImage(named: "OrderConfirmationPeyalaLocation")
            pinmarker.icon = UIImage(named: "OrderConfirmationLocationIcon")
            pinmarker.map = self.contactUsMapView
            let camera = GMSCameraPosition.camera(withLatitude: pinPosition.latitude, longitude: pinPosition.longitude, zoom: 15.0)
            self.contactUsMapView.camera = camera
            
        }else{
            self.setMultipleAnnotations()
        }
        contactUsMapView.isMyLocationEnabled = true
        PYLAPIHandler.handler.getContactUsDetails({ (response) in
            self.contactUsData = response!.dictionaryObject! as [String : AnyObject]
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)){
              self.contactUsTable.reloadData()
            }
            }) { (error) in
                
        }
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(CONTACT_US_SCREEN, isGoogle: true, isFB: true)
    }

    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.searchButtonEnabled = false
        self.menuButtonEnabled = true
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.title = "CONTACT US"
    }
    
    
    func setMultipleAnnotations() {
        
        for (index) in 0..<mapData.count {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(index+1) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                
                let pinPosition = CLLocationCoordinate2D(latitude: (((self.mapData[index] as! [String:AnyObject])["branch_latitude"] as? String)?.toDouble())!, longitude: (((self.mapData[index] as! [String:AnyObject])["branch_longitude"] as? String)?.toDouble())!)
                let position = pinPosition
                let pinmarker = GMSMarker(position: position)
                pinmarker.title = ((self.mapData[index] as! [String:AnyObject])["branch_name"] as? String)
                pinmarker.snippet = ((self.mapData[index] as! [String:AnyObject])["branch_address"] as? String)
                pinmarker.groundAnchor = CGPoint(x: 0,y: 0)
                pinmarker.icon = UIImage(named: "OrderConfirmationPeyalaLocation")
                //pinmarker.icon = UIImage(named: "OrderConfirmationLocationIcon")
                pinmarker.map = self.contactUsMapView
            }
        }
    }
    

    // MARK: - Table View DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactUsData.count > 0 ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellGlobal = UITableViewCell()
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            if let addressLabel = cell.contentView.viewWithTag(2) as? UILabel{
            addressLabel.text = (contactUsData["address"] as! String).getAESDecryption()
            }
            cellGlobal = cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneNoCell", for: indexPath)
            if let phoneLabel = cell.contentView.viewWithTag(2) as? UILabel{
                var phoneNo = ""
                let arrphonenumbers:[[String:AnyObject]] = contactUsData["phone_list"] as! Array
                for item in arrphonenumbers {
                    phoneNo = phoneNo + (item["phone_number"] as! String).getAESDecryption() + "\n"
                }
                phoneLabel.text = phoneNo
            }
            cellGlobal = cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            if let emailsLabel = cell.contentView.viewWithTag(2) as? UILabel{
                var emails = ""
                for item:[String:AnyObject] in (contactUsData["email_list"] as! Array) {
                    emails = emails + (item["email_id"] as! String).getAESDecryption() + "\n"
                }
                emailsLabel.text = emails
            }
            cellGlobal = cell
        default:
            break
        }
        
        cellGlobal.contentView.setNeedsLayout()
        return cellGlobal
    }
    
    // MARK: - Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

       return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
      return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let arrphonenumbers:[[String:AnyObject]] = contactUsData["phone_list"] as! Array
            let phoneNo = (arrphonenumbers[0]["phone_number"] as! String).getAESDecryption()
            let url = URL(string: "telprompt://" + phoneNo)
            if url != nil{
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(url!)) {
                    application.openURL(url!);
                }else{
                    self.view.showToastWithMessage("Not available")
                }
            }
        }
        if indexPath.section == 2 {
            
            let arrphonenumbers:[[String:AnyObject]] = contactUsData["email_list"] as! Array
            let emailID = (arrphonenumbers[0]["email_id"] as! String).getAESDecryption()
            
            let mailComposeViewController = configuredMailComposeViewController(recipient: emailID)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController(recipient: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([recipient])
        //mailComposerVC.setSubject("Sending you an in-app e-mail...")
        //mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PYLContactUsViewController : GMSMapViewDelegate {
}
