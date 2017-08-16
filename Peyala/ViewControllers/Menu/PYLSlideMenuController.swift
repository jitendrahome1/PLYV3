//
//  PYLSlideMenuController.swift
//  Peyala
//
//  Created by Chinmay Das on 01/08/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class PYLSlideMenuController: SlideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SlideMenuOptions.leftViewWidth = IS_IPAD() ? 400.0 : 270.0
        SlideMenuOptions.contentViewScale = 1
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
