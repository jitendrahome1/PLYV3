//
//  PYLInviteAndEarnViewController.swift
//  Peyala
//
//  Created by Adarsh on 14/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLInviteAndEarnViewController: PYLBaseViewController {
    
    // MARK: - Outlet Connections
    @IBOutlet weak var tableViewReferrals: UITableView!
    @IBOutlet weak var lblReferralCode: UILabel!
    
    var arrReferrals:[Dictionary<String,Any>] = []
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        loadDummyDataToTableView()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "Invite & Earn"
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func setupUI(){
        self.tableViewReferrals.estimatedRowHeight = 133
        self.tableViewReferrals.rowHeight = UITableViewAutomaticDimension
        lblReferralCode.text = "122448jWQ"
    }
    
    func loadDummyDataToTableView() {
        arrReferrals = [["email_id":"samirranjan@gmail.com" as AnyObject,"is_registered":"1" as AnyObject,"referred_date":"15/09/2014" as AnyObject,"reward_amount":"100" as AnyObject,"reward_credited_date":"18/09/2014" as AnyObject],
        ["email_id":"manishgoyal@gmail.com" as AnyObject,"is_registered":"0" as AnyObject,"referred_date":"15/09/2014" as AnyObject,"reward_amount":"200" as AnyObject,"reward_credited_date":"18/09/2014" as AnyObject],
        ["email_id":"shakibhassan@gmail.com" as AnyObject,"is_registered":"0" as AnyObject,"referred_date":"24/01/2015" as AnyObject,"reward_amount":"500" as AnyObject,"reward_credited_date":"30/01/2015" as AnyObject],
        ["email_id":"mirasingh@gmail.com" as AnyObject,"is_registered":"1" as AnyObject,"referred_date":"19/10/2014" as AnyObject,"reward_amount":"1000" as AnyObject,"reward_credited_date":"22/10/2014" as AnyObject],
        ["email_id":"vaishalipandey@gmail.com" as AnyObject,"is_registered":"1" as AnyObject,"referred_date":"28/02/2016" as AnyObject,"reward_amount":"300" as AnyObject,"reward_credited_date":"02/03/2016" as AnyObject],
        ["email_id":"chiranjibchatterjee@gmail.com" as AnyObject,"is_registered":"1" as AnyObject,"referred_date":"15/09/2014","reward_amount":"200","reward_credited_date":"18/09/2014"],
        ["email_id":"shabbirkumar@gmail.com","is_registered":"0","referred_date":"15/09/2014","reward_amount":"1000","reward_credited_date":"18/09/2014"],
        ["email_id":"hemasargaonkar@gmail.4b- com","is_registered":"0","referred_date":"16/09/2017","reward_amount":"500","reward_credited_date":"28/09/2017"]]
        tableViewReferrals.reloadData()
    }
    
    //MARK: - Actions
    @IBAction func inviteBtnAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        PYLInvitePopUpViewController.showInvitePopUp(self) { 
            sender.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func copyTextLongPressAction(_ sender: UILongPressGestureRecognizer) {
        guard sender.isEnabled else { return }  // 'enabled' property is not used as intended, its just used as a tag property. This guard therefore helps to stop double entry of control inside this function for a single long-press.
        UIPasteboard.general.string = lblReferralCode.text
        self.view.showToastWithMessage("\(COPIED_CLIPBOARD)")
        
        //rest part of the solution for the double entry of control issue.
        sender.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           sender.isEnabled = true
        }
       
    }
    
}

extension PYLInviteAndEarnViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReferrals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLReferralCell.self), for: indexPath) as! PYLReferralCell
        cell.datasource = arrReferrals[indexPath.row] as AnyObject!
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getViewFromNib("PYLMyOrderHeader", tag: 201, owner: self)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return IS_IPAD() ? 42.0 : 40.0
    }

}
extension PYLInviteAndEarnViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

