//
//  MapViewController.swift
//  cycle
//
//  Created by boy setiawan on 15/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var initialLocation:CLLocationCoordinate2D!
    var routesPoints:[MKPlacemark] = []
    var isSearchRouteClicked = false
    var isSearchActivityClicked = false
   
    
    @IBOutlet weak var searchActivity: UIButton!
    @IBOutlet weak var searchRoute: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //show user location
        mapView.showsUserLocation = true
        //set delegate for mapview
        self.mapView.delegate = self
        
        //set tap location in map view
        let selectLocationTap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        selectLocationTap.minimumPressDuration = 1.5
        selectLocationTap.delaysTouchesBegan = true
        selectLocationTap.delegate = self
        self.mapView.addGestureRecognizer(selectLocationTap)
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter Activity Name", message: "Enter activity name", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text
            
            var routesShared:[CLLocationCoordinate2D] = []
            
            for route in self.routesPoints{
                routesShared.append(route.coordinate)
            }
            let activityName = "\(name!.uppercased())\(Int.random(in: 1...10000))"
            let activity = Activity(id: activityName.trimmingCharacters(in: .whitespacesAndNewlines), routes: routesShared)
            
            activity.insertData { (info) in
                let alert = UIAlertController(title: "Routes",message: info,preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        //alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func searchActivity(_ sender: UIButton) {
        
        if isSearchActivityClicked{
            
            isSearchActivityClicked = false
            self.searchActivity.setTitle("Activity", for: .normal)
            
            let alert = UIAlertController(title: "Start Activity",message: "Let's Go",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            
            navigationItem.titleView = nil
            
        }else{
            let activitySearchTable = storyboard!.instantiateViewController(withIdentifier: "ActivitySearchTable") as! SearchActivityViewController
            resultSearchController = UISearchController(searchResultsController: activitySearchTable)
            resultSearchController?.searchResultsUpdater = activitySearchTable
            resultSearchController?.searchBar.delegate = activitySearchTable
            
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for activities"
            navigationItem.titleView = resultSearchController?.searchBar
            
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            self.searchActivity.setTitle("Start Route", for: .normal)
            isSearchActivityClicked = true
            activitySearchTable.handleActivitySearchDelegate = self
            cancelRoutes()
        }
        
    }
    @IBAction func search(_ sender: UIButton) {
        
        if isSearchRouteClicked{
            
            isSearchRouteClicked = false
            self.searchRoute.setTitle("New Route", for: .normal)
            
            showInputDialog()
            navigationItem.titleView = nil
            
        }else{
            let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchRouteViewController
            resultSearchController = UISearchController(searchResultsController: locationSearchTable)
            resultSearchController?.searchResultsUpdater = locationSearchTable
            resultSearchController?.searchBar.delegate = locationSearchTable
            
            let searchBar = resultSearchController!.searchBar
            searchBar.sizeToFit()
            searchBar.placeholder = "Search for places"
            navigationItem.titleView = resultSearchController?.searchBar
            
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
            
            locationSearchTable.mapView = mapView
            locationSearchTable.handleMapSearchDelegate = self
            isSearchRouteClicked = true
            self.searchRoute.setTitle("Share Route", for: .normal)
            cancelRoutes()
        }
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.initialLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension MapViewController: HandleMapSearch {
    
    func cancelRoutes() {
        self.routesPoints = []
        self.mapView.removeOverlays(self.mapView.overlays)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: initialLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        
    }
    
    func addPinInMap(placemark:MKPlacemark){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
    }
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        addPinInMap(placemark: placemark)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        self.routesPoints.append(placemark)
        drawRoutes()
    }
    
    func drawRoutes(){
        
        let sourcePlaceMark = MKPlacemark(coordinate: initialLocation)
        
        let directionRequest = MKDirections.Request()
        var source = MKMapItem(placemark: sourcePlaceMark)
        
        for point in routesPoints{
            
            directionRequest.source = source
            directionRequest.destination = MKMapItem(placemark: point)
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                    }
                    return
                }
            
            //get route and assign to our route variable
            let route = directionResonse.routes[0]
            
            //add rout to our mapview
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            //setting rect of our mapview to fit the two locations
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
            
            source = MKMapItem(placemark: point)
            
        }
        

    }
}

extension MapViewController:HandleActivitySearch{
    func dropActivity(activity: Activity) {
        
        self.routesPoints = []
        for point in activity.routes{
            let placemark = MKPlacemark(coordinate: point)
            routesPoints.append(placemark)
            addPinInMap(placemark: placemark)
        }
        drawRoutes()
    }
    
    func cancelActivity() {
        navigationItem.titleView = nil
        isSearchActivityClicked = false
        self.searchActivity.setTitle("Activity", for: .normal)
        cancelRoutes()
        
    }
    
}

extension MapViewController: MKMapViewDelegate{
    
    //MARK:- MapKit delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate{
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            
                let touchLocation = gestureReconizer.location(in: mapView)
                let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
                //print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
                let point = MKPlacemark(coordinate: locationCoordinate)
                if let index = routesPoints.first(where: { $0.coordinate.latitude == point.coordinate.latitude && $0.coordinate.longitude == point.coordinate.longitude }){
                   
                    return
                }
                //print("ADD")
                addPinInMap(placemark: point)
                self.routesPoints.append(point)
                drawRoutes()
               
                return
            
        }
        
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            
            return
        }
    }
}
    

