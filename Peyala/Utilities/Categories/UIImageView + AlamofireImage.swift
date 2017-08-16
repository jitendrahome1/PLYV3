//
//  UIImage + AlamofireImage.swift
//  AlomofireImage
//
//  Created by Chinmay Das on 31/08/16.
//  Copyright © 2016 Indus Net Technologies. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
  
  static var imageCache: AutoPurgingImageCache?
  static var downloader: ImageDownloader?
  
  static func configureCache(withMemoryCapacity memoryCapacity: UInt64?, andPreferredMemoryAfterPurge preferredMemory:UInt64?) {
    imageCache = AutoPurgingImageCache(memoryCapacity: memoryCapacity!, preferredMemoryUsageAfterPurge: preferredMemory!)
    downloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .fifo, maximumActiveDownloads: 10, imageCache: imageCache)
  }
  
  func setImage(withURL url: URL, placeHolderImageNamed placeholder:String?, andImageTransition imageTransition:ImageTransition) {
    
    var placeholderImage: UIImage? {
      if let placeholderImageName = placeholder {
        return UIImage(named: placeholderImageName)!
      }
      return nil
    }
    
    self.af_imageDownloader = UIImageView.downloader!
    self.af_setImage(withURL: url, placeholderImage: placeholderImage, filter: nil, progress: { (Progress) in
        
    }, progressQueue: DispatchQueue.main, imageTransition: imageTransition, runImageTransitionIfCached: true) { (image) in
        
    }
    //self.af_setImageWithURL(url, placeholderImage: placeholderImage, filter: nil, imageTransition: imageTransition)
  }
  
  func setImage(withURL url: URL, placeHolderImageNamed placeholder:String?) {
   // self.setImage(withURL: url, placeHolderImageNamed: placeholder, andImageTransition: .None)
  }
  
}
