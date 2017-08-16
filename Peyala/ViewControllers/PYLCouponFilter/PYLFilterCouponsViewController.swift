//
//  PYLFilterCouponsViewController.swift
//  Peyala
//
//  Created by Adarsh on 03/04/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

let Default_DateRange_Text = "Select"

class PYLFilterCouponsViewController: PYLBaseViewController {

    @IBOutlet weak var tableViewFilter: UITableView!
    @IBOutlet weak var labelTblHeaderGrayBg: UILabel!
    @IBOutlet weak var labeltblFooterGrayBg: UILabel!
    @IBOutlet weak var labelTblHeaderCounter: UILabel!
    
    var countOfFilter: Int! {
        didSet{
            labelTblHeaderCounter.isHidden = !(countOfFilter > 0)
            labelTblHeaderCounter.text = "\(countOfFilter)"
        }
    }
    
    var arrSections:[[String:AnyObject]] = []
    var arrSectionsTemp:[[String]] = []  // it is the surrogate array whhich will be used just for expanding.collapsing logic. Its sub array will always contain less or equal no. of elements than subarrays of 'arrSections'.
    var previousSelectedSection = -1
    
    override func viewDidLoad() {
        self.setUpperNavigationItems()
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setUpperNavigationItems() {
        
        self.title = "Filter Coupons"
        self.backButtonEnabled = true
        self.notificationButtonEnabled = true
        self.cartButtonEnabled = true
    }

    func setupUI() {
        arrSections = [["name":"Section0" as AnyObject,"appliedFilter":"0" as AnyObject,"rows":[["type":"0","title":"Date Range","cellId":"ParentCell"],["type":"1","cellId":"PYLDateRangeCell","fromDate":Default_DateRange_Text,"toDate":Default_DateRange_Text]] as AnyObject],
                       ["name":"Section2" as AnyObject,"appliedFilter":"0" as AnyObject,"rows":[["type":"0","title":"Usage Status","cellId":"ParentCell"],["type":"1","cellId":"PYLSingleCheckboxCell","title":"Coupon un-used","isChecked":"0"],
                        ["type":"1","cellId":"PYLSingleCheckboxCell","title":"Coupon used","isChecked":"0"]] as AnyObject],
                       ["name":"Section3" as AnyObject,"appliedFilter":"0" as AnyObject,"rows":[["type":"1","title":"Gift Voucher","isChecked":"0","cellId":"ParentCell"],
                        ["type":"1","cellId":"PYLSingleCheckboxCell","title":"Bought Voucher","isChecked":"0"],["type":"1","cellId":"PYLSingleCheckboxCell","title":"Recieved Voucher","isChecked":"0"],
                        ["type":"1","cellId":"PYLSingleCheckboxCell","title":"Sent Voucher","isChecked":"0"]] as AnyObject],
                       ["name":"Section4" as AnyObject,"appliedFilter":"0" as AnyObject,"rows":[["type":"0","title":"Voucher Code","cellId":"ParentCell"],["type":"1","title":"","cellId":"ChildCell"],["type":"1","title":"","cellId":"ChildCell"]] as AnyObject]
        ]
        arrSectionsTemp = [[""],
                           [""],
                           [""],
                           [""]
        ]  // no. of rows should be same as of 'arrSections'
        self.tableViewFilter.reloadData()
        
        countOfFilter = 0
        labelTblHeaderCounter.isHidden = true
        
        labelTblHeaderGrayBg.layer.cornerRadius = 10.0
        labelTblHeaderGrayBg.layer.masksToBounds = true
        labelTblHeaderGrayBg.layer.borderWidth = 1.0
        labelTblHeaderGrayBg.layer.borderColor = UIColor.lightGray.cgColor
        
        labeltblFooterGrayBg.layer.cornerRadius = 10.0
        labeltblFooterGrayBg.layer.masksToBounds = true
        labeltblFooterGrayBg.layer.borderWidth = 1.0
        labeltblFooterGrayBg.layer.borderColor = UIColor.lightGray.cgColor
        
        labelTblHeaderCounter.layer.cornerRadius = labelTblHeaderCounter.frame.height/2
        labelTblHeaderCounter.layer.masksToBounds = true
        labelTblHeaderCounter.layer.borderWidth = 1.0
        labelTblHeaderCounter.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func calculateFilterLabelCount(_ section:Int, checkingKey: String) {
        var dictThisSection = arrSections[section] //'arrSections' will be used instead of 'arrSectionsTemp'.
        let arrRows = dictThisSection["rows"] as! [[String:String]]
        var flag = 0
        for i in 1..<arrRows.count {
            let dictRow = arrRows[i]
            switch checkingKey {
            case "isChecked":
                if dictRow["isChecked"] == "1" {
                    flag = 1
                    break
                }
            case "toDate":
                if dictRow["toDate"]! != Default_DateRange_Text {
                    flag = 1
                    break
                }
            default:
                break
            }
        }
        dictThisSection["appliedFilter"] = "\(flag)" as AnyObject?
        arrSections[section] = dictThisSection
        
        var count = 0
        for dictSection in arrSections {
            count = count + Int(dictSection["appliedFilter"] as! String)!
        }
       countOfFilter = count
    }
    
    func updateUIForSection(_ section: Int, isExpanding:Bool) {
        let cell = tableViewFilter.cellForRow(at: IndexPath(row: 0, section: section))
        let imageViewArrow = cell?.viewWithTag(ImageViewBaseTag+1) as! UIImageView
        let imageName = isExpanding ? "FoodItemsDownArrow" : "FoodItemsRightArrow"
        imageViewArrow.image = UIImage(named: imageName)
        
        //last section, first row (parent cell) separator issue solution.
        let lastSectionIndex = tableViewFilter.numberOfSections-1
        if (section == lastSectionIndex) {
            let labelSeparator = cell!.viewWithTag(LabelBaseTag+3) as! UILabel
            labelSeparator.isHidden = !isExpanding
        }
    }
    
    func insertRowsInSection(_ section: Int) {
        updateUIForSection(section, isExpanding: true)
        
        var arrInsertionIndexPath:[NSIndexPath] = []
        var arrTempSectionAtIndex = arrSectionsTemp[section]
        var i=1
        for _ in 1..<(arrSections[section]["rows"] as! [[String:String]]).count {
            arrTempSectionAtIndex.append("")
            arrInsertionIndexPath.append(IndexPath(row: i, section: section) as NSIndexPath)
            i+=1
        }
        arrSectionsTemp[section] = arrTempSectionAtIndex
        tableViewFilter.insertRows(at: arrInsertionIndexPath as [IndexPath], with: .fade)
    }
    
    func deleteRowsInSection(_ section: Int) {
        updateUIForSection(section, isExpanding: false)
        
        var arrDeletionIndexPath:[NSIndexPath] = []
        var arrTempSectionAtIndex = arrSectionsTemp[section]
        var i=1
        for _ in 1..<(arrSections[section]["rows"] as! [[String:String]]).count {
            arrTempSectionAtIndex.removeLast()
            arrDeletionIndexPath.append(IndexPath(row: i, section: section) as NSIndexPath)
            i+=1
        }
        arrSectionsTemp[section] = arrTempSectionAtIndex
        tableViewFilter.deleteRows(at: arrDeletionIndexPath as [IndexPath], with: .fade)
    }
}

extension PYLFilterCouponsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSectionsTemp.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  arrSectionsTemp[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellGlobal:UITableViewCell = UITableViewCell()
        var dictSection = arrSections[indexPath.section] //'arrSections' will be used instead of 'arrSectionsTemp'.
        var dictRow = (dictSection["rows"] as! [[String:String]])[indexPath.row]
        
        if indexPath.row == 0 {
            //means Parent cell (index no. 0 of any section)
            cellGlobal = tableView.dequeueReusableCell(withIdentifier: "ParentCell", for: indexPath as IndexPath)
            let lableTitle = cellGlobal.viewWithTag(LabelBaseTag+1) as! UILabel
            lableTitle.text = dictRow["title"]
            
            let imageViewArrow = cellGlobal.viewWithTag(ImageViewBaseTag+1) as! UIImageView
            let imageName = (arrSectionsTemp[indexPath.row].count > 1) ? "FoodItemsDownArrow" : "FoodItemsRightArrow"
            imageViewArrow.image = UIImage(named: imageName)
        }
        else {
            // other cells other than 0 index. These are cells of any section.
            switch dictRow["cellId"]!  {
            case "PYLDateRangeCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLDateRangeCell.self), for: indexPath as IndexPath) as! PYLDateRangeCell
                cell.datasource = dictRow as AnyObject!
                cell.dateBtnTapped = { (btn) in
                    
                    var minDate:String?, maxDate:String?
                    if(btn == cell.btnFromDate) {
                        minDate = nil
                        maxDate = "05 Apr 3000" // set it to 'nil' if want to set at current date.
                    } else {
                        guard cell.btnFromDate.titleLabel?.text! != Default_DateRange_Text else {
                            self.view.showToastWithMessage(SELECT_FROM_DATE)
                            return
                        }
                        minDate = cell.btnFromDate.titleLabel?.text!
                        maxDate = "05 Apr 3000" // set it to 'nil' if want to set at current date.
                    }
                    
                    let preSelect = (btn.titleLabel?.text! != Default_DateRange_Text) ? btn.titleLabel?.text! : ""
                    
//                    PYLPickerViewController.showPickerController(self, isDatePicker: true, pickerArray: [], position: .Bottom, pickerTitle: "", preSelected: btn.titleLabel!.text!, selected: { (value, index) in
                    PYLPickerViewController.showPickerController(self, isDatePicker: true, minDateStr: minDate, maxDateStr: maxDate, pickerArray: [], position: .bottom, pickerTitle: "", preSelected: preSelect!, selected: { (value, index) in
                    
                        if value != nil {
                            guard (value as! String).length > 0 else { return }
//                            btn.setTitle(value as? String, forState: UIControlState.Normal)
                            dictSection = self.arrSections[indexPath.section] //fetch again in these 2 lines, else will cause improper updating issue.
                            dictRow = (dictSection["rows"] as! [[String:String]])[indexPath.row]
                            
                            if(btn == cell.btnFromDate) {
                                dictRow["fromDate"] = value as? String
                            } else {
                                dictRow["toDate"] = value as? String
                            }
                            
                            var arrRows = dictSection["rows"] as! [[String:String]]
                            arrRows[indexPath.row] = dictRow
                            dictSection["rows"] = arrRows as AnyObject?
                            self.arrSections[indexPath.section] = dictSection
                            tableView.reloadRows(at: [indexPath as IndexPath], with: .none)
                            self.calculateFilterLabelCount(indexPath.section, checkingKey: "toDate")
                        }
                    })
                }
                cellGlobal = cell
                
            case "PYLSingleCheckboxCell":
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PYLSingleCheckboxCell.self), for: indexPath as IndexPath) as! PYLSingleCheckboxCell
                cell.datasource = dictRow as AnyObject!
                cell.checkBoxTapped = { (isChecked) in
                    dictSection = self.arrSections[indexPath.section] //fetch again in these 2 lines, else will cause improper updating issue.
                    dictRow = (dictSection["rows"] as! [[String:String]])[indexPath.row]
                    
                    dictRow["isChecked"] = isChecked ? "1" : "0"
                    var arrRows = dictSection["rows"] as! [[String:String]]
                    arrRows[indexPath.row] = dictRow
                    dictSection["rows"] = arrRows as AnyObject?
                    self.arrSections[indexPath.section] = dictSection
                    tableView.reloadRows(at: [indexPath as IndexPath], with: .none)
                    
                    self.calculateFilterLabelCount(indexPath.section, checkingKey: "isChecked")
                }
                cellGlobal = cell
                
            case "ChildCell":
                cellGlobal = tableView.dequeueReusableCell(withIdentifier: "ChildCell", for: indexPath as IndexPath)
                
            default:
                break
            }
        }
        
        let labelSeparator = cellGlobal.viewWithTag(LabelBaseTag+3) as! UILabel
        labelSeparator.isHidden = false
        let lastSectionIndex = tableView.numberOfSections-1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if (indexPath.row == lastRowIndex && indexPath.section == lastSectionIndex) {
            labelSeparator.isHidden = true
        }
        
        let lableSideBorders = cellGlobal.viewWithTag(LabelBaseTag+2) as! UILabel
        lableSideBorders.layer.borderWidth = 1.0
        lableSideBorders.layer.borderColor = UIColor.lightGray.cgColor
        return cellGlobal
    }
}

extension PYLFilterCouponsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            if previousSelectedSection != indexPath.section{
                if previousSelectedSection != -1 {
                    deleteRowsInSection(previousSelectedSection)
                }
                insertRowsInSection(indexPath.section)
                previousSelectedSection = indexPath.section
            }
            else {
                if previousSelectedSection != -1 {
                    deleteRowsInSection(previousSelectedSection)
                }
                previousSelectedSection = -1
            }
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//                tableView.reloadData()
//            }
        }else {
            
        }
    }
}

