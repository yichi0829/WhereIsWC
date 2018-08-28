//
//  WCMapDetailViewController.swift
//  HDAugmentedRealityDemo
//
//  Created by YiChi on 2016/6/16.
//  Copyright © 2016年 Danijel Huis. All rights reserved.
//

import UIKit
import MapKit

class WCMapDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    var mapRoute : MKRoute?
    private var locationManager = CLLocationManager()
    private var heading: Double = 0
    private var interactionInProgress = false
    
    
    @IBOutlet weak var nameLabel: UILabel!
    var annotation:ARAnnotation!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.rotateEnabled = false
        self.mapView.mapType = .Standard
        //
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        nameLabel.numberOfLines = 0
        addressLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        addressLabel.numberOfLines = 0
        
        nameLabel.text = self.annotation.title
        addressLabel.text = self.annotation.address
        //
        var mapAnnotations: [MKPointAnnotation] = []
        
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
        
        
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: false)
        
        //
        mapView.delegate = self
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setARAnnotation(annotation:ARAnnotation){
        self.annotation = annotation
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingHeading()
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingHeading()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
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
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        self.interactionInProgress = true
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        self.interactionInProgress = false
    }
    
    internal func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if( annotation.title! != "Current Location"){
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            //        pinAnnotationView.pinColor = .Purple
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            
            let deleteButton = UIButton(type: UIButtonType.Custom)
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
//            deleteButton.backgroundColor = UIColor.redColor()
            deleteButton.setImage(UIImage(named: "naviicon"), forState: .Normal)
            
            pinAnnotationView.leftCalloutAccessoryView = deleteButton
            
            return pinAnnotationView
            
        }else{
            return nil
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
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
        directionsRequest.requestsAlternateRoutes = true
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay);
        pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5);
        pr.lineWidth = 5;
        return pr;
    }
    
    @IBAction func naviBtnClick(sender: AnyObject) {
        if (self.mapView.overlays.count > 0){
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        
        let directionsRequest = MKDirectionsRequest()
        let fromPoint = MKPlacemark(coordinate: CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!), addressDictionary: nil)
        annotation.location?.coordinate.latitude
        let toPoint = MKPlacemark(coordinate: CLLocationCoordinate2DMake((self.annotation.location?.coordinate.latitude)!, (self.annotation.location?.coordinate.longitude)!), addressDictionary: nil)
        
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
//                self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!), animated: true)
            }
        }
    }
}
