//
//  AnnotationManager.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/14.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
//import Alamofire

protocol AnnotationsRefreshListener {
    func annotationsRefreshFinished()
}

protocol CloseUpdatePopUpListener {
    func closeUpdatePopUp(isOK:Bool, isTimeOut:Bool)
}

final class AnnotationManager{
    var annotations: [ARAnnotation] = []
    var taipeiWCUrl = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=008ed7cf-2340-4bc4-89b0-e258a5573be2"
    var xinbeiGasUrl = "http://data.ntpc.gov.tw/od/data/api/112F981A-0F10-4791-8F10-67FBDA1D3A83;jsessionid=AD892EF1E7EB6204383029827791F22B?$format=json"
    var xinbeiWCUrl = "http://data.ntpc.gov.tw/od/data/api/348DD2FF-2444-493F-93B4-90A90F8A6C0B;jsessionid=CCF7572BD1C59EA5EDA7408B8D90600C?$format=json"
    
    private var closeUpdatePopUpList = [CloseUpdatePopUpListener]()
    private var annotationsRefreshList = [AnnotationsRefreshListener]()
    private var wcList:[WCData] = [WCData]()
    var fetchResultController:NSFetchedResultsController!
    var coreDataManager:CoreDataManager = CoreDataManager.agent
    
    func registerAnnotationsRefreshListener(listener:AnnotationsRefreshListener){
        self.annotationsRefreshList.append(listener)
    }
    
    func registerCloseUpdatePopUpListener(listener:CloseUpdatePopUpListener){
        self.closeUpdatePopUpList.append(listener)
    }
    
    private init(){
        queryWCData()
    }
    
    class var agent:AnnotationManager{
        struct SingletonWrapper
        {
            static let singleton = AnnotationManager()
        }
        return SingletonWrapper.singleton
    }
    
    func queryWCData() {
        let fetchRequest = NSFetchRequest(entityName: "WCData")
        let sortDescriptor = NSSortDescriptor(key: "lon", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultController.performFetch()
            self.wcList = fetchResultController.fetchedObjects as! [WCData]
            print("wcList.count=",self.wcList.count)
        } catch {
            print(error)
        }
        
    }
    
    func deleteAllWC() {
        // Delete the row from the database
        //        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
        
        self.coreDataManager.managedObjectContext.deletedObjects//.deleteObject(favoriteCCTVToDelete)
        
        do {
            try self.coreDataManager.managedObjectContext.save()
        } catch {
            print("Failure to save context: \(error)")
        }
    }
    
    
    func addWCData(title:String, address:String, county:String, lat:Double, lon:Double, town:String, type:String, ref:String){
        
        let wc = NSEntityDescription.insertNewObjectForEntityForName("WCData", inManagedObjectContext: self.coreDataManager.managedObjectContext) as! WCData
        wc.title = title
        wc.address = address
        wc.county = county
        wc.lat = lat
        wc.lon = lon
        wc.town = town
        wc.type = type
        wc.ref = ref
        
        do {
            try self.coreDataManager.managedObjectContext.save()
        }catch{
            print("Failure to save context: \(error)")
        }
    }
    
