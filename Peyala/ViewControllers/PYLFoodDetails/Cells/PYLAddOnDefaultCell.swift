//
//  PYLAddOnDefaultCell.swift
//  Peyala
//
//  Created by Adarsh on 28/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLAddOnDefaultCell: PYLBaseTableViewCell {

    @IBOutlet weak var buttonCheckbox: UIButton!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var constraintCurveViewBottom: NSLayoutConstraint!
    
    var checkBoxTapped:((_ isChecked: Bool)->())!
    override var datasource: AnyObject! {
        didSet{
            //            ["addOnName":"Add-On 1","addOnPrice":"50","addOnQuantity":"1","checked":"0"]
            labelName.text = (datasource as! Dictionary<String,AnyObject>)["addon_name"] as? String
            // got crash in below line -> Sequence -> after cart clear add wrap item -> add combo item.
            // this crash should be handled
            if Int(datasource["maxLimit"] as! String)! >= (datasource["seletedItems"] as? Int)!
            {
                // got crash
            buttonCheckbox.isSelected = ((datasource as! Dictionary<String,AnyObject>)["checked"] as? String) == "1" ? true : false
            }
          
        }
    }
    
    //MARK: Actions
    @IBAction func buttonCheckboxAction(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected
        let seleted = !sender.isSelected
        if checkBoxTapped != nil {
            checkBoxTapped(seleted)
        }
        
    }
}
