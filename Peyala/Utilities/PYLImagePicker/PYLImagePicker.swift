//
//  PYLImagePicker.swift
//  Peyala
//
//  Created by Adarsh on 23/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

class PYLImagePicker: NSObject {
    
    var imageSelected:((_ image:UIImage?)->())!
    static let handler = PYLImagePicker()
    fileprivate override init() {
    }
    
    static func showImagePickerOn(_ viewController: UIViewController, belowView: UIView, selectedImageCompletion:@escaping (_ image: UIImage?)->()) {
        let imagePickerObj = PYLImagePicker.handler
        imagePickerObj.imageSelected = selectedImageCompletion
        let sourceRect = CGRect(x: belowView.frame.midX,y:belowView.frame.maxY,width: 0, height: 0)
        let alertController = UIAlertController.showStandardActionSheetOrPopOverWith("", messageText: CHOOSE_PICKER, tuplePopOver: (sourceView: viewController.view, sourceRect: sourceRect, arrowIsUp: true), arrayButtons: ["Camera","Gallery"]) { (index) in
            switch index
            {
            case 0 :
                DispatchQueue.main.async(execute: {
                    imagePickerObj.showCameraDevice(viewController)
                })
                
            case 1:
                DispatchQueue.main.async(execute: {
                    imagePickerObj.showGallery(viewController)
                })
                
            default :
                break
            }
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showCameraDevice(_ viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            viewController.present(UIAlertController.showSimpleAlertWith("", alertText: CAMERA_NOT_AVAILABLE, selected_: { (index) in
                
            }), animated: true, completion: nil)
            return
        }
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = PYLImagePicker.handler
        //        sleep(5)
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func showGallery(_ viewController: UIViewController) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = PYLImagePicker.handler
        //        sleep(5)
        debugPrint(picker.delegate ?? "")
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension PYLImagePicker : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if imageSelected != nil {
            imageSelected((info[UIImagePickerControllerOriginalImage] as? UIImage)!)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if imageSelected != nil {
            imageSelected(nil)
        }
    }
}

