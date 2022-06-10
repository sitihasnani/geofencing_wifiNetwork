//
//  ViewController.swift
//  geofencing
//
//  Created by Siti Hasnani Bt Mohd Hanafiyah on 08/06/2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController{

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
        
        let geofenceRegionCenter = CLLocationCoordinate2DMake(2.926015, 101.636093)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 500, identifier: "notifymeonExit")
        geofenceRegion.notifyOnExit = true
        geofenceRegion.notifyOnEntry = true
        locationManager.startMonitoring(for: geofenceRegion)
        let circle = MKCircle(center: geofenceRegion.center, radius: geofenceRegion.radius)
        mapView.addOverlay(circle)

    }
    
    @IBAction func addRegion(_ sender: Any) {
        print("Add Region")
//        guard let longPress = sender as? UILongPressGestureRecognizer else
//        { return }
//
//        let touchLocation = longPress.location(in: mapView)
//        //convert location we touch to coordinate, CGPoint to coordinate
//        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
//        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "geofence")
//        mapView.removeOverlay(mapView.overlays as! MKOverlay)
//        locationManager.startMonitoring(for: region)
//        let circle = MKCircle(center: coordinate, radius: region.radius)
//        mapView.addOverlay(circle)
//
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
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locValue
//        annotation.title = "Geofencing"
//        annotation.subtitle = "current location"
//        mapView.addAnnotation(annotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Oh No!", message: "You Exit The Region", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Oh WoWW!", message: "You Enter The Region", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return
            MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}

