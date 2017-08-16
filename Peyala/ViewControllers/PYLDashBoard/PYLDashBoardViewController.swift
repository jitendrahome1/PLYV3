//
//  PYLDashBoardViewController.swift
//  Peyala
//
//  Created by Adarsh on 06/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PYLDashBoardViewController: PYLBaseViewController {
    
    @IBOutlet weak var collectionViewBanner: UICollectionView!
    @IBOutlet weak var collectionViewCategory: UICollectionView!
    @IBOutlet weak var pageControlBanner: UIPageControl?
    
    @IBOutlet weak var imageViewDesserts: UIImageView!
    @IBOutlet weak var imageViewWraps: UIImageView!
    @IBOutlet weak var imageViewSalads: UIImageView!
    @IBOutlet weak var imageViewHotBeverage: UIImageView!
    @IBOutlet weak var imageViewColdBeverage: UIImageView!
    @IBOutlet weak var labelTitle:        UILabel!
    @IBOutlet weak var labelCost:         UILabel!
    
    @IBOutlet weak var labelWraps: UILabel!
    @IBOutlet weak var labelSalads: UILabel!
    @IBOutlet weak var labelHotBeverage: UILabel!
    @IBOutlet weak var labelColdBeverage: UILabel!
    @IBOutlet weak var labelDesserts: UILabel!
    
    @IBOutlet var constraintHeightWidthRatio: NSLayoutConstraint!
    var arrBanner:[[String:AnyObject]] = []
    var arrCategory = [AnyObject]()
    var timer = Timer()
    //var timerShine = NSTimer()
    var arrayViews = [UIView]()
    var isApiCalledOnce = false
    var isShowCallout = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "PEYALA"
        callBannerApi()
        callCategoryApi()
        arrayViews.append(imageViewDesserts.superview!)
        arrayViews.append(imageViewHotBeverage.superview!)
        arrayViews.append(imageViewWraps.superview!)
        arrayViews.append(imageViewColdBeverage.superview!)
        arrayViews.append(imageViewSalads.superview!)
        for (_, item) in arrayViews.enumerated() {
            item.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        //showAlertPopup()
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpperNavigationItems()
        super.viewWillAppear(animated)
        trackScreenForAnalyticsWithName(DASHBOARD_SCREEN, isGoogle: true, isFB: true)
        
    }
    
    func animateRandomFoods() {
        for (index, item) in arrayViews.enumerated() {
            UIView.animate(withDuration: 0.25, delay: (Double(index)/10), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.01, options: .curveLinear, animations: {
                item.transform = CGAffineTransform.identity
            }) { (complete) in
            }
        }
    }
    
    /*
     func addShineAnimation() {
     
     let animateimage = arc4random()%6
     switch animateimage {
     case 1:
     imageViewWraps.shineWithRepeatCount(0)
     break
     case 2:
     imageViewSalads.shineWithRepeatCount(0)
     break
     case 3:
     imageViewDesserts.shineWithRepeatCount(0)
     break
     case 4:
     imageViewHotBeverage.shineWithRepeatCount(0)
     break
     case 5:
     imageViewColdBeverage.shineWithRepeatCount(0)
     break
     default:
     break
     }
     }
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        timer.invalidate()
        //timerShine.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.bannerMoveNext), userInfo: nil, repeats: true)
        //timerShine = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(addShineAnimation), userInfo: nil, repeats: true)
        animateRandomFoods()
    }
    override func viewDidLayoutSubviews() {
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //timerShine.invalidate()
        timer.invalidate()
        
    }
    
    func setUpperNavigationItems() {
        self.searchButtonEnabled = true
        self.cartButtonEnabled = true
        self.notificationButtonEnabled = true
    }
    
    func setupUI() {
        //changedUI things
        imageViewWraps.curveRoundWithGray()
        imageViewSalads.curveRoundWithGray()
        imageViewHotBeverage.curveRoundWithGray()
        imageViewColdBeverage.curveRoundWithGray()
        imageViewDesserts.curveRoundWithGray()
        
    }
    func showAlertPopup()
    {
        if isShowCallout
        {
            if PYLAPIManager.sharedManager.isReachable()
            {
                return
            }
            else
            {
                let alertController = UIAlertController.showSimpleAlertWith("Connection failed", alertText: CONNECTION_STATUS, selected_: { (index) in
                })
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    //MARK:- Netrork-ON Notification Observer
    override func networkOnConnectAction() {
        super.networkOnConnectAction()
        guard !isApiCalledOnce else { return }
        callBannerApi()
        callCategoryApi()
        
        PYLSpinner.show()
        // imageeeeeeeee downloaddd
        
        if let url = URL(string: PYLHelper.helper.selectedCountryFlagURL) {
            let request = URLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (response: URLResponse?, data: Data?, error: NSError?) in
                
                PYLSpinner.hide()
                if data?.count > 0{
                    PYLHelper.helper.selectedCountryFlagImage = UIImage(data: data!)!
                }
                self.pushToViewController(servicesStoryboard, viewController: String(describing: PYLDashBoardViewController.self))
            } as! (URLResponse?, Data?, Error?) -> Void)
        }
            
        else {
            self.view.showToastWithMessage("\(CHOOSE_OPTIONS)")
        }
        
    }
    
    
    func callBannerApi() {
        let constraint = self.constraintHeightWidthRatio.constraintWithMultiplier(IS_IPAD() ? 2.2 : 2.0)
        self.view!.removeConstraint(self.constraintHeightWidthRatio)
        self.view!.addConstraint(constraint)
        self.view!.layoutIfNeeded()
        
        PYLAPIHandler.handler.getBanner({ (response) in
            //            self.isApiCalledOnce = true
            //            //Use Banner
            //            if let banner_details = response["banner_details"].arrayObject{
            //                //                self.arrBanner = banner_details
            //                for i in 0..<banner_details.count {
            //                    var dict = banner_details[i] as! [String:String]
            //                    var tempDict = ["image":""]
            //                    tempDict["image"] = String.getSafeString(dict["banner_image_url"]).getAESDecryption()
            //                    tempDict["title"] = String.getSafeString(dict["banner_title"]).getAESDecryption()
            //                    tempDict["bannerID"] = String.getSafeString(dict["banner_id"]).getAESDecryption()
            //                    tempDict["food_item_id"] = String.getSafeString(dict["food_item_id"]).getAESDecryption()
            //                    tempDict["is_food_item"] = String.getSafeString(dict["is_food_item"]).getAESDecryption()
            //                    debugPrint("id=== \(tempDict["title"])")
            //                    self.arrBanner.append(tempDict)
            //                }
            //            }
            //            if self.arrBanner.count > 0 {
            //                if self.labelTitle != nil {
            //                    self.labelTitle.text = (self.arrBanner[0])["title"] as? String
            //                    
            //                }
            //            }
            //            debugPrint(self.arrBanner)
            //            self.collectionViewBanner.reloadData()
            //            self.pageControlBanner?.numberOfPages = self.arrBanner.count
            //            self.pageControlBanner?.currentPage = 0
            self.offlineOrSuccessResponseHandleBannerApi(response!)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleBannerApi(response!)
        }) { (error) in
            
        }
    }
    
    func callCategoryApi() {
        PYLAPIHandler.handler.getFoodCatagoryList({ (response) in
            //            debugPrint(response)
            //            self.isApiCalledOnce = true
            //            var responseDict = response.dictionaryObject!
            //            self.arrCategory = responseDict["food_category_list"] as! [AnyObject]
            //            PYLHelper.helper.arrFoodCategory = self.arrCategory
            //            
            //            for index in 0..<self.arrCategory.count {
            //                
            //                let catagoryDict = self.arrCategory[index]
            //                switch (index) {
            //                case 0:
            //                    if let image = catagoryDict["food_category_image_url"] as? String{
            //                        self.imageViewWraps.af_setImageWithURL(
            //                            NSURL(string: image.getAESDecryption().replaceSpaceFromURL())!,
            //                            placeholderImage: UIImage(named: "Placeholder")!,
            //                            filter:nil,
            //                            imageTransition: .CrossDissolve(0.5)
            //                        )
            //                    }
            //                    if let name =  catagoryDict["food_category_name"] as? String{
            //                        self.labelWraps.text = name.getAESDecryption().uppercaseString
            //                    }
            //                case 1:
            //                    if let image = catagoryDict["food_category_image_url"] as? String{
            //                        self.imageViewSalads.af_setImageWithURL(
            //                            NSURL(string: image.getAESDecryption().replaceSpaceFromURL())!,
            //                            placeholderImage: UIImage(named: "Placeholder")!,
            //                            filter:nil,
            //                            imageTransition: .CrossDissolve(0.5)
            //                        )
            //                    }
            //                    if let name =  catagoryDict["food_category_name"] as? String{
            //                        self.labelSalads.text = name.getAESDecryption().uppercaseString
            //                    }
            //                    
            //                case 2:
            //                    if let image = catagoryDict["food_category_image_url"] as? String{
            //                        self.imageViewDesserts.af_setImageWithURL(
            //                            NSURL(string: image.getAESDecryption().replaceSpaceFromURL())!,
            //                            placeholderImage: UIImage(named: "Placeholder")!,
            //                            filter:nil,
            //                            imageTransition: .CrossDissolve(0.5)
            //                        )
            //                    }
            //                    if let name =  catagoryDict["food_category_name"] as? String{
            //                        self.labelDesserts.text = name.getAESDecryption().uppercaseString
            //                    }
            //                    
            //                case 3:
            //                    if let image = catagoryDict["food_category_image_url"] as? String{
            //                        self.imageViewHotBeverage.af_setImageWithURL(
            //                            NSURL(string: image.getAESDecryption().replaceSpaceFromURL())!,
            //                            placeholderImage: UIImage(named: "Placeholder")!,
            //                            filter:nil,
            //                            imageTransition: .CrossDissolve(0.5)
            //                        )
            //                    }
            //                    if let name =  catagoryDict["food_category_name"] as? String{
            //                        self.labelHotBeverage.text = name.getAESDecryption().uppercaseString
            //                    }
            //                    
            //                case 4:
            //                    if let image = catagoryDict["food_category_image_url"] as? String{
            //                        self.imageViewColdBeverage.af_setImageWithURL(
            //                            NSURL(string: image.getAESDecryption().replaceSpaceFromURL())!,
            //                            placeholderImage: UIImage(named: "Placeholder")!,
            //                            filter:nil,
            //                            imageTransition: .CrossDissolve(0.5)
            //                        )
            //                    }
            //                    if let name =  catagoryDict["food_category_name"] as? String{
            //                        self.labelColdBeverage.text = name.getAESDecryption().uppercaseString
            //                    }
            //                    
            //                default:
            //                    break
            //                }
            //            }
            self.offlineOrSuccessResponseHandleCategoryApi(response!)
            }, offlineBlock: { (response) in
                self.offlineOrSuccessResponseHandleCategoryApi(response!)
        }) { (error) in
            
        }
    }
    
    func offlineOrSuccessResponseHandleBannerApi(_ response: JSON) {
        self.isApiCalledOnce = true
        //Use Banner
        if let banner_details = response["banner_details"].arrayObject{
            //                self.arrBanner = banner_details
            for i in 0..<banner_details.count {
                var dict = banner_details[i] as! [String:String]
                var tempDict = ["image":""]
                tempDict["image"] = String.getSafeString(dict["banner_image_url"] as AnyObject?).getAESDecryption()
                tempDict["title"] = String.getSafeString(dict["banner_title"] as AnyObject?).getAESDecryption()
                tempDict["bannerID"] = String.getSafeString(dict["banner_id"] as AnyObject?).getAESDecryption()
                tempDict["food_item_id"] = String.getSafeString(dict["food_item_id"] as AnyObject?).getAESDecryption()
                tempDict["is_food_item"] = String.getSafeString(dict["is_food_item"] as AnyObject?).getAESDecryption()
                debugPrint("id=== \(tempDict["title"])")
                self.arrBanner.append(tempDict as [String : AnyObject])
            }
        }
        if self.arrBanner.count > 0 {
            if self.labelTitle != nil {
                self.labelTitle.text = (self.arrBanner[0])["title"] as? String
                
            }
        }
        debugPrint(self.arrBanner)
        self.collectionViewBanner.reloadData()
        self.pageControlBanner?.numberOfPages = self.arrBanner.count
        self.pageControlBanner?.currentPage = 0
    }
    
    func offlineOrSuccessResponseHandleCategoryApi(_ response: JSON) {
        debugPrint(response)
        self.isApiCalledOnce = true
        var responseDict = response.dictionaryObject!
        self.arrCategory = responseDict["food_category_list"] as! [AnyObject]
        PYLHelper.helper.arrFoodCategory = self.arrCategory
        
        for index in 0..<self.arrCategory.count {
            
            let catagoryDict = self.arrCategory[index]
            switch (index) {
            case 0:
                if let image = catagoryDict["food_category_image_url"] as? String{
                    
                    self.imageViewWraps.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
                    
//                    self.imageViewWraps.af_setImageWithURL(
//                        URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                        placeholderImage: UIImage(named: "Placeholder")!,
//                        filter:nil,
//                        imageTransition: .CrossDissolve(0.5)
//                    )
                }
                if let name =  catagoryDict["food_category_name"] as? String{
                    self.labelWraps.text = name.getAESDecryption().uppercased()
                }
            case 1:
                if let image = catagoryDict["food_category_image_url"] as? String{
                    
                    self.imageViewSalads.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
                    
//                    self.imageViewSalads.af_setImageWithURL(
//                        URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                        placeholderImage: UIImage(named: "Placeholder")!,
//                        filter:nil,
//                        imageTransition: .CrossDissolve(0.5)
//                    )
                }
                if let name =  catagoryDict["food_category_name"] as? String{
                    self.labelSalads.text = name.getAESDecryption().uppercased()
                }
                
            case 2:
                if let image = catagoryDict["food_category_image_url"] as? String{
                    self.imageViewDesserts.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
//                    self.imageViewDesserts.af_setImageWithURL(
//                        URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                        placeholderImage: UIImage(named: "Placeholder")!,
//                        filter:nil,
//                        imageTransition: .CrossDissolve(0.5)
//                    )
                }
                if let name =  catagoryDict["food_category_name"] as? String{
                    self.labelDesserts.text = name.getAESDecryption().uppercased()
                }
                
            case 3:
                if let image = catagoryDict["food_category_image_url"] as? String{
                    self.imageViewHotBeverage.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
//                    self.imageViewHotBeverage.af_setImageWithURL(
//                        URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                        placeholderImage: UIImage(named: "Placeholder")!,
//                        filter:nil,
//                        imageTransition: .CrossDissolve(0.5)
//                    )
                }
                if let name =  catagoryDict["food_category_name"] as? String{
                    self.labelHotBeverage.text = name.getAESDecryption().uppercased()
                }
                
            case 4:
                if let image = catagoryDict["food_category_image_url"] as? String{
                    
                    self.imageViewColdBeverage.af_setImage(withURL: URL(string: image.getAESDecryption().replaceSpaceFromURL())!, placeholderImage: UIImage(named: "Placeholder")!, filter: nil, progress: { (progess) in
                        
                    }, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: { (image) in
                        
                    })
//                    self.imageViewColdBeverage.af_setImageWithURL(
//                        URL(string: image.getAESDecryption().replaceSpaceFromURL())!,
//                        placeholderImage: UIImage(named: "Placeholder")!,
//                        filter:nil,
//                        imageTransition: .CrossDissolve(0.5)
//                    )
                }
                if let name =  catagoryDict["food_category_name"] as? String{
                    self.labelColdBeverage.text = name.getAESDecryption().uppercased()
                }
                
            default:
                break
            }
        }
    }
    
    func bannerMoveNext() {
        if arrBanner.count==0 {
            return
        }
        pageControlBanner!.currentPage = (pageControlBanner!.currentPage == arrBanner.count-1) ? 0 : pageControlBanner!.currentPage + 1
        collectionViewBanner.selectItem(at: IndexPath(item: pageControlBanner!.currentPage, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        
        if labelTitle != nil {
            labelTitle.text = (arrBanner[(pageControlBanner?.currentPage)!] )["title"] as? String
        }
    }
    
    //MARK:  Button Actions
    @IBAction func foodMenuTapped(_ sender: UIButton) {
        
        //        let crashLine = arrBanner[1000]
        
        let viewController = servicesStoryboard.instantiateViewController(withIdentifier: String(describing: PYLFoodItemsViewController.self))  as! PYLFoodItemsViewController
        
        switch (sender.tag) {
            
        case ButtonBaseTag+1:
            
            //            UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            //                self.imageViewWraps.transform = CGAffineTransformMakeScale(0.8, 0.5)
            //            }) { (complete) in
            //                
            //                UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            //                    self.imageViewWraps.transform = CGAffineTransformMakeScale(1.5, 1.5)
            //                }) { (complete) in
            //                    
            //                    UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .CurveEaseIn, animations: {
            //                        self.imageViewWraps.transform = CGAffineTransformIdentity
            //                    }) { (complete) in
            //                        
            //                    }
            //                    
            //                    if self.arrCategory.count < 1 {
            //                        self.view.showToastWithMessage(FOOD_ITEM_NOT_AVAILABLE)
            //                        return
            //                    }
            //                    let catagoryDict = self.arrCategory[0]
            //                    if let catagoryID =  catagoryDict["food_category_id"] as? String {
            //                        viewController.foodCatagoryID = catagoryID.getAESDecryption()
            //                    }
            //                    if let catagoryName =  catagoryDict["food_category_name"] as? String{
            //                        viewController.foodCatagoryName = catagoryName.getAESDecryption()
            //                    }
            //                }
            //            }
            
            if self.arrCategory.count < 1 {
                let msg = PYLHelper.helper.isNetworkOn ? FOOD_ITEM_NOT_AVAILABLE : NO_NETWORK
                self.view.showToastWithMessage(msg)
                return
            }
            let catagoryDict = self.arrCategory[0]
            if let catagoryID =  catagoryDict["food_category_id"] as? String {
                viewController.foodCatagoryID = catagoryID.getAESDecryption()
            }
            if let catagoryName =  catagoryDict["food_category_name"] as? String{
                viewController.foodCatagoryName = catagoryName.getAESDecryption()
            }
            
            
            break
            
        case ButtonBaseTag+2:
            if self.arrCategory.count < 2 {
                let msg = PYLHelper.helper.isNetworkOn ? FOOD_ITEM_NOT_AVAILABLE : NO_NETWORK
                self.view.showToastWithMessage(msg)
                return
            }
            let catagoryDict = self.arrCategory[1]
            if let catagoryID =  catagoryDict["food_category_id"] as? String {
                viewController.foodCatagoryID = catagoryID.getAESDecryption()
            }
            if let catagoryName =  catagoryDict["food_category_name"] as? String{
                viewController.foodCatagoryName = catagoryName.getAESDecryption()
            }
            break
            
        case ButtonBaseTag+3:
            if self.arrCategory.count < 3 {
                let msg = PYLHelper.helper.isNetworkOn ? FOOD_ITEM_NOT_AVAILABLE : NO_NETWORK
                self.view.showToastWithMessage(msg)
                return
            }
            let catagoryDict = self.arrCategory[2]
            if let catagoryID =  catagoryDict["food_category_id"] as? String {
                viewController.foodCatagoryID = catagoryID.getAESDecryption()
            }
            if let catagoryName =  catagoryDict["food_category_name"] as? String {
                viewController.foodCatagoryName = catagoryName.getAESDecryption()
            }
            break
            
        case ButtonBaseTag+4:
            if self.arrCategory.count < 4 {
                let msg = PYLHelper.helper.isNetworkOn ? FOOD_ITEM_NOT_AVAILABLE : NO_NETWORK
                self.view.showToastWithMessage(msg)
                return
            }
            let catagoryDict = self.arrCategory[3]
            if let catagoryID =  catagoryDict["food_category_id"] as? String {
                viewController.foodCatagoryID = catagoryID.getAESDecryption()
            }
            if let catagoryName =  catagoryDict["food_category_name"] as? String {
                viewController.foodCatagoryName = catagoryName.getAESDecryption()
            }
            break
            
        case ButtonBaseTag+5:
            if self.arrCategory.count < 5 {
                let msg = PYLHelper.helper.isNetworkOn ? FOOD_ITEM_NOT_AVAILABLE : NO_NETWORK
                self.view.showToastWithMessage(msg)
                return
            }
            let catagoryDict = self.arrCategory[4]
            if let catagoryID =  catagoryDict["food_category_id"] as? String {
                viewController.foodCatagoryID = catagoryID.getAESDecryption()
            }
            if let catagoryName =  catagoryDict["food_category_name"] as? String {
                viewController.foodCatagoryName = catagoryName.getAESDecryption()
            }
            break
            
        default:
            break
        }
        viewController.catagoryArray = self.arrCategory
        self.removeViewControllerFromNavigationStack(String(describing: viewController))
        PYLNavigationHelper.helper.navigationController.pushViewController(viewController, animated: true)
    }
}

extension PYLDashBoardViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard scrollView == collectionViewBanner else { return }
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControlBanner!.currentPage = Int(pageNumber)
        
        if self.arrBanner.count > 0 {
            if self.labelTitle != nil {
                self.labelTitle.text = (self.arrBanner[Int(pageNumber)])["title"] as? String
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return collectionViewBanner(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
    }
    
    // MARK: - Banner
    func collectionViewBanner(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewBanner.bounds.width,height: collectionViewBanner.bounds.height)
    }
    
    // MARK: Category
    func collectionViewCategory(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = collectionViewCategory.bounds.width*0.49
        return CGSize(width: width,height: width*0.7)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == collectionViewBanner else { return }
        let foodItemBannerDict: [String:String] = arrBanner[indexPath.row] as! [String : String]
        let foodItemBannerID:String = foodItemBannerDict["food_item_id"]!
        if (foodItemBannerID.length > 0)
        {
            let viewController = otherStoryboard.instantiateViewController( withIdentifier: String(describing: PYLFoodDetailsViewController.self)) as! PYLFoodDetailsViewController
            viewController.foodID = foodItemBannerID
            self.removeViewControllerFromNavigationStack(String(describing: viewController))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            let viewController = mainStoryboard.instantiateViewController( withIdentifier: String(describing: PYLAboutUsViewController.self)) as! PYLAboutUsViewController
            self.removeViewControllerFromNavigationStack(String(describing: viewController))
            PYLNavigationHelper.helper.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension PYLDashBoardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewBanner(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionViewBanner(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // MARK: Banner
    func collectionViewBanner(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  arrBanner.count
    }
    
    func collectionViewBanner(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PYLBannerCollectionCell.self), for: indexPath) as! PYLBannerCollectionCell
        cell.datasource = arrBanner[indexPath.row] as AnyObject!
        return cell
    }
}

extension UIImageView {
    func curveRoundWithGray() {
        // debugPrint(self.frame)
        self.layoutIfNeeded()
        self.contentMode = .scaleToFill
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
}
