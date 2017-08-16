//
//  PYLMyTransactionsViewController.swift
//  Peyala
//
//  Created by Adarsh on 20/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLMyTransactionsViewController: PYLBaseViewController {

    @IBOutlet weak var tableViewTransaction: UITableView!
    
    var arrTransactions = [["":""]]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        loadDummyDataToTableView()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "My Transactions"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func setupUI(){
        self.tableViewTransaction.estimatedRowHeight = 133
        self.tableViewTransaction.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadDummyDataToTableView() {
        arrTransactions = [["order_id":"77612222155","date":"15/09/2014","type":"Invite & Earn","debit":"100","credit":"500","image":"OrderReadyTwo"],
                        ["transaction_id":"99612222150","date":"16/09/2014","type":"Purchase","debit":"100","credit":"500","image":"OrderReadyTwo"],["order_id":"77612222155","date":"17/09/2014","type":"Invite & Earn","debit":"100","credit":"500","image":"OrderReadyTwo"],
                        ["order_id":"77612222155","date":"18/09/2014","type":"Invite & Earn","credit":"500","image":"OrderReadyTwo"],
                        ["transaction_id":"77612222155","date":"19/09/2014","type":"Load Cash","debit":"100","image":"OrderReadyTwo"],
                        ["transaction_id":"77612222155","date":"20/09/2014","type":"Recieved Cash","debit":"100","credit":"500","image":"OrderReadyTwo"],
                        ["order_id":"77612222155","date":"21/09/2014","type":"Gift Voucher","credit":"500","image":"OrderReadyTwo"]
        ]
        tableViewTransaction.reloadData()
    }
}

extension PYLMyTransactionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLTransactionCell.self), for: indexPath) as! PYLTransactionCell
        cell.datasource = arrTransactions[indexPath.row] as AnyObject!
        cell.labelSeparator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1) - 1
        if (indexPath.row == lastRowIndex) {
            cell.labelSeparator.isHidden = true
        }
        return cell
    }
    
}
extension PYLMyTransactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
