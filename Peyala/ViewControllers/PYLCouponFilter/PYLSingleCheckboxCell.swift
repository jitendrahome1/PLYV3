//
//  PYLSingleCheckboxCell.swift
//  Peyala
//
//  Created by Adarsh on 03/04/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLSingleCheckboxCell: PYLBaseTableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnCheckbox: UIButton!
    
    var checkBoxTapped:((_ isChecked: Bool)->())!
    override var datasource: AnyObject! {
        didSet{
            let dictSource = datasource as! [String:String]
            //TODO: decrypt all the dictionary fetched things once you fetch the api data's.
            labelTitle.text = dictSource["title"]
            let isChecked = (dictSource["isChecked"] == "0") ? false : true
            btnCheckbox.isSelected = isChecked
            
            btnCheckbox.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    
    //MARK: Actions
    @IBAction func buttonCheckboxAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if checkBoxTapped != nil {
            checkBoxTapped(sender.isSelected)
        }
    }
}
