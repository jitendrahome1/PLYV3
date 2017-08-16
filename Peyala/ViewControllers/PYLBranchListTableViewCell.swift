//
//  PYLBranchListTableViewCell.swift
//  Peyala
//
//  Created by Soumen Das on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLBranchListTableViewCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var branchTitle: UILabel!
    @IBOutlet weak var branchAddress: UILabel!
    @IBOutlet weak var branchPhoneNo: UILabel!
    @IBOutlet weak var labelBranchOperatingTime: UILabel!
    @IBOutlet weak var buttonPhone: UIButton!
    @IBOutlet weak var buttonLocation: UIButton!
    @IBOutlet weak var labelSeparator: UILabel!
    
    var showMapOnTap:((_ latitude:String?, _ longitude:String?, _ name: String?,_ address: String?)->())!
    var callOnTap:((_ mobileNumber:String?)->())!
    var name:String?
    var latitude:String?
    var longitude:String?
    var address:String?
    
    override var datasource :AnyObject! {
        
        didSet {
            
            if let name = datasource["branch_name"] as? String {
                branchTitle.text = name.getAESDecryption()
            }else{
                branchTitle.text = "N/A"
            }
            if let address = datasource["branch_address"] as? String {
                branchAddress.text = address.getAESDecryption()
            }else{
                branchAddress.text = "N/A"
            }
            if let mobile = datasource["branch_mobile"] as? String {
                branchPhoneNo.text = "Call: " + mobile.getAESDecryption()
            }else{
                branchPhoneNo.text = "Call: " + "N/A"
            }
//            var branchStartTime = String.getSafeString(datasource["branch_start_time"]).getAESDecryption()
//            branchStartTime = branchStartTime.isEmpty ? "N/A" : branchStartTime
//            var branchEndTime = String.getSafeString(datasource["branch_end_time"]).getAESDecryption()
//            branchEndTime = branchEndTime.isEmpty ? "N/A" : branchEndTime
//            labelBranchOperatingTime.text = "Operation Time: \(branchStartTime) - \(branchEndTime)"
            
            var branchOrderStartTime = String.getSafeString(datasource["branch_order_start_time"] as! String as AnyObject?).getAESDecryption()
            branchOrderStartTime = branchOrderStartTime.isEmpty ? "N/A" : branchOrderStartTime
            var branchOrderEndTime = String.getSafeString(datasource["branch_order_end_time"] as! String as AnyObject?).getAESDecryption()
            branchOrderEndTime = branchOrderEndTime.isEmpty ? "N/A" : branchOrderEndTime
            labelBranchOperatingTime.text = "Operation Time: \(branchOrderStartTime) - \(branchOrderEndTime)"
        }
    }
    
    @IBAction func buttonGoToMapAction(_ sender: AnyObject) {
        
        if let lat = datasource["branch_latitude"] as? String {
            latitude = lat.getAESDecryption()
        }else{
            return
        }
        if let lng = datasource["branch_longitude"] as? String {
            longitude = lng.getAESDecryption()
        }else{
            return
        }
        if let name = datasource["branch_name"] as? String {
            self.name = name.getAESDecryption()
        }else{
            self.name = "N/A"
        }
        if let addr = datasource["branch_address"] as? String {
            address = addr.getAESDecryption()
        }else{
            address = "N/A"
        }
        
        self.showMapOnTap(self.latitude!,self.longitude!,self.name!,self.address!)
    }
    
    @IBAction func buttonCallAction(_ sender: AnyObject) {
        if let phone = datasource["branch_mobile"] as? String {
            self.callOnTap(phone.getAESDecryption())
        }else{
            return
        }
    }
}
