//
//  PYLNotificationEnableCell.swift
//  Peyala
//
//  Created by Adarsh on 09/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLNotificationEnableCell: PYLBaseTableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonSwitch: UIButton!
    
    var notificationTapped:((_ enable:Bool)->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["attribute":"Notification","value":"1","cellId":String(PYLNotificationEnableCell)]
            labelTitle.text = (datasource as! Dictionary<String,AnyObject>)["attribute"] as? String
            buttonSwitch.isSelected = (((datasource as! Dictionary<String,AnyObject>)["value"] as? String) == "1") ? true : false
        }
    }
    
    @IBAction func buttonSwitchAction(_ sender: UIButton) {
//        buttonSwitch.selected = !buttonSwitch.selected
        if notificationTapped != nil {
            notificationTapped(buttonSwitch.isSelected)
        }
    }
    
}
