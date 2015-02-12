//
//  CameraViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/11.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController : UIViewController, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate {
    
    var imagePicker:UIImagePickerController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePicker = UIImagePickerController()
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker!.allowsEditing = false
        }
    }

    override func viewDidAppear(animated: Bool) {
        self.presentViewController(imagePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!){
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}