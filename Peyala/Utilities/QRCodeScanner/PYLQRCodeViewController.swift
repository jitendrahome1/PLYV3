//
//  PYLQRCodeViewController.swift
//  Peyala
//
//  Created by Adarsh on 27/03/17.
//  Copyright © 2017 Indusnet. All rights reserved.
//

import UIKit
import AVFoundation

class PYLQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var viewCentralSqr: UIView!
    @IBOutlet weak var imgViewAnimatingBlue: UIImageView!
    @IBOutlet weak var btnCross: UIButton!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
//    var qrCodeFrameView:UIView?
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    var dissmissPopUpAction:(()->())!
    var dissmissAfterDecoding:((String)->())!
    var sourceViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
//            qrCodeFrameView = UIView()
            
//            if let qrCodeFrameView = qrCodeFrameView {
//                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
//                qrCodeFrameView.layer.borderWidth = 2
//                view.addSubview(qrCodeFrameView)
//                view.bringSubviewToFront(qrCodeFrameView)
//            }
            
            //paytm like scanning view and animation creation.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.messageLabel.frame.size.height), cornerRadius: 0)
                let squarePath = UIBezierPath(roundedRect: self.viewCentralSqr.frame, cornerRadius: 0)
                path.append(squarePath)
                path.usesEvenOddFillRule = true
                
                let fillLayer = CAShapeLayer()
                fillLayer.path = path.cgPath
                fillLayer.fillRule = kCAFillRuleEvenOdd
                fillLayer.fillColor = UIColor.black.cgColor
                fillLayer.opacity = 0.5
                self.view.layer.addSublayer(fillLayer)
                self.view.bringSubview(toFront: self.viewCentralSqr)
                
                //animate inner blue imageview for scanning effect
                self.imgViewAnimatingBlue.translatesAutoresizingMaskIntoConstraints = false
                self.imgViewAnimatingBlue.center = CGPoint(x: self.viewCentralSqr.frame.size.width/2, y: -self.viewCentralSqr.frame.size.height/2)
                UIView.animate(withDuration: 2.0, delay: 0, options: [UIViewAnimationOptions.repeat, UIViewAnimationOptions.autoreverse], animations: {
                    self.imgViewAnimatingBlue.center = CGPoint(x: self.viewCentralSqr.frame.size.width/2, y: self.viewCentralSqr.frame.size.height/2)
                    }, completion: nil)
                
                //not related to paytm animating.
                self.view.bringSubview(toFront: self.btnCross)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
//            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No barcode/QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
//            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
//            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
//                let imgViewScreenShot = UIImageView(image: self.getScreenShotImage())
//                view.addSubview(imgViewScreenShot)
//                view.bringSubviewToFront(imgViewScreenShot)
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
//                    if self.dissmissAfterDecoding != nil {
//                        self.dissmissAfterDecoding(metadataObj.stringValue)
//                    }
//                    self.dismissAnimate()
//                }
                
                if self.dissmissAfterDecoding != nil {
                    self.dissmissAfterDecoding(metadataObj.stringValue)
                }
                self.dismissAnimate()
            }
        }
    }
    
    func getScreenShotImage() -> UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
//        var imageSize = CGSize.zero
//        
//        let orientation = UIApplication.sharedApplication().statusBarOrientation
//        if UIInterfaceOrientationIsPortrait(orientation) {
//            imageSize = UIScreen.mainScreen().bounds.size
//        } else {
//            imageSize = CGSize(width: UIScreen.mainScreen().bounds.size.height, height: UIScreen.mainScreen().bounds.size.width)
//        }
//        
//        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
//        for window in UIApplication.sharedApplication().windows {
//            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
//        }
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // MARK: - User Defined Functiom\ns
    internal class func showQrCodeScannerPopUp(_ sourceController: UIViewController, dissmiss:@escaping ()->(), dissmissAfterDecode:@escaping (String)->()) {
        
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: PYLQRCodeViewController.self)) as! PYLQRCodeViewController
        viewController.sourceViewController = sourceController
        viewController.dissmissPopUpAction = dissmiss
        viewController.dissmissAfterDecoding = dissmissAfterDecode
        viewController.presentPopUP()
    }
    
    func presentPopUP() {
        
        self.view.frame = sourceViewController!.navigationController!.view.bounds
        sourceViewController!.navigationController!.view.addSubview(self.view)
        sourceViewController!.navigationController!.addChildViewController(self)
        sourceViewController!.navigationController!.view.bringSubview(toFront: self.view)
        
        presentAnimationToView()
    }
    
    //MARK: - Animation
    func presentAnimationToView() {
        self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform.identity
        }) 
    }
    
    func dismissAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: SCREEN_HEIGHT)
        }, completion: { (true) in
            self.view.removeFromSuperview();
            self.removeFromParentViewController()
            
        }) 
    }
    
    //MARK: - Actions
    @IBAction func crossBtnAction(_ sender: UIButton) {
        if self.dissmissPopUpAction != nil {
            self.dissmissPopUpAction()
        }
        dismissAnimate()
    }
}
