//
//  WCData+CoreDataProperties.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/27.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WCData {

    @NSManaged var lat: NSNumber?
    @NSManaged var lon: NSNumber?
    @NSManaged var address: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var county: String?
    @NSManaged var town: String?
    @NSManaged var ref: String?

}
