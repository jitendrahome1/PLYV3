//
//  PYLPayAtRestaurantsViewController.swift
//  Peyala
//
//  Created by Adarsh on 27/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLPayAtRestaurantsViewController: PYLBaseViewController {
    
    @IBOutlet weak var tableViewRestaurants: UITableView!
    
    var arrRestaurants = [["":""]]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        loadDummyDataToTableView()
    }
    
    func setUpperNavigationItems() {
        self.title = "Pay at other Restaurants"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func setupUI(){
        self.tableViewRestaurants.estimatedRowHeight =  159
        self.tableViewRestaurants.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadDummyDataToTableView() {
        arrRestaurants = [["rest_name":"Peter Cat","rest_id":"111222","merchant_id":"999827","image":"OrderReadyTwo","address":"243 C, Kol"],
                           ["rest_name":"Kentucky Fried Chicken","rest_id":"111222","merchant_id":"999828","image":"OrderReadyTwo","address":"243 C, Southcity Mall, Prince Anwarsha Road, Tollygunge, Kolkata - 700541"],
                           ["rest_name":"Annapurna","rest_id":"222333","merchant_id":"999829","image":"OrderReadyTwo","address":"243 C, Southcity Mall, Prince Anwarsha Road, Tollygunge, Kolkata - 700541"],
                           ["rest_name":"Arsalan","rest_id":"333444","merchant_id":"999821","image":"OrderReadyTwo","address":"243 C, Southcity Mall, Prince Anwarsha Road, Tollygunge, Kolkata - 700541, West Bengal, India"],
                           ["rest_name":"Jaisalmer","rest_id":"444555","merchant_id":"999822","image":"OrderReadyTwo","address":"Southcity Mall, Prince Anwarsha Road"],
                           ["rest_name":"Ocean Grill","rest_id":"555666","merchant_id":"999823","image":"OrderReadyTwo","address":"243 C, Southcity Mall, Prince Anwarsha Road, Tollygunge, Kolkata - 700541"]
        ]
        tableViewRestaurants.reloadData()
    }
}

extension PYLPayAtRestaurantsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLRestaurantCell.self), for: indexPath as IndexPath) as! PYLRestaurantCell
        cell.datasource = arrRestaurants[indexPath.row] as AnyObject!
        cell.labelSeparator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1) - 1
        if (indexPath.row == lastRowIndex) {
            cell.labelSeparator.isHidden = true
        }
        
        return cell
    }
    
}
extension PYLPayAtRestaurantsViewController: UITableViewDelegate {
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLPaySingleRestaurantViewController.self)) as! PYLPaySingleRestaurantViewController
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        viewController.selectedRestaurantDict = arrRestaurants[indexPath.row]
        PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
