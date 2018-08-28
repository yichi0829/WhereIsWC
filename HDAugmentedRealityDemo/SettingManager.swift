//
//  SettingManager.swift
//  HiNaviR
//
//  Created by YiChi on 2016/5/19.
//  Copyright © 2016年 Citus. All rights reserved.
//

import Foundation
import CoreLocation

final class SettingManager{
    
    let defaults = NSUserDefaults.standardUserDefaults()
    /*"交通","公園","加油站","學校","宗教寺廟","市場","戲院","機關","環保局","百貨","超商","遊憩","醫院","餐廳"*/
    var location = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    var curLocation:CLLocation {
        get {
            return location
        }
        set (newVal) {
            location = newVal
        }
    }
    
    var isRestaurant:Bool {
        get {
            let _isRestaurant = defaults.objectForKey("isRestaurant")
            if ( _isRestaurant != nil) {
                return defaults.boolForKey("isRestaurant")
            }else{
                defaults.setBool(true, forKey: "isRestaurant")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isRestaurant")
        }
    }

    var isHospital:Bool {
        get {
            let _isHospital = defaults.objectForKey("isHospital")
            if ( _isHospital != nil) {
                return defaults.boolForKey("isHospital")
            }else{
                defaults.setBool(true, forKey: "isHospital")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isHospital")
        }
    }
    
    var isRecreation:Bool {
        get {
            let _isRecreation = defaults.objectForKey("isRecreation")
            if ( _isRecreation != nil) {
                return defaults.boolForKey("isRecreation")
            }else{
                defaults.setBool(true, forKey: "isRecreation")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isRecreation")
        }
    }

    var isCS:Bool {
        get {
            let _isCS = defaults.objectForKey("isCS")
            if ( _isCS != nil) {
                return defaults.boolForKey("isCS")
            }else{
                defaults.setBool(true, forKey: "isCS")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isCS")
        }
    }
    
    var isDepartmentStore:Bool {
        get {
            let _isDepartmentStore = defaults.objectForKey("isDepartmentStore")
            if ( _isDepartmentStore != nil) {
                return defaults.boolForKey("isDepartmentStore")
            }else{
                defaults.setBool(true, forKey: "isDepartmentStore")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isDepartmentStore")
        }
    }
    
    var isEPA:Bool {
        get {
            let _isEPA = defaults.objectForKey("isEPA")
            if ( _isEPA != nil) {
                return defaults.boolForKey("isEPA")
            }else{
                defaults.setBool(true, forKey: "isEPA")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isEPA")
        }
    }

    var isGov:Bool {
        get {
            let _isGov = defaults.objectForKey("isGov")
            if ( _isGov != nil) {
                return defaults.boolForKey("isGov")
            }else{
                defaults.setBool(true, forKey: "isGov")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isGov")
        }
    }
    
    var isTheater:Bool {
        get {
            let _isTheater = defaults.objectForKey("isTheater")
            if ( _isTheater != nil) {
                return defaults.boolForKey("isTheater")
            }else{
                defaults.setBool(true, forKey: "isTheater")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isTheater")
        }
    }

    var isMarket:Bool {
        get {
            let _isMarket = defaults.objectForKey("isMarket")
            if ( _isMarket != nil) {
                return defaults.boolForKey("isMarket")
            }else{
                defaults.setBool(true, forKey: "isMarket")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isMarket")
        }
    }
    
    var isTemple:Bool {
        get {
            let _isTemple = defaults.objectForKey("isTemple")
            if ( _isTemple != nil) {
                return defaults.boolForKey("isTemple")
            }else{
                defaults.setBool(true, forKey: "isTemple")
                return true
            }
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isTemple")
        }
    }
    
    var isSchool:Bool {
        get {
            let _isSchool = defaults.objectForKey("isSchool")
            if ( _isSchool != nil) {
                return defaults.boolForKey("isSchool")
            }else{
                defaults.setBool(true, forKey: "isSchool")
                return true
            }
            
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isSchool")
        }
    }
    
    var isPark:Bool {
        get {
            let _isPark = defaults.objectForKey("isPark")
            if ( _isPark != nil) {
                return defaults.boolForKey("isPark")
            }else{
                defaults.setBool(true, forKey: "isPark")
                return true
            }
            
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isPark")
        }
    }
    
    var isTraffic:Bool {
        get {
            let _isTraffic = defaults.objectForKey("isTraffic")
            if ( _isTraffic != nil) {
                return defaults.boolForKey("isTraffic")
            }else{
                defaults.setBool(true, forKey: "isTraffic")
                return true
            }
            
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isTraffic")
        }
    }
    
    var isGas:Bool {
        get {
            let _isGas = defaults.objectForKey("isGas")
            if ( _isGas != nil) {
                return defaults.boolForKey("isGas")
            }else{
                defaults.setBool(true, forKey: "isGas")
                return true
            }
            
        }
        set (newVal) {
            defaults.setBool(newVal, forKey: "isGas")
        }
    }

    // 地圖範圍(km): default 10km
    var wcRange:Int {
        get {
            let _wcRange = defaults.objectForKey("wcRange")
            if ( _wcRange != nil) {
                return defaults.integerForKey("wcRange")
            }else{
                defaults.setInteger(10, forKey: "wcRange")
                return 10
            }
            
        }
        set (newVal) {
            defaults.setInteger(newVal, forKey: "wcRange")
        }
    }
    
    class var agent:SettingManager{
        struct SingletonWrapper
        {
            static let singleton = SettingManager()
        }
        return SingletonWrapper.singleton
    }
}
 