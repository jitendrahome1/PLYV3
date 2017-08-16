//
//  PYLComboPopUpControllerViewController.swift
//  Peyala
//
//  Created by Adarsh on 07/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLComboPopUpControllerViewController: PYLBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK:- Outlet Connections
    
    @IBOutlet weak var collectionViewCombo: UICollectionView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var buttonForward: UIButton!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonCross: UIButton!
    
    var dismissPopUpAction:(()->())!  // no use now, as crossBtn is removed.
    var yesNoTapped:((_ isChosen:Bool, _ chosenComboDict: [String:AnyObject])->())!
    var sourceViewController: UIViewController?
    var currentShowingImageIndex = 0
    var arrData:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layoutIfNeeded()
//        arrData = [[:],[:],[:]]
        buttonPrevious.isHidden = true
        buttonForward.isHidden = (arrData.count <= 1) ? true : false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        collectionViewCombo.reloadData()
        buttonCross.center = CGPoint(x: popUpView.frame.maxX, y: popUpView.frame.minY)
        var frame: CGRect
        frame = buttonCross.frame
        frame.origin.x = frame.origin.x - popupRedCrossButtonPadding
        frame.origin.y = frame.origin.y + popupRedCrossButtonPadding
        buttonCross.frame = frame
    }
    
    //MARK: - User Defined Function
    internal class func showComboPopUp(_ sourceController: UIViewController, dissmiss:@escaping ()->()) {
        
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLComboPopUpControllerViewController.self)) as! PYLComboPopUpControllerViewController
        viewController.sourceViewController = sourceController
        viewController.dismissPopUpAction = dissmiss
        viewController.presentPopUP(sourceController)
    }
    
    internal class func showComboPopUp(_ sourceController: UIViewController, dataArray: [AnyObject] , yesOrNoTapped:@escaping (_ isChosen:Bool, _ chosenComboDict: [String:AnyObject])->()) {
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLComboPopUpControllerViewController.self)) as! PYLComboPopUpControllerViewController
        viewController.sourceViewController = sourceController
        viewController.arrData = dataArray
        viewController.yesNoTapped = yesOrNoTapped
        viewController.presentPopUP(sourceController)
    }
    
    func presentPopUP(_ sourceController: UIViewController) {
        
        self.view.frame = sourceController.navigationController!.view.bounds
        sourceController.navigationController!.view.addSubview(self.view)
        sourceController.navigationController!.addChildViewController(self)
        sourceController.navigationController!.view.bringSubview(toFront: self.view)
        collectionViewCombo.reloadData()
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimateWithCompletion(_ yesTapped:Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            if self.yesNoTapped != nil {
                self.yesNoTapped(yesTapped,self.arrData[self.currentShowingImageIndex] as! [String : AnyObject])
            }
        }) 
    }
    
    
    //MARK: CollectionView DataSource and Delegate methods.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentShowingImageIndex = Int(pageNumber)
        buttonForward.isHidden = (currentShowingImageIndex == arrData.count - 1) ? true : false
        buttonPrevious.isHidden = (currentShowingImageIndex == 0) ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PYLComboOfferCell.self), for: indexPath) as! PYLComboOfferCell
        cell.datasource = arrData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        debugPrint(CGSize(width: collectionViewCombo.frame.width, height: collectionViewCombo.frame.height-10))
        return CGSize(width: collectionViewCombo.frame.width, height: collectionViewCombo.frame.height-10)
    }
    
    func dismissPopUpView(){
        super.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Actions
    @IBAction func crossBtnAction(_ sender: UIButton) {
        dismissPopUpView()
    }
    
    @IBAction func forwardButtonAction(_ sender: AnyObject) {
        currentShowingImageIndex = currentShowingImageIndex + 1
        buttonForward.isHidden = (currentShowingImageIndex == arrData.count - 1) ? true : false
        buttonPrevious.isHidden = false
        collectionViewCombo.selectItem(at: IndexPath(item: currentShowingImageIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
    
    @IBAction func previousButtonAction(_ sender: AnyObject) {
        currentShowingImageIndex = currentShowingImageIndex - 1
        buttonPrevious.isHidden = (currentShowingImageIndex == 0) ? true : false
        collectionViewCombo.selectItem(at: IndexPath(item: currentShowingImageIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
    
    @IBAction func comboYesAction(_ sender: AnyObject) {
        dismissAnimateWithCompletion(true)
    }
    
    @IBAction func comboNoAction(_ sender: AnyObject) {
        dismissAnimateWithCompletion(false)
    }
    
}
