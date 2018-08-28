//
//  SettingViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/17.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    var names = ["交通"
    ,"公園"
    ,"加油站"
    ,"學校"
    ,"宗教寺廟"
    ,"市場"
    ,"戲院"
    ,"機關"
    ,"環保局"
    ,"百貨"
    ,"超商"
    ,"遊憩"
    ,"醫院"
    ,"餐廳"]

    @IBOutlet weak var rangeBtn: UIButton!
    
    
    @IBOutlet weak var catTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeBtn.layer.cornerRadius = 10
        catTableView.layer.cornerRadius = 10
        if(SettingManager.agent.wcRange == 1){
            self.rangeBtn.setTitle("1 km 以內", forState: .Normal)
        }else if(SettingManager.agent.wcRange == 3){
            self.rangeBtn.setTitle("3 km 以內", forState: .Normal)
        }else if(SettingManager.agent.wcRange == 5){
            self.rangeBtn.setTitle("5 km 以內", forState: .Normal)
        }else if(SettingManager.agent.wcRange == 10){
            self.rangeBtn.setTitle("10 km 以內", forState: .Normal)
        }else if(SettingManager.agent.wcRange == 30){
            self.rangeBtn.setTitle("30 km 以內", forState: .Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func rangeBtnClick(sender: AnyObject) {
        
         let titleString = NSAttributedString(string: "請選擇距離範圍", attributes: [
         NSFontAttributeName : UIFont.systemFontOfSize(22),
         NSForegroundColorAttributeName : UIColor.blueColor()
         ])
         let optionMenu = UIAlertController(title: "距離範圍", message:nil, preferredStyle: .ActionSheet)
         optionMenu.setValue(titleString, forKey: "attributedTitle")
         
         //
         let cancelAction = UIAlertAction(title: "cancel", style: .Cancel, handler: nil)
         
         let oneAction = UIAlertAction(title: "1 km 以內", style: UIAlertActionStyle.Default, handler: {
         (action:UIAlertAction!) -> Void in
            self.rangeBtn.setTitle("1 km 以內", forState: .Normal)
                SettingManager.agent.wcRange = 1
                AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
         })
        
         let threeAction = UIAlertAction(title: "3 km 以內", style: UIAlertActionStyle.Default, handler: {
         (action:UIAlertAction!) -> Void in
            self.rangeBtn.setTitle("3 km 以內", forState: .Normal)
            SettingManager.agent.wcRange = 3
            AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
         })
         
         let fiveAction = UIAlertAction(title: "5 km 以內", style: UIAlertActionStyle.Default, handler: {
         (action:UIAlertAction!) -> Void in
            self.rangeBtn.setTitle("5 km 以內", forState: .Normal)
            SettingManager.agent.wcRange = 5
            AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
         })
         
         let tenAction = UIAlertAction(title: "10 km 以內", style: UIAlertActionStyle.Default, handler: {
         (action:UIAlertAction!) -> Void in
            self.rangeBtn.setTitle("10 km以內", forState: .Normal)
            SettingManager.agent.wcRange = 10
            AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
         })
        
        let thirtyAction = UIAlertAction(title: "30 km 以內", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) -> Void in
            self.rangeBtn.setTitle("30 km 以內", forState: .Normal)
            SettingManager.agent.wcRange = 30
            AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
        })
         
         optionMenu.addAction(cancelAction)
         optionMenu.addAction(oneAction)
         optionMenu.addAction(threeAction)
         optionMenu.addAction(fiveAction)
         optionMenu.addAction(tenAction)
         optionMenu.addAction(thirtyAction)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            optionMenu.popoverPresentationController!.sourceView = self.view
            optionMenu.popoverPresentationController!.sourceRect = CGRectMake(0, self.view.bounds.height , self.view.bounds.width, self.view.bounds.height/2.0)
            
        }
        
        
         self.presentViewController(optionMenu,animated:true,completion:nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        cell.accessoryType = .None
        
        if(SettingManager.agent.isTraffic && names[indexPath.row] == "交通"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isPark && names[indexPath.row] == "公園"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isGas && names[indexPath.row] == "加油站"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isSchool && names[indexPath.row] == "學校"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isTemple && names[indexPath.row] == "宗教寺廟"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isMarket && names[indexPath.row] == "市場"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isTheater && names[indexPath.row] == "戲院"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isGov && names[indexPath.row] == "機關"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isEPA && names[indexPath.row] == "環保局"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isDepartmentStore && names[indexPath.row] == "百貨"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isCS && names[indexPath.row] == "超商"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isRecreation && names[indexPath.row] == "遊憩"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isHospital && names[indexPath.row] == "醫院"){
            cell.accessoryType = .Checkmark
        }
        if(SettingManager.agent.isRestaurant && names[indexPath.row] == "餐廳"){
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(names[indexPath.row] == "交通"){
            if(SettingManager.agent.isTraffic){
            SettingManager.agent.isTraffic = false
            }else{
                SettingManager.agent.isTraffic = true
            }
        }else if(names[indexPath.row] == "公園"){
            if(SettingManager.agent.isPark){
                SettingManager.agent.isPark = false
            }else{
                SettingManager.agent.isPark = true
            }
        }else if(names[indexPath.row] == "加油站"){
            if(SettingManager.agent.isGas){
                SettingManager.agent.isGas = false
            }else{
                SettingManager.agent.isGas = true
            }
        }else if(names[indexPath.row] == "學校"){
            if(SettingManager.agent.isSchool){
                SettingManager.agent.isSchool = false
            }else{
                SettingManager.agent.isSchool = true
            }
        }else if(names[indexPath.row] == "宗教寺廟"){
            if(SettingManager.agent.isTemple){
                SettingManager.agent.isTemple = false
            }else{
                SettingManager.agent.isTemple = true
            }
        }else if(names[indexPath.row] == "市場"){
            if(SettingManager.agent.isMarket){
                SettingManager.agent.isMarket = false
            }else{
                SettingManager.agent.isMarket = true
            }
        }else if(names[indexPath.row] == "戲院"){
            if(SettingManager.agent.isTheater){
                SettingManager.agent.isTheater = false
            }else{
                SettingManager.agent.isTheater = true
            }
        }else if(names[indexPath.row] == "機關"){
            if(SettingManager.agent.isGov){
                SettingManager.agent.isGov = false
            }else{
                SettingManager.agent.isGov = true
            }
        }else if(names[indexPath.row] == "環保局"){
            if(SettingManager.agent.isEPA){
                SettingManager.agent.isEPA = false
            }else{
                SettingManager.agent.isEPA = true
            }
        }else if(names[indexPath.row] == "百貨"){
            if(SettingManager.agent.isDepartmentStore){
                SettingManager.agent.isDepartmentStore = false
            }else{
                SettingManager.agent.isDepartmentStore = true
            }
        }else if(names[indexPath.row] == "超商"){
            if(SettingManager.agent.isCS){
                SettingManager.agent.isCS = false
            }else{
                SettingManager.agent.isCS = true
            }
        }else if(names[indexPath.row] == "遊憩"){
            if(SettingManager.agent.isRecreation){
                SettingManager.agent.isRecreation = false
            }else{
                SettingManager.agent.isRecreation = true
            }
        }else if(names[indexPath.row] == "醫院"){
            if(SettingManager.agent.isHospital){
                SettingManager.agent.isHospital = false
            }else{
                SettingManager.agent.isHospital = true
            }
        }else if(names[indexPath.row] == "餐廳"){
            if(SettingManager.agent.isRestaurant){
                SettingManager.agent.isRestaurant = false
            }else{
                SettingManager.agent.isRestaurant = true
            }
        }
        AnnotationManager.agent.refreshAnnotations(SettingManager.agent.curLocation.coordinate.latitude, currentlon: SettingManager.agent.curLocation.coordinate.longitude)
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


}
