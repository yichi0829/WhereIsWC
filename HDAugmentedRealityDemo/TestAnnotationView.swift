//
//  TestAnnotationView.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 30/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit

protocol TestAnnotationViewListener {
    func openMapView(annotations: [ARAnnotation])
}

public class TestAnnotationView: ARAnnotationView, UIGestureRecognizerDelegate, UIAlertViewDelegate
{
    public var titleLabel: UILabel?
    public var infoButton: UIButton?
    private var annotations: [ARAnnotation] = []
    private var annotationViewList = [TestAnnotationViewListener]()

    func registerTestAnnotationViewListener(listener:TestAnnotationViewListener){
        self.annotationViewList.append(listener)
    }
    
    override public func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if self.titleLabel == nil
        {
            self.loadUi()
        }
    }
    
    func loadUi()
    {
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        self.addSubview(label)
        self.titleLabel = label
        
        // Info button
        self.infoButton?.removeFromSuperview()
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        button.userInteractionEnabled = false   // Whole view will be tappable, using it for appearance
        self.addSubview(button)
        self.infoButton = button
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapGesture"))
        self.addGestureRecognizer(tapGesture)
        
        // Other
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.layer.cornerRadius = 5
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        
        self.titleLabel?.frame = CGRectMake(10, 0, self.frame.size.width - buttonWidth - 5, self.frame.size.height);
        self.infoButton?.frame = CGRectMake(self.frame.size.width - buttonWidth, self.frame.size.height/2 - buttonHeight/2, buttonWidth, buttonHeight);
    }
    
    // This method is called whenever distance/azimuth is set
    override public func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title
        {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            let text = String(format: "%@\n%@", title, distance)
            
//            let text = String(format: "%@\nAZ: %.0f°\nDST: %@", title, annotation.azimuth, distance)
            self.titleLabel?.text = text
        }
    }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    public func tapGesture()
    {
        if let annotation = self.annotation
        {
            annotations.removeAll()
            annotations.append(annotation)
            let alertView = UIAlertView(title: annotation.title!, message: annotation.address, delegate: self, cancelButtonTitle: "關閉", otherButtonTitles:"查看地圖")
            alertView.show()
        }
        
    }
    
    public func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            break //close
        case 1:
            for listener in self.annotationViewList{
                listener.openMapView(self.annotations)
            }
            break //map
        default: print("Is this part even possible?")
        }
    }


}
