//
//  PYLFoodSizeCell.swift
//  Peyala
//
//  Created by Adarsh on 03/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLFoodSizeCell: PYLBaseTableViewCell {
    
    @IBOutlet weak var sizeScrollView: UIScrollView!
    
    var selectSizeButton:((_ selectedIndex:String)->())!
    var cellHeightForSingle: Double = 0.0
    override var datasource: AnyObject! {
        didSet{
            //            var startPosition: CGFloat = 0.0
            var startPositionY: CGFloat = 0.0
//            let widthForEachSize: CGFloat = 0.0
            let subViews = self.sizeScrollView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            //            if let sizeArray = datasource["size"] as? [String] {
            //                for index in 0..<sizeArray.count {
            //                    let view: UIView = UIView(frame:CGRectMake(startPosition, 0, 80, 44))
            //                    let imageView: UIImageView = UIImageView(frame:CGRectMake(0, 11, 23 , 23))
            //                    let selectedIndex = datasource["sizeIndex"] as! String
            //                    if index == Int(selectedIndex) {
            //                        imageView.image = UIImage(named: "FoodDetailsRadioButtonOn")
            //                    }else{
            //                        imageView.image = UIImage(named: "FoodDetailsRadioButtonOff")
            //                    }
            //                    view.addSubview(imageView)
            //                    let sizeButton: UIButton = UIButton(frame:CGRectMake(0, 0, 80 , 44))
            //                    sizeButton.addTarget(self, action:#selector(self.radioBtnActions), forControlEvents: .TouchUpInside)
            //                    sizeButton.tag = index
            //                    view.addSubview(sizeButton)
            //                    let labelTitle = UILabel(frame:CGRectMake(30, 0,50, 44))
            //                    labelTitle.text = sizeArray[index]
            //                    labelTitle.textColor = .grayColor()
            //                    labelTitle.font = labelTitle.font.fontWithSize(IS_IPAD() ? 18 : 15)
            //                    view.addSubview(labelTitle)
            //                    view.backgroundColor = UIColor.redColor()
            //                    sizeScrollView.addSubview(view)
            //                    startPosition = startPosition + (IS_IPAD() ? 10 : 5) + 80
            //                }
            //            }
            //            sizeScrollView.contentSize = CGSizeMake(startPosition, CGRectGetHeight(sizeScrollView.frame))
            
            if let sizeArray = datasource["size"] as? [String] {
                for index in 0..<sizeArray.count {
                    let view: UIView = UIView(frame:CGRect(x: 0, y: startPositionY, width: sizeScrollView.frame.width, height: CGFloat(cellHeightForSingle)))
                    let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y:11, width: 23 ,height: 23))
                    let selectedIndex = datasource["sizeIndex"] as! String
                    if index == Int(selectedIndex) {
                        imageView.image = UIImage(named: "FoodDetailsRadioButtonOn")
                    }else{
                        imageView.image = UIImage(named: "FoodDetailsRadioButtonOff")
                    }
                    imageView.center = CGPoint(x: imageView.center.x, y: view.frame.height * 0.5)
                    view.addSubview(imageView)
                    let sizeButton: UIButton = UIButton(frame:CGRect(x: 0, y: 0, width: view.frame.width ,height: CGFloat(cellHeightForSingle)))
                    sizeButton.addTarget(self, action:#selector(self.radioBtnActions), for: .touchUpInside)
                    sizeButton.tag = index
                    view.addSubview(sizeButton)
                    let labelTitle = UILabel(frame:CGRect(x: 30, y: 0,width: view.frame.width - 30, height: CGFloat(cellHeightForSingle)))
                    labelTitle.text = sizeArray[index]
                    labelTitle.textColor = .gray
                    labelTitle.font = labelTitle.font.withSize(IS_IPAD() ? 18 : 15)
                    view.addSubview(labelTitle)
//                    view.backgroundColor = (index % 2 == 0) ?  UIColor.redColor() : UIColor.greenColor()
                    sizeScrollView.addSubview(view)
                    startPositionY = startPositionY + (IS_IPAD() ? 0 : 0) + CGFloat(cellHeightForSingle)
                }
            }
            sizeScrollView.contentSize = CGSize(width: sizeScrollView.frame.width,height:startPositionY)
            sizeScrollView.frame.size = sizeScrollView.contentSize
        }
    }
    
    @IBAction func radioBtnActions(_ sender: UIButton) {
        let selectValue = sender.tag
        if selectSizeButton != nil {
            selectSizeButton("\(selectValue)")
        }
    }
}
