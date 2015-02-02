//
//  SettingDetailViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/2/2.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import Foundation


class SettingDetailViewController : UIViewController{
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName"){
            self.nameTextField.text = name
        }
    }
    
    override func viewWillAppear(animated: Bool) {
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "關閉", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveTouchDown(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("userName")
        {
            defaults.setObject(self.nameTextField.text, forKey: "userName")
            
            self.navigationController?.popViewControllerAnimated(true)
            
        }
    }
}