//
//  PYLCouponListViewController.swift
//  Peyala
//
//  Created by Adarsh on 30/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLCouponListViewController: PYLBaseViewController {
    @IBOutlet weak var tableViewCoupon: UITableView!
    
    var arrCoupons = [["":""]]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "My Peyala Coupon"
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func setupUI(){
        self.tableViewCoupon.estimatedRowHeight = 252.0
        self.tableViewCoupon.rowHeight = UITableViewAutomaticDimension
        arrCoupons = [["title":"Smoked Turkey","coupon_code":"12223YQRT","offer_valid":"5th May, 2017","image":"ServiceOptionBanner"],
                           ["title":"Roasted Chicken","coupon_code":"88423YQRT","offer_valid":"6th May, 2017","image":"ServiceOptionBanner"],
                           ["title":"Veg Salad Turkey","coupon_code":"VB8923YQRT","offer_valid":"7th May, 2017","image":"ServiceOptionBanner"],
                           ["title":"Hot Garlic","coupon_code":"41223YQRT","offer_valid":"8th May, 2017","image":"ServiceOptionBanner"],
                           ["title":"Cold Koffee","coupon_code":"538923YIPO","offer_valid":"9th May, 2017","image":"ServiceOptionBanner"]]
        self.tableViewCoupon.reloadData()
    }
    
    @IBAction func filterBtnAction(_ sender: UIButton) {
        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLFilterCouponsViewController.self))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension PYLCouponListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLCouponInfoCell.self), for: indexPath) as! PYLCouponInfoCell
        cell.datasource = arrCoupons[indexPath.row] as AnyObject!
        return cell
    }
}

extension PYLCouponListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = utilityStoryboard.instantiateViewController(withIdentifier: String(describing: PYLCouponDetailViewController.self))
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
}
