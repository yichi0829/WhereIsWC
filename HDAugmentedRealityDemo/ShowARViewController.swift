//
//  ShowARViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/17.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import UIKit
import CoreLocation

class ShowARViewController: UIViewController, ARDataSource,TestAnnotationViewListener{
    var annotationManager = AnnotationManager.agent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        showARViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Creates random annotations around predefined center point and presents ARViewController modally
    func showARViewController()
    {
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        
        // Create random annotations around center point    //@TODO
        //FIXME: set your initial position here, this is used to generate random POIs
//        let lat = 24.976859
//        let lon = 121.546034
//        let delta = 0.05
//        let count = 50
        let dummyAnnotations = annotationManager.getCurrentAnnotations()
        
        // Present ARViewController
        let arViewController = ARViewController()
//        arViewController.debugEnabled = true
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(dummyAnnotations)
        //        self.presentViewController(arViewController, animated: true, completion: nil)
        //        print("w=",self.view.layer.bounds.size.width,", h=",self.view.layer.bounds.size.height)
        ////////////////////////////////////////////
        arViewController.view.layer.frame = CGRect(x: 0,y: 0,width: self.view.layer.bounds.size.width,height: self.view.layer.bounds.size.height)
        self.view.addSubview(arViewController.view)
        
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.registerTestAnnotationViewListener(self)
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    func openMapView(annotations: [ARAnnotation]){
        let bundle = NSBundle(forClass: DebugMapViewController.self)
        let mapViewController = DebugMapViewController(nibName: "DebugMapViewController", bundle: bundle)
        self.presentViewController(mapViewController, animated: true, completion: nil)
        mapViewController.addAnnotations(annotations)
    }
    
}
