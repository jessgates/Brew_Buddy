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
import UserNotifications

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
    
    // Locate Breweries based on lat, lon
    func getBreweriesCurrentLocation() {
        
        currentLocation = locationManager?.location
            
        BreweryDBClient.sharedInstance().getNearbyBreweries(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude) { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(BreweryAnnotation.sharedInstance().annotations!)
                    self.breweries = data
                    self.regions(breweries: self.breweries!)
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
            self.locationManager?.distanceFilter = 1
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
    }
    
    // Set the regions for the 20 closest breweries for notification on entry
    func regions(breweries: [Brewery]) {
        var allRegions = [CLCircularRegion]()
        
        for brewery in breweries {
            
            let coordinate = CLLocationCoordinate2DMake(brewery.latitude!, brewery.longitude!)
            let region = CLCircularRegion(center: coordinate, radius: 1000, identifier: (brewery.brewery?["name"])! as! String)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            allRegions.append(region)
        }
        regionsToMonitor = Array(allRegions.prefix(10))
        startMonitoring(regions: regionsToMonitor)
    }
    
    // Start monitoring the array of regions
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
    
    // Stop monitoring the array of regions
    func stopMonitoring(regions: [CLCircularRegion]) {
        if regionsToMonitor.count > 0 {
            for region in regionsToMonitor {
                locationManager?.stopMonitoring(for: region)
            }
        }
    }
    
    // Open the Apple Maps application with current location and destination coordinates
    func directionsButtonTapped() {
        let brewery = mapView.selectedAnnotations.first
        let coordinate = brewery?.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate!, addressDictionary:nil))
        mapItem.name = brewery?.title!
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    // Manually refresh the nearby breweries and set new regions to monitor
    func refreshMapButtonPressed(_ sender: UIBarButtonItem!) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.removeAnnotations(mapView.annotations)
            stopMonitoring(regions: regionsToMonitor)
            getBreweriesCurrentLocation()
        } else {
            displayError("Enable locations services for Brew Buddy to find nearby Breweries")
        }
    }
    
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate Methods

extension BreweryMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        let directionsButton = UIButton(type: .custom)
        directionsButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        directionsButton.setImage(UIImage(named: "directionsMap.png"), for: .normal)
        let directionsTap = UITapGestureRecognizer(target: self, action: #selector(BreweryMapViewController.directionsButtonTapped))
        directionsButton.addGestureRecognizer(directionsTap)
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.leftCalloutAccessoryView = directionsButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView
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

// MARK: CLLocationManager Delegate Methods

extension BreweryMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
        displayError(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayError(error.localizedDescription)
    }
}

