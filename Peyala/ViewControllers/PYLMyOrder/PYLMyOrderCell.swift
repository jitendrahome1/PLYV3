//
//  PYLMyOrderCell.swift
//  Peyala
//
//  Created by Pradip Paul on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLMyOrderCell: PYLBaseTableViewCell {
    
    //MARK:- Outlet Connections
    @IBOutlet weak var labelorderID: UILabel!
    @IBOutlet weak var labelorderDescription: UILabel!
    @IBOutlet weak var labelorderAmount: UILabel!
    @IBOutlet weak var imageStatus: UIImageView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var btnReorder: UIButton!
    
    var reorderCompletion:((_ orderID: String)->())!
    override var datasource: AnyObject! {
        
        didSet {
            if let orderID = datasource["order_id"] as? String {
                labelorderID.text = "Order ID : " + orderID.getAESDecryption()
            }else{
                labelorderID.text = "N/A"
            }
            if let description = datasource["order_date"] as? String {
                labelorderDescription.text = "Date: " + description.getAESDecryption()
            }else{
                labelorderDescription.text = "N/A"
            }
            if let ammount = datasource["total_price"] as? String {
                labelorderAmount.text = "Amount: " + ammount.getAESDecryption() + " Taka"
            }else{
                labelorderAmount.text = "Amount: " + "N/A"
            }
            if let orderStatus = datasource["order_status"] as? String {
                labelStatus.text = orderStatus.getAESDecryption().replacingOccurrences(of: "_", with: " ")
            }else{
                labelStatus.text = "N/A"
            }
        }
    }
    
    @IBAction func btnReorderTapped(_ sender: AnyObject) {
        if let orderID = datasource["order_id"] as? String {
            reorderCompletion(orderID)
        }else{
            
            return
        }
        
       
    }
}
