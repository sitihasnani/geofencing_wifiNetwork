//
//  ViewController.swift
//  geofencing
//
//  Created by Siti Hasnani Bt Mohd Hanafiyah on 08/06/2022.
//

import UIKit
import MapKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import Network
import NetworkExtension

class ViewController: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var ssidName: String = "RAMSSOLGROUP_5Ghz"
    var password: String = "RG55459225"
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: "RAMSSOLGROUP_5Ghz")
        print("disappear")
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getConfiguredNetwork(checkWifiResgion: true)
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                print("Internet connection is on.")
                self.getConfiguredNetwork(checkWifiResgion: false)
                NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (ssidsArray) in
                            print("ssidsArray.count==\(ssidsArray.count)")
                            for ssid in ssidsArray {
                                print("Connected ssid = ",ssid)
                                if(ssid == self.ssidName){
                                    self.getLocation()
                                } else {
                                    print("You are not in the region")
                                    self.connectToWifi()
                                }
                            }
                        }

                
            } else {
                print("There's no internet connection.")
                self.connectToWifi()
                
                }
            }

        monitor.start(queue: queue)


    }
    
    func getLocation(){
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 200
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            }
       
        self.locationManager.startMonitoringSignificantLocationChanges()
        print("You are in the region")
    }
    
    func connectToWifi(){
        let wiFiConfig = NEHotspotConfiguration(ssid: self.ssidName, passphrase: self.password, isWEP: false)
//        wiFiConfig.joinOnce = true
        NEHotspotConfigurationManager.shared.apply(wiFiConfig) { error in
            if let error = error {
                print(error.localizedDescription)
                }
            else {
                print("successfully connected!")
//                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: self.ssidName)
                self.getLocation()
                        
                }
                }
    }
    
    func getConfiguredNetwork(checkWifiResgion: Bool){
        NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (ssidsArray) in
                    print("ssidsArray.count==\(ssidsArray.count)")
                    for ssid in ssidsArray {
                        print("Connected ssid = ",ssid)
                        if(ssid == self.ssidName && checkWifiResgion == true){
                            self.getLocation()
                        } else {
                            print("You are not in the region")
                        }
                    }
                }
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
        
        let geofenceRegionCenter = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 500, identifier: "notifymeonExit")
        geofenceRegion.notifyOnExit = true
        geofenceRegion.notifyOnEntry = true
        locationManager.startMonitoring(for: geofenceRegion)
        let circle = MKCircle(center: geofenceRegion.center, radius: geofenceRegion.radius)
        mapView.addOverlay(circle)
        
        
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

