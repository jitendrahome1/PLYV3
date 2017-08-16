//
//  PYLCouponDetailViewController.swift
//  Peyala
//
//  Created by Adarsh on 30/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLCouponDetailViewController: PYLBaseViewController {

    @IBOutlet weak var tableViewCoupon: UITableView!
    
    var arrCouponDetail = [["":""]]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "My Peyala Coupon"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func setupUI(){
        self.tableViewCoupon.estimatedRowHeight = 69
        self.tableViewCoupon.rowHeight = UITableViewAutomaticDimension
        arrCouponDetail = [["title":"Coupon/Voucher Code","value":"12223YQRT"],
                           ["title":"Coupon/Voucher Type","value":"Regular"],
                           ["title":"Date of Receiving","value":"18/09/2016"],
                           ["title":"Usage Status","value":"Availed"],
                           ["title":"Usage Date","value":"22/10/2016"]]
        self.tableViewCoupon.reloadData()
    }
}

extension PYLCouponDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCouponDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = arrCouponDetail[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath)
        let lblTitle = cell.viewWithTag(LabelBaseTag+1) as! UILabel
        lblTitle.text = dataSource["title"]
        
        let lblDesc = cell.viewWithTag(LabelBaseTag+2) as! UILabel
        lblDesc.text = dataSource["value"]
        
        let labelSeparator = cell.viewWithTag(LabelBaseTag+3) as! UILabel
        labelSeparator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1) - 1
        if (indexPath.row == lastRowIndex) {
            labelSeparator.isHidden = true
        }

        cell.backgroundColor = UIColor.clear
        return cell
    }
}

