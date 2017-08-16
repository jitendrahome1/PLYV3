
//
//  PYLDeliveryAddressVC.swift
//  Peyala
//
//  Created by Pradip Paul on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLDeliveryAddressVC: PYLBaseViewController {

    //MARK:- Outlet Connections
    @IBOutlet weak var buttonExistingAddress: UIButton!
    @IBOutlet weak var buttonNewAddress: UIButton!
    @IBOutlet weak var container: UIView!
    //MARK:- Variables
    weak var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PYLNewAddressVC")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        //container.addSubview(self.currentViewController!.view)
        //self.addSubview(self.currentViewController!.view, toView: container)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func cycleFromViewController(_ oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:container!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParentViewController()
                                    newViewController.didMove(toParentViewController: self)
        })
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Button Actions

    @IBAction func onAddressSelection(_ sender: UIButton!) {
        buttonNewAddress.isSelected = false
        buttonExistingAddress.isSelected = false
        sender.isSelected = true
        if buttonNewAddress.isSelected {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "PYLNewAddressVC")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        } else {
            let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "PYLExistingAddressVC")
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }
    }
   
}
