//
//  PYLPickerViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 19/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

public enum PickerPosition {
    case center
    case bottom
}

class PYLPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var pickerView: UIView!
    @IBOutlet var labelSetDate: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!
    var listPickerArray = [String]()
    var pickerSelected: ((_ value: AnyObject?, _ index: Int?) -> ())?
    var selectedValue: AnyObject!
    var selectedIndex: Int!
    var isDatePicker = false
    var preValue: String?
    var preIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:))))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal class func showPickerController(_ sourceViewController: UIViewController, isDatePicker: Bool, minDateStr:String? = nil, maxDateStr:String? = nil, pickerArray: [String], position: PickerPosition, pickerTitle: String, preSelected: String, selected: @escaping (_ value: AnyObject?, _ index: Int?) -> ()) {
        if !isDatePicker && pickerArray.count == 0 {
            sourceViewController.view.showToastWithMessage(NO_LISTING)
            return
        }
        let viewController = otherStoryboard.instantiateViewController(withIdentifier: String(describing: PYLPickerViewController.self)) as! PYLPickerViewController
        viewController.pickerSelected = selected
        viewController.isDatePicker = isDatePicker
        viewController.presentPickerWith(sourceViewController, isDatePicker: isDatePicker, minDateStr:minDateStr, maxDateStr:maxDateStr, pickerArray: pickerArray,position:position, pickerTitle: pickerTitle, preSelected: preSelected)
    }
    
//    func presentPickerWith(sourceController: UIViewController, isDatePicker: Bool, pickerArray: [String], position: PickerPosition, pickerTitle: String, preSelected: String) {
    func presentPickerWith(_ sourceController: UIViewController, isDatePicker: Bool, minDateStr:String? = nil, maxDateStr:String? = nil, pickerArray: [String], position: PickerPosition, pickerTitle: String, preSelected: String) {
        self.view.frame = UIScreen.main.bounds
        UIApplication.shared.windows.first!.addSubview(self.view)
        sourceController.addChildViewController(self)
        self.didMove(toParentViewController: sourceController)
        sourceController.view.bringSubview(toFront: self.view)
        pickerView.translatesAutoresizingMaskIntoConstraints = true
        labelSetDate.text = pickerTitle
        if isDatePicker {
            datePicker.isHidden = false
            listPicker.isHidden = true
            datePicker.maximumDate = Date()
            if let maxDate = maxDateStr {
                datePicker.maximumDate = maxDate.stringToDateWithCustomFormat("dd MMM yyyy")
            }
            if let minDate = minDateStr {
                datePicker.minimumDate = minDate.stringToDateWithCustomFormat("dd MMM yyyy")
            }
            if preSelected.length>0 {
                datePicker.date = preSelected.stringToDateWithCustomFormat("dd MMM yyyy")
            }

            selectedIndex = 0
            getDatePickerDate()
        } else {
            datePicker.isHidden = true
            listPicker.isHidden = false
            listPicker.delegate = self
            listPicker.dataSource = self
            listPickerArray.removeAll()
            listPickerArray = pickerArray
            selectedValue = listPickerArray[0] as AnyObject!
            selectedIndex = 0
        }
        if !isDatePicker {
            preValue = preSelected
            if pickerArray.contains(preSelected) {
                preIndex = pickerArray.index(of: preSelected)!
                selectedIndex = preIndex
                selectedValue = pickerArray[selectedIndex] as AnyObject
                listPicker.selectRow(pickerArray.index(of: preSelected)!, inComponent: 0, animated: false)
            }
        }
        if !IS_IPAD() {
            if position == .center {
                pickerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 50 , height: 200.0)
                pickerView.layer.cornerRadius = 10.0
                pickerView.layer.masksToBounds = true
            }else{
                pickerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 200.0)
            }
        }else{
            pickerView.layer.cornerRadius = 10.0
            pickerView.layer.masksToBounds = true
        }
        
        if IS_IPAD() {
            // show it in center incase of iPAD
            pickerView.center = CGPoint(x: self.view.frame.midX, y:self.view.frame.midY)
        } else {
            if position == .center {
                pickerView.center = CGPoint(x: self.view.frame.midX, y:self.view.frame.midY)
            }else if position == .bottom{
                pickerView.center = CGPoint(x: self.view.frame.midX, y: (SCREEN_HEIGHT - (pickerView.frame.height / 2)))
            }
        }
        
        presentAnimationToView()
    }
    
    // MARK: - Picker View Delegate & Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listPickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.white
        pickerLabel.font = UIFont(name: FONT_BOLD, size: IS_IPAD() ? 19 : 17)
        pickerLabel.text = listPickerArray[row]
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = listPickerArray[row] as AnyObject!
        let label = pickerView.view(forRow: row, forComponent: component) as? UILabel
        label!.font = UIFont(name: FONT_BOLD, size: IS_IPAD() ? 20 : 18)
        selectedIndex = row
    }
    
    // MARK: - Animation
    func presentAnimationToView() {
        pickerView.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.pickerView.transform = CGAffineTransform.identity
        }, completion: { (complete) in
        }) 
    }
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
        }) 
    }
    
    func getDatePickerDate() {
        selectedValue = datePicker.date.dateToStringWithCustomFormat("dd MMM yyyy") as AnyObject!
        labelSetDate.text = selectedValue as? String
    }
    
    // MARK: IBAction
    func didTap(_ gesture: UITapGestureRecognizer) {
        pickerSelected!(preValue as AnyObject?, preIndex)
        dismissAnimate()
    }
    
    @IBAction func dateSelectAction(_ sender: AnyObject) {
        pickerSelected!(selectedValue, selectedIndex)
        dismissAnimate()
    }
    
    @IBAction func datePickerAction(_ sender: AnyObject) {
        getDatePickerDate()
    }
}
