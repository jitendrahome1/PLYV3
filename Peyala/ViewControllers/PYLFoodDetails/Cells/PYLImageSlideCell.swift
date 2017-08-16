//
//  PYLImageSlideCell.swift
//  Peyala
//
//  Created by Adarsh on 08/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLImageSlideCell: PYLBaseTableViewCell {

    @IBOutlet weak var collectionViewImages: UICollectionView!
    
    @IBOutlet weak var buttonForward: UIButton!
    @IBOutlet weak var buttonPrevious: UIButton!
    var arrBanner:[Dictionary<String,AnyObject>] = []
    override var datasource: AnyObject! {
        didSet{
            //            ["selectedIndex":"","images":arrFoodImage]
            arrBanner = (datasource as! Dictionary<String,AnyObject>)["images"] as! Array
            collectionViewImages.reloadData()
            buttonPrevious.isHidden = true
            buttonForward.isHidden = (arrBanner.count <= 1) ? true : false
            
        }
    }
    var currentShowingImageIndex = 0
    
    override func draw(_ rect: CGRect) {
        collectionViewImages.layer.cornerRadius = 2.0
        collectionViewImages.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        collectionViewImages.layer.borderWidth = 1
    }
    
    @IBAction func forwardButtonAction(_ sender: AnyObject) {
        currentShowingImageIndex = currentShowingImageIndex + 1
        buttonForward.isHidden = (currentShowingImageIndex == arrBanner.count - 1) ? true : false
        buttonPrevious.isHidden = false
        collectionViewImages.selectItem(at: IndexPath(row: currentShowingImageIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
    
    @IBAction func previousButtonAction(_ sender: AnyObject) {
        currentShowingImageIndex = currentShowingImageIndex - 1
        buttonPrevious.isHidden = (currentShowingImageIndex == 0) ? true : false
        collectionViewImages.selectItem(at: IndexPath(row: currentShowingImageIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }
}

extension PYLImageSlideCell: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentShowingImageIndex = Int(pageNumber)
        buttonForward.isHidden = (currentShowingImageIndex == arrBanner.count - 1) ? true : false
        buttonPrevious.isHidden = (currentShowingImageIndex == 0) ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
//        debugPrint("\(CGRectGetWidth(collectionView.bounds))")
        return  CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

extension PYLImageSlideCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return arrBanner.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PYLBannerCollectionCell.self), for: indexPath) as! PYLBannerCollectionCell
        cell.datasource = arrBanner[indexPath.row] as AnyObject!
        return cell
    }
}
