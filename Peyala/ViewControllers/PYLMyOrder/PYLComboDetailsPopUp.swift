//
//  PYLComboDetailsPopUp.swift
//  Peyala
//
//  Created by Pradip Paul on 26/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLComboDetailsPopUp: PYLBaseViewController {
    
    var combos = [Any]()
    var dissmissPopUpAction:(()->())!
    var sourceViewController: UIViewController?
    
    @IBOutlet weak var tableComboDetails: UITableView!
    @IBOutlet weak var viewCenter: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableComboDetails.rowHeight = UITableViewAutomaticDimension
        tableComboDetails.estimatedRowHeight = 100
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - User Defined Functiom
    internal class func showComboDetailsPopUp(_ sourceController: UIViewController, comboItems:AnyObject, dissmiss:@escaping ()->()) {
        
        let viewController = servicesStoryboard.instantiateViewController(withIdentifier: "PYLComboDetailsPopUp") as! PYLComboDetailsPopUp
        viewController.sourceViewController = sourceController
        viewController.dissmissPopUpAction = dissmiss
        viewController.combos = (comboItems as! NSArray) as! [Any]
        viewController.presentPopUP(sourceController)
    }
    
    func presentPopUP(_ sourceController: UIViewController) {
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimateWithCompletion(_ completion:@escaping ()->()) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            completion()
        }) 
    }
    
    //Button Action
    @IBAction func backGroundButtonPressed(_ sender: AnyObject) {
    }
    @IBAction func crossButtonPressed(_ sender: AnyObject) {
        dismissAnimateWithCompletion {
            if self.dissmissPopUpAction != nil {
                self.dissmissPopUpAction()
            }
       }
    }
}

extension PYLComboDetailsPopUp: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return combos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLOrderDetailsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLOrderDetailsCell.self)+"Combo") as! PYLOrderDetailsCell
        cell.datasource = combos[indexPath.row] as AnyObject!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Table View Delegate Methods
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
}

