//
//  PYLDateRangeCell.swift
//  Peyala
//
//  Created by Adarsh on 03/04/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLDateRangeCell: PYLBaseTableViewCell {

    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!

    var dateBtnTapped:((_ btn: UIButton)->())!
    override var datasource: AnyObject! {
        didSet{
            let dictSource = datasource as! [String:String]
            //TODO: decrypt all the dictionary fetched things once you fetch the api data's.
            btnFromDate.setTitle(dictSource["fromDate"], for: UIControlState.normal)
            btnToDate.setTitle(dictSource["toDate"], for: UIControlState.normal)
            
            btnFromDate.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            btnToDate.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            
            btnFromDate.imageEdgeInsets = UIEdgeInsetsMake(0, IS_IPAD() ? 100 : 90, 0, 0)
            btnToDate.imageEdgeInsets = UIEdgeInsetsMake(0, IS_IPAD() ? 100 : 90, 0, 0)
        }
    }
    
    //MARK: Actions
    @IBAction func dateBtnAction(_ sender: UIButton) {
//        sender.selected = !sender.selected
        if dateBtnTapped != nil {
            dateBtnTapped(sender)
        }
    }
}
