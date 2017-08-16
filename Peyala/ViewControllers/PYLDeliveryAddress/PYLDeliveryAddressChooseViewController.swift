//
//  PYLDeliveryAddressChooseViewController.swift
//  Peyala
//
//  Created by Adarsh on 13/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLDeliveryAddressChooseViewController: PYLBaseViewController {
    
    @IBOutlet weak var buttonCurrentLocation: UIButton!
    @IBOutlet weak var buttonOtherLocation: UIButton!
    @IBOutlet weak var innerView: UIView!
    
    override func viewDidLoad() {
        
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        innerView.layer.borderWidth = 0.5
        innerView.layer.borderColor = UIColor.lightGray.cgColor
        innerView.layer.cornerRadius = 5
        
        if !IS_IPAD() {
            buttonCurrentLocation.titleEdgeInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0)
            buttonOtherLocation.titleEdgeInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 0.0)
        }
    }
    
    // MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = false
        self.backButtonEnabled = true
        self.title = "DELIVERY ADDRESS"
    }
    
    //MARK: - Button Action
    
    @IBAction func chooseBtnAction(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            
            if sender == buttonCurrentLocation {
                buttonOtherLocation.isSelected = false
            }
            else {
                buttonCurrentLocation.isSelected = false
            }
        }
        //never touch the below statements, to change anything-change above codes
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "segueCurrentAddress") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view //
            let VC = segue.destination as! PYLDeliveryAddressMapViewController
            VC.shouldSaveAddInDirectory = "0"
        }
    }
}
