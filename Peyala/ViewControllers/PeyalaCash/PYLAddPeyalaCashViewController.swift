//
//  PYLAddPeyalaCashViewController.swift
//  Peyala
//
//  Created by Adarsh on 21/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

class PYLAddPeyalaCashViewController: PYLBaseViewController {
    
    
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var txtFieldAmount: UITextField!
    @IBOutlet weak var btnAddMoney: UIButton!
    @IBOutlet weak var collectionViewMoney: UICollectionView!
    var arrMoney = [""]
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        initializeValues()
        setupUI()
    }
    
    func setUpperNavigationItems() {
        
        self.title = "Add Peyala Cash"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }
    
    func initializeValues() {
        arrMoney = ["599","799","999","1999","1599","2599","3599"]
    }
    
    func setupUI(){
        txtFieldAmount.showToolBar()
    }
    
    //MARK: Actions
    @IBAction func addMoneyBtnAction(_ sender: UIButton) {
        
    }
}

extension PYLAddPeyalaCashViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMoney.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoneyCollectionCell", for: indexPath)
        let btnMoney = cell.viewWithTag(ButtonBaseTag+1) as! UIButton
        btnMoney.setTitle(arrMoney[indexPath.row], for: .normal)
        btnMoney.layer.borderColor = DEFAULT_COLOR.cgColor
        return cell
    }
}

extension PYLAddPeyalaCashViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = SCREEN_WIDTH > 320 ? collectionView.frame.width/3.0 : collectionView.frame.width/2.0
        let height = width/3.0
        let size = CGSize(width:width, height:height)
        
        debugPrint(size)
        return size
    }
}

extension PYLAddPeyalaCashViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        txtFieldAmount.text = arrMoney[indexPath.row]
    }
}

extension PYLAddPeyalaCashViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var strText = String()
        if (range.length == 0){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.insert(string, at: range.location)
            strText = stringNew as String
        }
        else if(range.length == 1){
            let stringNew = NSMutableString(string: textField.text!)
            stringNew.deleteCharacters(in: range)
            strText = stringNew as String
        }
        if(strText.length > MAX_PHONE_NO_LIMIT || !strText.isNumber) {return false}
        return true
    }
    
}





