//
//  PYLMyPeyalaCashProfileViewController.swift
//  Peyala
//
//  Created by Adarsh on 17/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLMyPeyalaCashProfileViewController: PYLBaseViewController {
    
    @IBOutlet weak var btnLoadPeyalaCash: UIButton!
    @IBOutlet weak var btnMyTransaction: UIButton!
    @IBOutlet weak var tableViewMenu: UITableView!
    var arrMenu = [["":""]]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        initializeValues()
        setupUI()
    }

    func setUpperNavigationItems() {
        
        self.title = "My Peyala Cash"
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func initializeValues() {
        arrMenu = [["title":"Autoload Peyala Cash","imagename":"MyPeyalaCashAutoloadCashIcon"],
        ["title":"Recharge/top up your mobile","imagename":"MyPeyalaCashRechargeIcon"],
        ["title":"Pay Mobile Bill","imagename":"MyPeyalaCashPayMobileBillIcon"],
        ["title":"Pay at Store","imagename":"MyPeyalaCashPayAtStoreIcon"],
        ["title":"Transfer to your friends","imagename":"MyPeyalaCashInviteFriendsIcon"],
        ["title":"Pay at other Restaurants","imagename":"MyPeyalaCashPayAtRestaurantIcon"],
        ["title":"Send Gift Voucher to your friends","imagename":"MyPeyalaCashSendGiftVoucherIcon"]]
    }
    
    func setupUI(){
        self.tableViewMenu.estimatedRowHeight = 67
        self.tableViewMenu.rowHeight = UITableViewAutomaticDimension
        btnLoadPeyalaCash.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        btnMyTransaction.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    @IBAction func loadPeyalaCashBtnAction(_ sender: UIButton) {
        //PYLAddPeyalaCashViewController
        let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLAddPeyalaCashViewController.self)) as! PYLAddPeyalaCashViewController
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func myTransactionsBtnAction(_ sender: UIButton) {
        //PYLMyTransactionsViewController
        let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLMyTransactionsViewController.self)) as! PYLMyTransactionsViewController
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PYLMyPeyalaCashProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selectedDict = arrMenu[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PYLCashMenu", for: indexPath)
        let imgViewIcon = cell.viewWithTag(ImageViewBaseTag+1) as! UIImageView
        imgViewIcon.image = UIImage(named: selectedDict["imagename"]!)
        
        let lblTitle = cell.viewWithTag(LabelBaseTag+1) as! UILabel
        lblTitle.text = selectedDict["title"]!
        
//        let labelSeparator = cell.viewWithTag(LabelBaseTag+2) as! UILabel
//        labelSeparator.isHidden = false
//        let lastRowIndex = tableView.numberOfRowsInSection(tableView.numberOfSections-1) - 1
//        if (indexPath.row == lastRowIndex) {
//            labelSeparator.isHidden = true
//        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}
extension PYLMyPeyalaCashProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==1) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLRechargeMobileViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else if(indexPath.row==2) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLRechargeMobileViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else if(indexPath.row==3) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLPayAtStoreViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else if(indexPath.row==4) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLCreateGiftVoucherViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else if(indexPath.row==5) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLPayAtRestaurantsViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else if(indexPath.row==6) {
            let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLCreateGiftVoucherViewController.self))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
