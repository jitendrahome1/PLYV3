//
//  PYLNotificationTableViewCell.swift
//  Peyala
//
//  Created by Soumen Das on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
enum readStatus:String {
    case read = "READ"
    case unread = "UNREAD"
}
class PYLNotificationTableViewCell: PYLBaseTableViewCell {
  
    @IBOutlet weak var titleNotification: UILabel!
    @IBOutlet weak var titleDescription: UILabel!
    @IBOutlet weak var buttonDate: UIButton!
    @IBOutlet weak var labelSeparator: UILabel!
    
    let ReadStatus : readStatus = .unread
    override var datasource: AnyObject! {
        
        didSet {
            //if let title = datasource["notification_title"] as? String {
            //    titleNotification.text = title
            //}
            titleNotification.text = ""
            if let description = datasource["notification_desc"] as? String {
                titleDescription.text = description
            }
            if let dateStr = datasource["notification_time"] as? String {
                buttonDate.setTitle(dateStr, for: UIControlState())
            }
            if let readStatus = datasource["notification_read_status"] as? String {
                if readStatus == "READ" {
                    self.backgroundColor = UIColor.groupTableViewBackground
                    //self.isUserInteractionEnabled = false
                }
                if readStatus == "UNREAD" {
                    self.backgroundColor = UIColor.clear
                    //self.isUserInteractionEnabled = true
                }

            }
        }
    }
    
   
}