    func downloadTaipeiPublicWCData(listCount:Int){
        let request = NSMutableURLRequest(URL: NSURL(string: taipeiWCUrl)!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if error != nil {
                if error!.domain == NSURLErrorDomain && error!.code == NSURLErrorTimedOut {
                    for listener in self.closeUpdatePopUpList{
                        listener.closeUpdatePopUp(false,isTimeOut: true)
                    }

                }
            }

            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                self.downloadXinbeiGasData(self.wcList.count-listCount)
            }else{
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        // process "json" as a dictionary
                        print( "json as a dictionary")
                        var dictionaryArray = [AnyObject]()
                        
                        dictionaryArray = json["result"]!["results"]! as! [AnyObject]
                        print("PWC=",dictionaryArray.count)
                        if(listCount != dictionaryArray.count){
                            self.wcList.removeAll()
                            self.deleteAllWC()
                            for var i in 0...dictionaryArray.count-1 {
                                let lon =  dictionaryArray[i].valueForKey("經度")?.doubleValue
                                let lat =  dictionaryArray[i].valueForKey("緯度")?.doubleValue
                                let title = dictionaryArray[i].valueForKey("單位名稱") as? String
                                let address = dictionaryArray[i].valueForKey("地址") as? String
                                let county = "台北市"
                                let town = dictionaryArray[i].valueForKey("行政區") as? String
                                let type = dictionaryArray[i].valueForKey("類別") as? String
                                let ref = "TaipeiPublicWC"
                                
                                self.addWCData(title!, address: address!, county: county, lat: lat!, lon: lon!, town: town!, type: type!, ref: ref)
                            }
                            self.queryWCData()
                            self.downloadXinbeiGasData(0)
                        }else{
                            self.downloadXinbeiGasData(self.wcList.count-listCount)
                        }
                        //                        print("annotations.count=",self.annotations.count)
                    } else if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSArray {
                        for listener in self.closeUpdatePopUpList{
                            listener.closeUpdatePopUp(false,isTimeOut: false)
                        }
                        
                    } else {
                        for listener in self.closeUpdatePopUpList{
                            listener.closeUpdatePopUp(false,isTimeOut: false)
                        }
                        
                    }
                    
                } catch _ {
                    for listener in self.closeUpdatePopUpList{
                        listener.closeUpdatePopUp(false,isTimeOut: false)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    func downloadXinbeiGasData(listCount:Int){
//        let url = xinbeiGasUrl
//        let shotsUrl = NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
//        Alamofire.request(.GET, shotsUrl).validate().responseJSON { response in
////            self.tableView.allowsSelection = true
////            self.tableView.scrollEnabled = true;
//            switch response.result {
//            case .Success: break
//            if let value = response.result.value {
//                let json = JSON(value)
//                dispatch_async(dispatch_get_main_queue(), {
//                    if(json.count>0){
//                        self.resultList.removeAll()
//                    }else{
//                        self.resultList.removeAll()
//                        self.tableView.reloadData()
//                    }
//                    let count = json.count
//                    for index in 0..<count{
//                        var info = POIInfo()
//                        info.name = json[index]["name"].string!
//                        info.address = json[index]["address"].string!
//                        info.address = info.address.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//                        info.lon = Double(json[index]["colx"].string!)!
//                        info.lat = Double(json[index]["coly"].string!)!
//                        //info.telphone = "02-22223333"
//                        self.resultList.append(info)
//                    }
//                    self.view.endEditing(true)
//                    self.tableView.reloadData()
//                    self.loadingIndictor!.hide()
//                });
//                
//                }
//                ////
//            if(listCount != json.count){
//                             }
//                
//                print("GAS=",json.count)
//                for var i in 0...json.count-1 {
//                    let aStatus = dictionaryArray[i] as? NSDictionary
//                    let title = aStatus!.valueForKey("station") as? String
//                    if(title?.characters.count > 0){
//                        let lon =  aStatus!.valueForKey("wgs84aX")?.doubleValue
//                        let lat =  aStatus!.valueForKey("wgs84aY")?.doubleValue
//                        let address = aStatus!.valueForKey("address") as? String
//                        let county = "新北市"
//                        let type = "加油站"
//                        let ref = "XinbeiGas"
//                        
//                        let townStr = aStatus!.valueForKey("address") as? NSString
//                        let townStr2 = townStr!.substringWithRange(NSRange(location: 0, length: 3))
//                        let town = townStr2 as String
//                        self.addWCData(title!, address: address!, county: county, lat: lat!, lon: lon!, town: town, type: type, ref: ref)
//                    }else{
//                        self.addWCData("", address: "", county: "新北市", lat: 0.0, lon: 0.0, town: "", type: "加油站", ref: "XinbeiGas")
//                    }
//                }
//                self.queryWCData()
//            }
//            self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
//                SettingManager.agent.curLocation.coordinate.longitude)
//            case .Failure(let error):
//                var errorArr = String(error).characters.split{$0 == " "}.map(String.init)
//                //                print("error ",errorArr[2])
//                for listener in self.closeUpdatePopUpList{
//                    listener.closeUpdatePopUp(false,isTimeOut: false)
//                }
//            }
//        }

        let request = NSMutableURLRequest(URL: NSURL(string: xinbeiGasUrl)!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if error != nil {
                if error!.domain == NSURLErrorDomain && error!.code == NSURLErrorTimedOut {
                    for listener in self.closeUpdatePopUpList{
                        listener.closeUpdatePopUp(false,isTimeOut: true)
                    }
                    
                }
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
                    SettingManager.agent.curLocation.coordinate.longitude)
                
            }else{
                do {
                    
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        for listener in self.closeUpdatePopUpList{
                            listener.closeUpdatePopUp(false,isTimeOut: false)
                        }
                    } else if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSArray {
                        
                        if let dictionaryArray = json as? NSArray{
                            if(listCount != dictionaryArray.count){
                                //                                var wcList2:[WCData] = [WCData]()
                                //                                for var i in 0...self.wcList.count-1 {
                                //                                    if(self.wcList[i].ref != "XinbeiGas"){
                                //                                        wcList2.append(self.wcList[i])
                                //                                    }
                                //                                }
                                //                                self.wcList.removeAll()
                                //                                for var i in 0...wcList2.count-1 {
                                //                                    self.wcList.append(wcList2[i])
                                //                                }
                                
                                print("GAS=",dictionaryArray.count)
                                for var i in 0...dictionaryArray.count-1 {
                                    let aStatus = dictionaryArray[i] as? NSDictionary
                                    let title = aStatus!.valueForKey("station") as? String
                                    if(title?.characters.count > 0){
                                        let lon =  aStatus!.valueForKey("wgs84aX")?.doubleValue
                                        let lat =  aStatus!.valueForKey("wgs84aY")?.doubleValue
                                        let address = aStatus!.valueForKey("address") as? String
                                        let county = "新北市"
                                        let type = "加油站"
                                        let ref = "XinbeiGas"
                                        
                                        let townStr = aStatus!.valueForKey("address") as? NSString
                                        let townStr2 = townStr!.substringWithRange(NSRange(location: 0, length: 3))
                                        let town = townStr2 as String
                                        self.addWCData(title!, address: address!, county: county, lat: lat!, lon: lon!, town: town, type: type, ref: ref)
                                    }else{
                                        self.addWCData("", address: "", county: "新北市", lat: 0.0, lon: 0.0, town: "", type: "加油站", ref: "XinbeiGas")
                                    }
                                }
                                self.queryWCData()
                            }
                            self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
                                SettingManager.agent.curLocation.coordinate.longitude)
                        }else{
                            self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
                                SettingManager.agent.curLocation.coordinate.longitude)
                            for listener in self.closeUpdatePopUpList{
                                listener.closeUpdatePopUp(false,isTimeOut: false)
                            }
                            
                        }
                        
                        
                        print("annotations.count=",self.annotations.count)
                        
                    } else {
                        for listener in self.closeUpdatePopUpList{
                            listener.closeUpdatePopUp(false,isTimeOut: false)
                        }
                    }
                    
                } catch _ {
                    self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
                        SettingManager.agent.curLocation.coordinate.longitude)
                    for listener in self.closeUpdatePopUpList{
                        listener.closeUpdatePopUp(false,isTimeOut: false)
                    }
                }
            }
        }
        task.resume()
    }
    
    func checkUrlData(){
//        self.downloadXinbeiGasData(0)
                var count = 0
        print("self.wcList.count=",self.wcList.count)
                if(self.wcList.count != 0){
                    self.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon:
                        SettingManager.agent.curLocation.coordinate.longitude)
                    
        
                }else{
                    downloadTaipeiPublicWCData(count)
                }
        
