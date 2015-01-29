//
//  ViewController.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/29.
//  Copyright (c) 2015年 KKAwesome. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as CollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel?.text = "\(indexPath.section):\(indexPath.row)"
        cell.imageView?.image = UIImage(named: "circle")
        return cell
    }
}

