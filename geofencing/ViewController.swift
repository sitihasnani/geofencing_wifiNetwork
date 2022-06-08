//
//  ViewController.swift
//  geofencing
//
//  Created by Siti Hasnani Bt Mohd Hanafiyah on 08/06/2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
//
//        mapView.delegate = self
//        mapView.mapType = .standard
//        mapView.isZoomEnabled = true
//        mapView.isScrollEnabled = true
//
//        if let coor = mapView.userLocation.location?.coordinate{
//            mapView.setCenter(coor, animated: true)
//        }
        
        
        
    }
    
    @IBAction func addRegion(_ sender: Any) {
        print("Add Region")
        guard let longPress = sender as? UILongPressGestureRecognizer else
        { return }
        
        let touchLocation = longPress.location(in: mapView)
        //convert location we touch to coordinate, CGPoint to coordinate
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "geofence")
        mapView.removeOverlay(mapView.overlays as! MKOverlay)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.addOverlay(circle)
        
    }
    

}

extension ViewController: CLLocationManagerDelegate{
    //stop update location once its already update, to avoid keep running
    //show current location to maps
    // blue dots in maps
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = true
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locValue
//        annotation.title = "Geofencing"
//        annotation.subtitle = "current location"
//        mapView.addAnnotation(annotation)
        
    }
}