//        var count = 0
//        if(self.wcList.count != 0){
//            for var i in 0...self.wcList.count-1 {
//                if(self.wcList[i].ref == "TaipeiPublicWC"){
//                    count = count + 1
//                }
//            }
//        }
//        
//        downloadTaipeiPublicWCData(count)
        
    }
    
    
    func refreshAnnotations(currentlat:Double, currentlon:Double){
        let userLocation:CLLocation = CLLocation(latitude: currentlat, longitude: currentlon)
        self.annotations.removeAll()
        print("self.wcList.count=",self.wcList.count)
        print("wcRange=",Double(SettingManager.agent.wcRange) * 1000.0)
        print("lon=",currentlon,", lat=",currentlat)
        for var i in 0...self.wcList.count-1 {
            if(!SettingManager.agent.isTraffic && self.wcList[i].type == "交通"){
                continue
            }
            if(!SettingManager.agent.isPark && self.wcList[i].type == "公園"){
                continue
            }
            if(!SettingManager.agent.isGas && self.wcList[i].type == "加油站"){
                continue
            }
            if(!SettingManager.agent.isSchool && self.wcList[i].type == "學校"){
                continue
            }
            if(!SettingManager.agent.isTemple && self.wcList[i].type == "宗教寺廟"){
                continue
            }
            if(!SettingManager.agent.isMarket && self.wcList[i].type == "市場"){
                continue
            }
            if(!SettingManager.agent.isTheater && self.wcList[i].type == "戲院"){
                continue
            }
            if(!SettingManager.agent.isGov && self.wcList[i].type == "機關"){
                continue
            }
            if(!SettingManager.agent.isEPA && self.wcList[i].type == "環保局"){
                continue
            }
            if(!SettingManager.agent.isDepartmentStore && self.wcList[i].type == "百貨"){
                continue
            }
            if(!SettingManager.agent.isCS && self.wcList[i].type == "超商"){
                continue
            }
            if(!SettingManager.agent.isRecreation && self.wcList[i].type == "遊憩"){
                continue
            }
            if(!SettingManager.agent.isHospital && self.wcList[i].type == "醫院"){
                continue
            }
            if(!SettingManager.agent.isRestaurant && self.wcList[i].type == "餐廳"){
                continue
            }
            if(self.wcList[i].lat == 0.0 || self.wcList[i].title?.characters.count == 0){
                continue
            }
            
            let annotation = ARAnnotation()
            annotation.location = CLLocation(latitude: Double(self.wcList[i].lat!), longitude: Double(self.wcList[i].lon!))
            let meters = userLocation.distanceFromLocation(annotation.location!)
//            print("meters=",meters)
            if(meters > Double(SettingManager.agent.wcRange) * 1000.0){
                continue
            }
            
            annotation.distanceFromUser = meters
            annotation.title = self.wcList[i].title
            annotation.address = self.wcList[i].address!
            annotation.type = self.wcList[i].type!
            
            
            self.annotations.append(annotation)
            
        }
        self.annotations.sortInPlace {(annotation1:ARAnnotation, annotation2:ARAnnotation) -> Bool in
            annotation1.distanceFromUser < annotation2.distanceFromUser
        }
        
        
        for listener in self.annotationsRefreshList{
            listener.annotationsRefreshFinished()
        }
        //        for listener in self.closeUpdatePopUpList{
        //            listener.closeUpdatePopUp(true)
        //        }
        
    }
    
    func getCurrentAnnotations()->[ARAnnotation]{
        return annotations
    }
    
    //    func downloadXinbeiPublicWCData(){
    //        let request = NSMutableURLRequest(URL: NSURL(string: xinbeiWCUrl)!)
    //        request.HTTPMethod = "GET"
    //
    //        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
    //            guard error == nil && data != nil else {                                                          // check for fundamental networking error
    //                print("error=\(error)")
    //                return
    //            }
    //
    //            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
    //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
    //                print("response = \(response)")
    //            }else{
    //                do {
    //
    //                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
    //                        // process "json" as a dictionary
    //                        print( "json as a dictionary")
    //
    //                    } else if let json = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSArray {
    //                        print( "json as an array")
    //
    //                        if let dictionaryArray = json as? NSArray{
    //                            for var i in 0...dictionaryArray.count-1 {
    //                                let aStatus = dictionaryArray[i] as? NSDictionary
    //                                let title = aStatus!.valueForKey("name") as? String
    //                                if(title?.characters.count > 0){
    //                                    let lon =  aStatus!.valueForKey("wgs84aX")?.doubleValue
    //                                    let lat =  aStatus!.valueForKey("wgs84aY")?.doubleValue
    //                                    let address = aStatus!.valueForKey("address") as? String
    //                                    let county = "新北市"
    //                                    let type = "公廁"
    //                                    let ref = "XinbeiPublicWC"
    //                                    let town = aStatus!.valueForKey("area") as? String
    //                                    //
    //                                    let fetchRequest = NSFetchRequest(entityName: "WCData")
    //                                    let predicate = NSPredicate(format: "address == %@", address!)
    //                                    fetchRequest.predicate = predicate
    //
    //                                    do {
    //                                        let fetchResults = try self.coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest) as? [WCData]
    //                                        if fetchResults!.count == 0 {
    //                                            self.addWCData(title!, address: address!, county: county, lat: lat!, lon: lon!, town: town!, type: type, ref: ref)
    //                                        }
    //                                    } catch let _ as NSError{
    //
    //                                    }
    //
    //                                }
    //
    //                            }
    //                        }
    //                        
    //                        
    //                        print("annotations.count=",self.annotations.count)
    //                        
    //                    } else {
    //                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
    //                        print("Error could not parse JSON string: \(jsonStr)")
    //                    }
    //                    
    //                } catch _ {
    //                    print("Error!")
    //                    
    //                    // Error
    //                }
    //            }
    //        }
    //        task.resume()
    //    }
}