//
//  Extensions.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import Foundation
import UIKit
fileprivate let minimumHitArea = CGSize(width: 50, height: 50)

extension Array where Element : Equatable {
    
    mutating func removeObject(_ object : Element){
        if let index = self.index(of: object){
            self.remove(at: index)
        }
    }
    
    mutating func removeObjects(_ objectArray : [Element]){
        for object in objectArray {
            self.removeObject(object)
        }
    }
}

class PYLButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isExclusiveTouch = true
    }
}

class PYLButtonForHitTest: UIButton {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.tag == 101 {
            let errorMargin: CGFloat = 20.0
            let largerFrame = CGRect(x: 0 - errorMargin, y: 0 - errorMargin, width: self.frame.width + (errorMargin * 2.0), height:  self.frame.height + (errorMargin * 2.0))
            return (largerFrame.contains(point) == true) ? self : nil;
        }else {
            return self
        }
    }
}

extension UIButton {
    func imageTitleCenteringwithSpacing(_ Spacing:CGFloat) {
        let insetAmount = Spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
 
//    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        // if the button is hidden/disabled/transparent it can't be hit
//        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01{ return nil }
//        // if the button tag is not 101 not need to increase the tapable area
//        else if self.tag != 101 { return self }
//        
//        debugPrint("self.tag -- \(self.tag)")
//        // increase the hit frame to be at least as big as `minimumHitArea`
//        let buttonSize = self.bounds.size
//        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
//        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
//        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
//        
//        // perform hit test on larger frame
//        return (largerFrame.contains(point)) ? self : nil
//    }
    
//    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
//        let margin: CGFloat = 10
//        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
//        return area.contains(point)
//    }
}
//MARK: Label
extension UILabel {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let fontType = self.font.fontName.components(separatedBy: "-").last
        switch fontType! {
        case "Regular":
            
            self.font = UIFont(name: self.tag  == 599 ? FONT_REGULAR_CASH : FONT_REGULAR, size: self.font.pointSize)
            break
        case "Semibold":
          self.font = UIFont(name: self.tag  == 599 ? FONT_SEMI_CASH : FONT_SEMI_BOLD, size: self.font.pointSize)
            break
        case "Medium":
            self.font = UIFont(name: FONT_SEMI_BOLD, size: self.font.pointSize)
            break
        case "Bold":
            self.font = UIFont(name:self.tag  == 599 ? FONT_REGULAR_BOLD_CASH : FONT_BOLD, size: self.font.pointSize)
            break
        default:
            break
        }
    }
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
    
    func roundedLabel() {
        let maxVal = max(self.frame.height,  self.frame.width)
        var labelrect = self.frame
        labelrect.size.height = maxVal + 3
        labelrect.size.width = maxVal + 3
        self.frame = labelrect
        self.layer.cornerRadius =  max(self.frame.height/2.0,  self.frame.width/2.0)
        self.layer.masksToBounds = true
    }
}

//Mark: Array
extension Array where Element : Comparable {
    
    mutating func removeObject(_ object : Element){
        if let index = self.index(of: object){
            self.remove(at: index)
        }
    }
    
    mutating func removeObjects(_ objectArray : [Element])
    {
        for object in objectArray {
            self.removeObject(object)
        }
    }
}

extension Array {
    
    func containsObject(_ type: AnyClass) -> (isPresent: Bool, index: Int?){
        for (index,item) in self.enumerated() {
            if (item as AnyObject).isKind(of: type) {
                return (true, index)
            }
        }
        return (false, nil)
    }
}
extension UIImage{
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UITableView {
    
    func defaultSetup(){
        self.estimatedRowHeight = 100;
        self.rowHeight = UITableViewAutomaticDimension;
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
    }
    
    func showNodataLabelWithText(_ text:String!) {
        hideNoDataLabel()
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 40)
        label.text = text ?? "No data found"
        label.tag = 111
        label.font = UIFont(name: FONT_REGULAR, size: IS_IPAD() ? 28 : 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.center = CGPoint(x: self.frame.width/2.0, y: self.tag == peyalaCashTableViewTag ? (self.frame.height/2.0 + 80) : self.frame.height/2.0)
        self.addSubview(label)
    }
    
    func hideNoDataLabel() {
        for _views in self.subviews as [UIView] {
            if let labelView = _views as? UILabel {
                if labelView.tag == 111 {
                    labelView.isHidden = true
                    labelView.removeFromSuperview()
                    break
                }
            }
        }
    }
}

//MARK: UIView

extension UIView {
    func showToastWithMessage(_ message: String) {
        if message.length > 0 {
            UIApplication.shared.keyWindow!.makeToast(message, duration: 1.0, position: CGPoint(x: SCREEN_WIDTH/2.0, y: 100.0))
        }
    }
    
