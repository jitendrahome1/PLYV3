//
//  PYLPayAtStoreViewController.swift
//  Peyala
//
//  Created by Adarsh on 28/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLPayAtStoreViewController: PYLBaseViewController {

    @IBOutlet weak var btnQrCode: UIButton!
    @IBOutlet weak var lblDecodedText: UILabel!
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "Pay at Store"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }

    
    @IBAction func qrCodeBtnAction(_ sender: UIButton) {
        PYLQRCodeViewController.showQrCodeScannerPopUp(self, dissmiss: { 
            //just the screen dismissed with no decoding.
            }) { (strDecoded) in
                //After successful decode
                self.lblDecodedText.text = strDecoded
        }
    }

}
