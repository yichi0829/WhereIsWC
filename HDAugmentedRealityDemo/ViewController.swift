//
//  ViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 21/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UITabBarController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.selectedIndex = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
    
    // UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        print("Selected item = ",item.tag)
//        if ( item.tag == 1 ){
//            showARViewController()
//        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("Selected view controller")
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}



















