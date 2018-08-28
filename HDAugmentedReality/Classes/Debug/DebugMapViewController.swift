//
//  MapViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 20/06/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit
import MapKit

/// Called from ARViewController for debugging purposes
public class DebugMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    var mapRoute : MKRoute?
    private var annotations: [ARAnnotation]?
    private var locationManager = CLLocationManager()
    private var heading: Double = 0
    private var interactionInProgress = false
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.mapView.rotateEnabled = false
        self.mapView.mapType = .Standard
        
        if let annotations = self.annotations
        {
            addAnnotationsOnMap(annotations)
        }
        locationManager.delegate = self
    }
    
    public override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        locationManager.startUpdatingHeading()
    }
    
    public override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingHeading()
    }
    
    
    public func addAnnotations(annotations: [ARAnnotation])
    {
        self.annotations = annotations
        
        if self.isViewLoaded()
        {
            addAnnotationsOnMap(annotations)
        }
    }
    
    private func addAnnotationsOnMap(annotations: [ARAnnotation])
    {
        var mapAnnotations: [MKPointAnnotation] = []
        for annotation in annotations
        {
            if let coordinate = annotation.location?.coordinate
            {
                let mapAnnotation = MKPointAnnotation()
                mapAnnotation.coordinate = coordinate
                //                let text = String(format: "%@, AZ: %.0f, VL: %i, %.0fm", annotation.title != nil ? annotation.title! : "", annotation.azimuth, annotation.verticalLevel, annotation.distanceFromUser)
                var text = ""
                if(annotation.distanceFromUser >= 1000){
                    var dist = annotation.distanceFromUser/1000.0
                    text = String(format: "%@: %.1f km", annotation.title != nil ? annotation.title! : "",dist)
                }else{
                    text = String(format: "%@: %.0f m", annotation.title != nil ? annotation.title! : "",annotation.distanceFromUser)
                }
                mapAnnotation.title = text
                mapAnnotations.append(mapAnnotation)
            }
        }
        
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: false)
    }
    
    
    @IBAction func longTap(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began
        {
            let point = sender.locationInView(self.mapView)
            let coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let userInfo: [NSObject : AnyObject] = ["location" : location]
            NSNotificationCenter.defaultCenter().postNotificationName("kNotificationLocationSet", object: nil, userInfo: userInfo)
        }
    }
    
    @IBAction func closeButtonTap(sender: AnyObject)
    {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    public func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        heading = newHeading.trueHeading
        
        // Rotate map
        if(!self.interactionInProgress && CLLocationCoordinate2DIsValid(mapView.centerCoordinate))
        {
            let camera = mapView.camera.copy() as! MKMapCamera
            camera.heading = CLLocationDirection(heading);
            self.mapView.setCamera(camera, animated: false)
        }
    }
    
    public func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        self.interactionInProgress = true
    }
    
    public func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        self.interactionInProgress = false
    }
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if( annotation.title! != "Current Location"){
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            //        pinAnnotationView.pinColor = .Purple
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            
            let deleteButton = UIButton(type: UIButtonType.Custom)
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
//            deleteButton.backgroundColor = UIColor
            deleteButton.setImage(UIImage(named: "naviicon"), forState: .Normal)
            
            pinAnnotationView.leftCalloutAccessoryView = deleteButton
            
            return pinAnnotationView
            
        }else{
            return nil
        }
        
    }
    
    public func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (self.mapView.overlays.count > 0){
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        //        mapView.removeAnnotation(view.annotation!)
        self.mapView.deselectAnnotation(view.annotation, animated: false)
//        var coordinates : [CLLocationCoordinate2D] = [];
//        coordinates.append(CLLocationCoordinate2D(latitude:(locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!))
//        coordinates.append(CLLocationCoordinate2D(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude))
//        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
//        self.mapView.addOverlay(polyLine, level: MKOverlayLevel.AboveRoads)
        
        //
        let directionsRequest = MKDirectionsRequest()
        let fromPoint = MKPlacemark(coordinate: CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!), addressDictionary: nil)
        let toPoint = MKPlacemark(coordinate: CLLocationCoordinate2DMake(view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude), addressDictionary: nil)
        
        directionsRequest.source = (MKMapItem(placemark: fromPoint))
        directionsRequest.destination = (MKMapItem(placemark: toPoint))
        directionsRequest.transportType = MKDirectionsTransportType.Automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for _ in unwrappedResponse.routes {
                self.mapRoute = response!.routes[0] as? MKRoute
                self.mapView.addOverlay((self.mapRoute?.polyline)!)
                self.mapView.setVisibleMapRect(self.mapRoute!.polyline.boundingMapRect, animated: true)
                
            }
        }
        
    }
    
    public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay);
        pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5);
        pr.lineWidth = 5;
        return pr;
    }
}
