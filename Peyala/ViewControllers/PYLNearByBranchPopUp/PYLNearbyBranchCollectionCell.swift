//
//  PYLNearbyBranchCollectionCell.swift
//  Peyala
//
//  Created by Adarsh on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLNearbyBranchCollectionCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBOutlet weak var labelBranchName: UILabel!
    @IBOutlet weak var labelBranchAddress: UILabel!
    @IBOutlet weak var labelBranchContactNo: UILabel!
    
    var checkUncheckAction:((_ checkStatus:String?)->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["checked":"0","branchName":"Peyala Cafe cofee Shop","branchAddress":"abc def, qwert, jhdgd dhgdhf aaaa, aahdddhd\n sjsjsww kkffjhsw","contact":"+91 8777777756"]
            buttonCheckbox.isSelected = ((datasource["checked"] as? String) == "0") ? false : true
//            labelBranchName.text = (datasource as! Dictionary<String,AnyObject>)["branchName"] as? String
//            labelBranchAddress.text = (datasource as! Dictionary<String,AnyObject>)["branchAddress"] as? String
//            labelBranchContactNo.text = (datasource as! Dictionary<String,AnyObject>)["contact"] as? String
            if let name = datasource["branch_name"] as? String {
                labelBranchName.text = name.getAESDecryption()
            }else{
                labelBranchName.text = "N/A"
            }
            if let address = datasource["branch_address"] as? String {
                labelBranchAddress.text = address.getAESDecryption()
            }else{
                labelBranchAddress.text = "N/A"
            }
            if let mobile = datasource["branch_mobile"] as? String {
                labelBranchContactNo.text = mobile.getAESDecryption()
            }else{
                labelBranchContactNo.text = "N/A"
            }
            
        }
    }
    
    @IBAction func checkboxBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if checkUncheckAction != nil {
            checkUncheckAction(sender.isSelected ? "1" : "0")
        }
    }
    
}
