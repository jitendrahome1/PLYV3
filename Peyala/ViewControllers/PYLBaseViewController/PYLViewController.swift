//
//  PYLViewController.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLViewController: PYLBaseViewController {
    let arr = ["","djh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionLogin(_ sender: AnyObject) {
        
//        NSUserDefaults.standardUserDefaults().setValue("1", forKey: USER_DEFAULT_USER_LOGIN_KEY)
        
    }
    @IBAction func actionLogout(_ sender: AnyObject) {
        
//        NSUserDefaults.standardUserDefaults().setValue("0", forKey: USER_DEFAULT_USER_LOGIN_KEY)
        
        let transition = CATransition();
        transition.duration = 0.3;
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut);
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        self.view.window!.layer.add(transition, forKey: nil);
        
        let rootViewController  = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        UIApplication.shared.windows.first!.rootViewController = rootViewController
        
        PYLNavigationHelper.helper.navigationController = rootViewController
        
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
