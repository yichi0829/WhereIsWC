//
//  WCListViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/16.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class WCListViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,AnnotationsRefreshListener,CloseUpdatePopUpListener
{
    var locationManager: CLLocationManager = CLLocationManager()
    
    var annotationManager = AnnotationManager.agent
    var settingManager = SettingManager.agent
    let al = UIAlertController(title: "更新資料庫", message: "資料下載中，需要一些時間", preferredStyle: UIAlertControllerStyle.Alert)
    var first:Bool = false
    var wcList = [ARAnnotation]()
    @IBOutlet weak var wcTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        settingManager.curLocation = currentLocation
        annotationManager.registerCloseUpdatePopUpListener(self)
        annotationManager.registerAnnotationsRefreshListener(self)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //        annotationManager.refreshAnnotations(24.97916, currentlon: 121.544444)
        //        self.presentViewController(self.al, animated: true, completion: nil)
        //        settingManager.curLocation = CLLocation(latitude: 24.97916, longitude: 121.544444)
        //        annotationManager.checkUrlData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func closeUpdatePopUp(isOK:Bool, isTimeOut:Bool){
        al.dismissViewControllerAnimated(true, completion: nil)
        if(!isOK){
            if(isTimeOut){
                let alertView = UIAlertView(title: "錯誤訊息", message: "資料下載異常, 請聯絡程式設計人員", delegate: self, cancelButtonTitle: "好")
                alertView.show()
            }else{
                let alertView = UIAlertView(title: "錯誤訊息", message: "連線逾時, 請檢查網路環境", delegate: self, cancelButtonTitle: "好")
                alertView.show()
            }
        }
    }
    
    func annotationsRefreshFinished()
    {
        wcList = AnnotationManager.agent.getCurrentAnnotations()
        self.wcTableView.reloadData()
        if(wcList.count == 0){
            self.closeUpdatePopUp(true,isTimeOut: false)
        }
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let curLocation:CLLocation = locations[0]
        if(!first){
            first=true
            self.presentViewController(self.al, animated: true, completion: nil)
            settingManager.curLocation = curLocation
            annotationManager.checkUrlData()
        }else{
            if(curLocation.distanceFromLocation(settingManager.curLocation) > 500){
                settingManager.curLocation = curLocation
                annotationManager.refreshAnnotations(curLocation.coordinate.latitude, currentlon: curLocation.coordinate.longitude)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WCTableViewCell
        cell.nameLabel?.text = wcList[indexPath.row].title
        cell.addressLabel?.text = wcList[indexPath.row].address
        if(wcList[indexPath.row].distanceFromUser >= 1000){
            cell.distLabel?.text = String(format:"%.1f", wcList[indexPath.row].distanceFromUser/1000.0) + " km"
        }else{
            cell.distLabel?.text = String(format:"%.0f", wcList[indexPath.row].distanceFromUser) + " m"
        }
        if(indexPath.row == 1){
            self.closeUpdatePopUp(true,isTimeOut: false)
        }
        return cell
        
    }
    
    //    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wcList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailMapView" {
            if let indexPath = self.wcTableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! WCMapDetailViewController
                destinationController.setARAnnotation(wcList[indexPath.row])
            }
        }
    }
    
}
