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
    
    let locationManager = CLLocationManager()
    var breweries: [Brewery]?
    var breweryID: String!
    var name: String!
    var website: String?
    var imageURLs = [String:String]()
    var savedRegionLoaded = false
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        setUpLocationManager()
        
        let currentLocationButton = MKUserTrackingBarButtonItem.init(mapView: mapView)
        navigationItem.setRightBarButton(currentLocationButton, animated: true)
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
            
        currentLocation = locationManager.location
            
        BreweryDBClient.sharedInstance().getNearbyBreweries(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude) { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(BreweryAnnotation.sharedInstance().annotations!)
                    self.breweries = data
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
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func setUpRegionsForMonitoring() {
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            
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

        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            currentLocation = locationManager.location
            setInitialMapViewRegion()
            getBreweriesCurrentLocation()
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            setInitialMapViewRegion()
            getBreweriesCurrentLocation()
            locationManager.startUpdatingLocation()
            displayError("If you would like to be notified when you're near a brewery, enable Always On location services for Brew Buddy")
        case .denied:
            displayError("Enable locations services for Brew Buddy to find nearby Breweries")
        case .restricted:
            displayError("You are unable to use location serices at this time")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locationManager.location
        //getBreweriesCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("There was an error!")
    }
}

