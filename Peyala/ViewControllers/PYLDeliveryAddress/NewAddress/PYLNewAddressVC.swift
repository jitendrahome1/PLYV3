//
//  PYLNewAddressVC.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLNewAddressVC: UITableViewController {

    //MARK:- Outlet Connections
    
    @IBOutlet weak var textViewAddress: UITextView!
    override func viewDidLoad() {
        textViewAddress.layer.borderColor = UIColor.gray.cgColor
        textViewAddress.layer.borderWidth = 1.0
        textViewAddress.layer.cornerRadius = 2.0
        textViewAddress.layer.masksToBounds = true
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return IS_IPAD() ? 150 : 100
        }
        return IS_IPAD() ? 70 : 55
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
