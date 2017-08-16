//
//  PYLFreqAskedQuestionViewController.swift
//  Peyala
//
//  Created by Soumen Das on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLFreqAskedQuestionViewController: PYLBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableFAQ: UITableView!
    
    var arrData:[Dictionary<String,String>] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        
        self.setUpperNavigationItems()
        super.viewDidLoad()
        
        tableFAQ.defaultSetup()
        
        if IS_IPAD() {
            tableFAQ.estimatedRowHeight = 70.0;
        } else {
            tableFAQ.estimatedRowHeight = 70.0;
        }
//        callFAQListApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callFAQListApi()
        trackScreenForAnalyticsWithName(FAQ_SCREEN, isGoogle: true, isFB: true)
    }
    
    override func viewDidLayoutSubviews() {
        tableFAQ.reloadData()
    }
    
    //MARK: - User Defined Function
    
    func setUpperNavigationItems() {
        
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
        self.menuButtonEnabled = true
        self.title = "FAQ"
    }
    
    //MARK: - API section
    
    func callFAQListApi()
    {
        PYLAPIHandler.handler.getFAQList({ (response) in
            self.successTaskFAQListApi(response!)
            }) { (error) in
                self.tableFAQ.showNodataLabelWithText(nil)
        }
    }
    
    func successTaskFAQListApi(_ response: JSON) {
        let tempArr = response["faq_details"].array
        tableFAQ.hideNoDataLabel()
        guard (tempArr?.count)! > 0 else {
            tableFAQ.showNodataLabelWithText(nil)
            return
        }
        
        for i in 0..<tempArr!.count {
            var dict = [String:String]()
            dict["faq_answer"] = tempArr![i]["faq_answer"].stringValue.getAESDecryption()
            dict["faq_id"] = tempArr![i]["faq_id"].stringValue.getAESDecryption()
            dict["faq_question"] = tempArr![i]["faq_question"].stringValue.getAESDecryption()
            arrData.append(dict)
        }
        tableFAQ.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.tableFAQ.reloadData()
        }
    }
    
    // MARK: - Table View DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: PYLFAQTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLFAQTableViewCell.self)) as! PYLFAQTableViewCell
        cell.datasource = arrData[indexPath.row] as AnyObject!
        cell.labelSeparator.isHidden = false
        let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
        if (indexPath.row == lastRowIndex - 1) {
            cell.labelSeparator.isHidden = true
        }
        return cell
    }
}