    func showToastWithMessage(_ message: String, delayTime: Double) {
        if message.length > 0 {
            UIApplication.shared.keyWindow!.makeToast(message, duration: delayTime, position: CGPoint(x: SCREEN_WIDTH/2.0, y: 100.0))
        }
    }
    
    func blinkAnimate(forTimes count:Int) {
        guard count != 0 else {return}
        let timeHalfBlink = 0.1
        UIView.animate(withDuration: timeHalfBlink, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
        }) { (success) in
            UIView.animate(withDuration: timeHalfBlink, delay: 0.0, options: .curveEaseOut, animations: {
                self.alpha = 1.0
            }) { (success) in
                self.blinkAnimate(forTimes: count - 1)
            }
        }
    }
}

extension UIView {
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    /*
    func roundView(_ corners: UIRectCorner, radius: CGFloat) {
        _round(corners, radius: radius)
    }
    */
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func roundedView(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners, radius: radius)
        addBorder(mask, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    /**
     Fully rounds an autolayout view (e.g. one with no known frame) with the given diameter and border
     
     - parameter diameter:    The view's diameter
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func fullyRound(_ diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
    
}

private extension UIView {
    
    func _round(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(_ mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
}

//ViewController
extension UIViewController {
    var className: String {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
}
//MARK: UIAlertController

extension UIAlertController {
    
    public class func showStandardAlertWith(_ title: String, alertText: String, cancelTitle:String, doneTitle:String, selected_: @escaping (_ index: Int)->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: alertText, preferredStyle: .alert)
        alert.view.tintColor = DEFAULT_COLOR
        let cancelAction = UIAlertAction(title: (cancelTitle == "" ? CANCEL : cancelTitle), style: .cancel) { (action) in
            selected_(0)
        }
        alert.addAction(cancelAction)
        let doneAction = UIAlertAction(title: (doneTitle == "" ? OK : doneTitle), style: .default) { (action) in
            selected_(1)
        }
        alert.addAction(doneAction)
        return alert
    }
    
    public class func showSimpleAlertWith(_ title: String, alertText: String, selected_: @escaping (_ index: Int)->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: alertText, preferredStyle: .alert)
        alert.view.tintColor = DEFAULT_COLOR
        
        let doneAction = UIAlertAction(title: OK, style: .default) { (action) in
            selected_(0)
        }
        alert.addAction(doneAction)
        return alert
    }
    
    
    public class func showStandardActionSheetWith(_ title: String, messageText: String, arrayButtons: [String], selectedIndex:@escaping (_ index: Int)->()) -> UIAlertController {
        let actionSheet = UIAlertController(title: title, message: messageText, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) { (action) in
            
        }
        actionSheet.addAction(cancelAction)
        for (index, item) in arrayButtons.enumerated() {
            let buttonAction = UIAlertAction(title: item, style: .default, handler: { (action) in
                selectedIndex(index)
            })
            actionSheet.addAction(buttonAction)
        }
        return actionSheet
    }
    
    public class func showStandardActionSheetOrPopOverWith(_ title: String, messageText: String, tuplePopOver:(sourceView: UIView,sourceRect: CGRect, arrowIsUp: Bool), arrayButtons: [String], selectedIndex:@escaping (_ index: Int)->()) -> UIAlertController {
        let actionSheet = UIAlertController(title: title, message: messageText, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) { (action) in
            
        }
        actionSheet.addAction(cancelAction)
        for (index, item) in arrayButtons.enumerated() {
            let buttonAction = UIAlertAction(title: item, style: .default, handler: { (action) in
                selectedIndex(index)
            })
            actionSheet.addAction(buttonAction)
        }
        
        if IS_IPAD() {
            actionSheet.popoverPresentationController?.sourceView = tuplePopOver.sourceView
            actionSheet.popoverPresentationController?.sourceRect = tuplePopOver.sourceRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = tuplePopOver.arrowIsUp ? .up : .down
        }
        
        return actionSheet
    }
    
    public class func showStandardAlertWithTextField(_ title: String, alertText: String, selected_: @escaping (_ index: Int, _ email: String)->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: alertText, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter email"
            textField.keyboardType = .emailAddress
        }
        alert.view.tintColor = DEFAULT_COLOR
        let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) { (action) in
            selected_(0, "")
        }
        alert.addAction(cancelAction)
        let doneAction = UIAlertAction(title: OK, style: .default) { (action) in
            selected_(1, alert.textFields![0].text!)
        }
        alert.addAction(doneAction)
        return alert
    }
}

//MARK: -  NSDate
extension Date{
    func dateToStringWithCustomFormat (_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
    
    
}

//MARK:- UITextField

extension UITextField{
    
    func showToolBar() {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UITextField.cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UITextField.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        self.inputAccessoryView = numberToolbar
    }
    func hideToolBar() {
        self.inputAccessoryView = nil
    }
    
    func doneWithNumberPad() {
        self.resignFirstResponder()
    }
    
    func cancelNumberPad() {
        self.text = ""
        self.resignFirstResponder()
    }
    
    func modifyClearButtonWithImage(_ image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: UIControlState())
        clearButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(UITextField.clear(_:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }
    
    func clear(_ sender : AnyObject) {
        self.text = ""
    }
}

extension UIApplication {
    
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}


//MARK: - String
extension String{
    
    public func toFloat() -> Float? {
        return Float.init(self)
    }
    
    public func toInt() -> Int? {
        return Int.init(self)
    }
    
    public func toDouble() -> Double? {
        return Double.init(self == "" ? "0" : self)
    }
    
    
    public func toDoubleWithRoundOfUpToTwoDecimal() -> Double? {
        guard self.length > 0 else {
            return 0.00
        }
        let x = Double.init(self)
        let y = Double(round(100*x!)/100)
        return y;
    }
    
    public func toStringWithRoundOfUpToTwoDecimal() -> String? {
        guard self.length > 0 else {
            return ("0.00")
        }
        let x = Double.init(self)
        let y = Double(round(100*x!)/100)
        return (String(format: "%.2f", y))
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func stringToDateWithCustomFormat(_ format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return dateFormatter.date(from: self)!
    }
    
    func dateToLong(_ date:Date) -> Double {
        let timeInSeconds : TimeInterval  = date.timeIntervalSince1970
        return timeInSeconds
    }
    
    func StringToLongDate(_ format :String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return "\(Int64(dateToLong(dateFormatter.date(from: self)!)))"
        
    }
    
    func ConvertDateToFormat(_ format :String, fromFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        //dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        var date = dateFormatter.date(from: self)
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            date = dateFormatter.date(from: self)
        }
        dateFormatter.dateFormat = format
        return "\(dateFormatter.string(from: date!))"
    }
    
    func LongDateStringToDateString(_ format: String) -> String {
        
        let date = Date(timeIntervalSince1970:self.toDouble()!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return "\(dateFormatter.string(from: date))"
    }
    
    var length: Int {
        return characters.count
    }
    
    init(htmlEncodedString: String) {
        do {
            let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
            ]
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)!
        } catch {
            fatalError("Unhandled error: \(error)")
        }
    }
    
    //To check text field or String is blank or not
    public var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    // Number Checking
    var isNumber: Bool {
        let badCharacters = CharacterSet.decimalDigits.inverted
        if self.rangeOfCharacter(from: badCharacters) == nil {
            return true
        } else {
            return false
        }
    }
    
    //Validate PhoneNumber
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    //Validate Email
    var isValidEmail: Bool {
        //let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailRegex = "[A-Z0-9a-z._%+-]{2,254}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    var isValidURL : Bool {
        if let url  = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
    
    // Replace space with %20
    func replaceSpaceFromURL() -> String {
        let urlNew:String = self.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        return urlNew
    }
    
    //To check String is not null/NULL/nil.
    static func isSafeString(_ strOpt: AnyObject?) -> Bool {
        var returnVar = true
        if let tempStr = strOpt as? String {
            if tempStr.lowercased() == "null" || tempStr.lowercased() == "<null>" {
                returnVar = false
            }
        }
        else {
            returnVar = false
        }
        return returnVar
    }
    
    //get the safe string.
    static func getSafeString(_ strOpt: AnyObject?) -> String {
        return String.isSafeString(strOpt) ? strOpt as! String : ""
    }
    
//    func attributedStringTitle(withTitle : String , description : String , size : CGFloat, titleColor: UIColor ,descriptionColor: UIColor ) -> NSMutableAttributedString
    static func getAttributedString(_ title : String , descriptionText : String , size : CGFloat, titleColor: UIColor ,descriptionColor: UIColor ) -> NSMutableAttributedString
    {
        let attribute1 = [NSForegroundColorAttributeName: titleColor,NSFontAttributeName: UIFont(name: FONT_BOLD, size: size)!]
        let attrTitle = NSMutableAttributedString(string: title, attributes: attribute1)
        let attributedPrice2 = [NSForegroundColorAttributeName: descriptionColor,NSFontAttributeName: UIFont(name: FONT_REGULAR, size: size)!]
        let attributedDescription = NSAttributedString(string: descriptionText, attributes: attributedPrice2)
        attrTitle.append(attributedDescription)
        return attrTitle
        
    }
    
    //Check Special Character in string
    func hasSpecialCharacter() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            return true
        }
        return false
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.endIndex, offsetBy: -count))
    }
    
    func containsEmoji() -> Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x3030, 0x00AE, 0x00A9,// Special Characters
            0x1D000...0x1F77F,          // Emoticons
            0x2100...0x27BF,            // Misc symbols and Dingbats
            0xFE00...0xFE0F,            // Variation Selectors
            0x1F900...0x1F9FF:          // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }
    
}

//MARK: - Int
extension Int {
    func getNumberOfDigits() -> Int {
        var n = self
        var count = 0
        while n > 0 {
            count += 1
            n /= 10
        }
        return count
    }
}

//MARK: - Double
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//MARK :- NSLayoutConstraint
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}


//MARK: - JSON
extension JSON {
    //JSON -> FILE
    func storeJSONtoFile(_ fileName:String) {
        let str = self.description
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            let pathUrl = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)
            debugPrint(pathUrl!.path)
            do {
                _ = try str.write(toFile: pathUrl!.path, atomically: false, encoding: String.Encoding.utf8)
                excludeFromBackup(path: (pathUrl?.path)!)
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func excludeFromBackup(path:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        for dir in paths {
            print("the paths are \(dir)")
            var urlToExclude = URL(fileURLWithPath: dir)
            do {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try urlToExclude.setResourceValues(resourceValues)
                
            } catch { print("failed to set resource value") }
        }
    }
    //FILE -> JSON
    static func getJSONFromFile(_ fileName:String) -> JSON? {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
            let pathUrl = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)
            do {
                let readingText = try NSString(contentsOfFile: pathUrl!.path, encoding: String.Encoding.utf8.rawValue)
                let data: NSData = readingText.data(using: String.Encoding.utf8.rawValue)! as NSData
                let jsonObj = JSON(data: data as Data)
                if jsonObj != JSON.null {
                    return jsonObj
                }
            }
            catch {
                /* error handling here */
            }
        }
        return nil
    }
}

//MARK: - CALAyer
extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}

extension Date {
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    func currentTime24() -> (Hour:Int,Minute:Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let Time = dateFormatter.string(from: self)
        return ((Int)(Time.components(separatedBy: ":").first!)!,(Int)(Time.components(separatedBy: ":").last!)!)
    }
    func convertTime24(_ TimeString:String) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh a"
        let time = dateFormatter.date(from: TimeString)
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: time!) as NSString
    }
    func convertTime12(_ TimeString:String) -> NSString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let time = dateFormatter.date(from: TimeString)
        dateFormatter.dateFormat = "hh a"
        return dateFormatter.string(from: time!) as NSString
    }
    
}


