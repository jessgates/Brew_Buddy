//
//  BreweryMapViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class BreweryMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager? = .none
    var breweries: [Brewery]?
    var regionsToMonitor = [CLCircularRegion]()
    var breweryID: String!
    var name: String!
    var website: String?
    var imageURLs = [String:String]()
    var savedRegionLoaded = false
    var currentLocation: CLLocation!
    var dataStack: CoreDataStack!
    
    override func viewDidLoad() {
        setUpLocationManager()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        setUpLocationManager()
        
        let currentLocationButton = MKUserTrackingBarButtonItem.init(mapView: mapView)
        let refreshMapButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshMapButtonPressed(_:)))
        navigationItem.setRightBarButton(currentLocationButton, animated: true)
        navigationItem.setLeftBarButton(refreshMapButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Use NSUserDefaults to persist the user initiated map position
        if !savedRegionLoaded {
            if let savedRegion = UserDefaults.standard.object(forKey: "savedMapRegion") as? [String: Double] {
                let center = CLLocationCoordinate2D(latitude: savedRegion["mapRegionCenterLat"]!, longitude: savedRegion["mapRegionCenterLon"]!)
                let span = MKCoordinateSpan(latitudeDelta: savedRegion["mapRegionSpanLatDelta"]!, longitudeDelta: savedRegion["mapRegionSpanLonDelta"]!)
                mapView.region = MKCoordinateRegion(center: center, span: span)
            }
            
            savedRegionLoaded = true
        }
    }
    
    // Prepare for segue passing Brewery information from a tapped Annotation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreweryDetails" {
            BreweryDBClient.sharedInstance().breweryID = breweryID
            let breweryDetailsVC = segue.destination as! BreweryDetailsViewController
            breweryDetailsVC.name = name
            breweryDetailsVC.website = website
            breweryDetailsVC.imageURLs = imageURLs
        }
    }
    
// MARK: - Helper Functions
    
    // Request permission to user's location and locate Breweries based on lat, lon
    func getBreweriesCurrentLocation() {
            
        currentLocation = locationManager?.location
            
        BreweryDBClient.sharedInstance().getNearbyBreweries(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude) { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(BreweryAnnotation.sharedInstance().annotations!)
                    self.breweries = data
                    self.regions(breweries: self.breweries!)
                    self.startMonitoring(regions: self.regionsToMonitor)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } else {
                DispatchQueue.main.async {
                    self.displayError("No data returned. Please check internet connection")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    func setInitialMapViewRegion() {
        let viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 10000, 10000)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    func setUpLocationManager() {
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.distanceFilter = kCLLocationAccuracyNearestTenMeters
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func regions(breweries: [Brewery]) {
        var allRegions = [CLCircularRegion]()
        
        for brewery in breweries {
            
            let coordinate = CLLocationCoordinate2DMake(brewery.latitude!, brewery.longitude!)
            let region = CLCircularRegion(center: coordinate, radius: 700, identifier: (brewery.brewery?["name"])! as! String)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            allRegions.append(region)
        }
        
        regionsToMonitor = Array(allRegions.prefix(20))
    }
    
    func startMonitoring(regions: [CLCircularRegion]) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            displayError("Geo monitoring is not supported on this device!")
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            displayError("Your nearby breweries will only be activated once you grant Brew Buddy permission to access the device location.")
        }
        
        for region in regionsToMonitor {
            locationManager?.startMonitoring(for: region)
        }
    }
    
    func stopMonitoring(regions: [CLCircularRegion]) {
        if regionsToMonitor.count > 0 {
            for region in regionsToMonitor {
                locationManager?.stopMonitoring(for: region)
            }
        }
    }
    
    func saveBreweries() {
        
        for brewery in breweries! {
            if let entity = NSEntityDescription.entity(forEntityName: "Breweries", in: dataStack.context) {
                let newBrewery = Breweries(entity: entity, insertInto: dataStack.context)
                newBrewery.name = brewery.brewery?["name"] as! String?
                newBrewery.id = brewery.brewery?["id"] as! String?
                newBrewery.latitude = brewery.latitude!
                newBrewery.longitude = brewery.longitude!
                dataStack.save()
            }
        }
    }
    
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func refreshMapButtonPressed(_ sender: UIBarButtonItem!) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.removeAnnotations(mapView.annotations)
            getBreweriesCurrentLocation()
        } else {
            displayError("Enable locations services for Brew Buddy to find nearby Breweries")
        }
    }
    
}

// MARK: - MKMapViewDelegate Methods

extension BreweryMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        if annotation is MKUserLocation {
            return nil
        } else {
           return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let selectedBrewery = view.annotation as! CustomBreweryPointAnnotation
            breweryID = selectedBrewery.breweryID
            name = selectedBrewery.title
            website = selectedBrewery.website
            imageURLs = selectedBrewery.imageURLs!
            performSegue(withIdentifier: "BreweryDetails", sender: view)
        }
    }
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if (recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            let regionToSave = [
                "mapRegionCenterLat": mapView.region.center.latitude,
                "mapRegionCenterLon": mapView.region.center.longitude,
                "mapRegionSpanLatDelta": mapView.region.span.latitudeDelta,
                "mapRegionSpanLonDelta": mapView.region.span.longitudeDelta
            ]
            
            UserDefaults.standard.set(regionToSave, forKey: "savedMapRegion")
        }
    }
}

extension BreweryMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        switch status {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .authorizedAlways:
            currentLocation = locationManager?.location
            setInitialMapViewRegion()
            getBreweriesCurrentLocation()
        case .authorizedWhenInUse:
            setInitialMapViewRegion()
            getBreweriesCurrentLocation()
            displayError("If you would like to be notified when you're near a brewery, enable Always On location services for Brew Buddy")
        case .denied:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            stopMonitoring(regions: regionsToMonitor)
            displayError("Enable locations services for Brew Buddy to find nearby Breweries")
        case .restricted:
            stopMonitoring(regions: regionsToMonitor)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            displayError("You are unable to use location serices at this time")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locationManager?.location
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayError("Monitoring has failed2")
    }
}

