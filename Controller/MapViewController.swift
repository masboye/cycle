//
//  MapViewController.swift
//  cycle
//
//  Created by boy setiawan on 15/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class MapViewController: UIViewController {
    
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var initialLocation:CLLocationCoordinate2D!
    var routesPoints:[MKPlacemark] = []
    var isSearchRouteClicked = false
    var isSearchActivityClicked = false
    var userID:String?
    var activityID:String?
    var isActivityOwner = false
    var messageID = 0
    
    let altiMeter = CMAltimeter()
    private var timerForBackground:Timer?
   
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    
    var friends: [Cyclist] = []
    var distanceFromDestination = 0.0
    var timeFromDestination = 0
    
    func notShowMenu(status:Bool){
        self.searchRoute.isHidden = status
        self.searchActivity.isHidden = status
        
    }
    
    func notShowCycling(status:Bool){
        self.finishButton.isHidden = status
        self.sosButton.isHidden = status
        
    }
    
    func showInputDialogActivityShare() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Share Activity", message: "What do you want to do with this route ?", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Delete", style: .default) { (_) in
            
            let kegiatan = Activity()
            
            kegiatan.searchActivity(activityID: self.activityID ?? "") { (activities) in
                
                for activity in activities{
                    activity.deleteData(callback: { (info) in
                        print(info)
                    })
                }
            }
        }
        
        //the confirm action taking the inputs
        let shareAction = UIAlertAction(title: "Share routes", style: .default) { (_) in
            
            //do nothing
            
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(shareAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func finish(_ sender: UIButton) {
        
        notShowMenu(status: false)
        notShowCycling(status: true)
        
        if isActivityOwner{
            showInputDialogActivityShare()
        }
        
    }
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var sosButton: UIButton!
    
    
    @IBAction func sos(_ sender: UIButton) {
        
        showSOSDialog()
    }
    
    func showSOSDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "SOS", message: "Message", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            //getting the input values from user
            let message = alertController.textFields?[0].text
            
            let kegiatan = Activity()
            
            let messageID = Int.random(in: 1...10000)
            
            kegiatan.searchActivity(activityID: self.activityID ?? "") { (activities) in
                
                for activity in activities{
                    //update values
                    activity.ref?.updateChildValues(["message" : message?.trimmingCharacters(in: .whitespacesAndNewlines),"user": self.userID,"messageID":messageID])
                
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Message"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var menuWhenCycling: UIView!
    @IBOutlet weak var searchActivity: UIButton!
    @IBOutlet weak var searchRoute: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
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
        
        let defaults = UserDefaults.standard
        self.userID = defaults.string(forKey: "email")
        
        //set altimeter
        if CMAltimeter.isRelativeAltitudeAvailable(){
            
            altiMeter.startRelativeAltitudeUpdates(to: OperationQueue.current!) { (altiData, error) in
                if let data = altiData{
                    
                    self.altitudeLabel.text = Pretiffy.getAltitude(height: Double(truncating: data.relativeAltitude))
                    
                }
            }
            
        }
        
        self.mapView.register(CyclistView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        guard let timer = self.timerForBackground else {return}
        
        timer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let timer = self.timerForBackground else {return}
        
        backgroundOperation()
        timer.fire()
    }
    
    func showSOSMessage(activity:Activity) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let user = User()
        
        user.searchUser(userID: activity.userID) { (users) in
            
            let user = users.first
            
            let info = "\(user?.fullName ?? "a friend") sends a message '\(activity.message)'"
            let alertController = UIAlertController(title: "SOS", message: info, preferredStyle: .alert)
            
            //the confirm action taking the inputs
            let confirmAction = UIAlertAction(title: "Show Location", style: .default) { (_) in
                
                self.performSegue(withIdentifier: "showRoute", sender: activity )
            }
            
            //        //the cancel action doing nothing
            let cancelAction = UIAlertAction(title: "Acknowledge", style: .cancel) { (_) in
                
                self.messageID = activity.messageID
                
            }
            
            //adding the action to dialogbox
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        }
        //
        
    }
    
     //MARK:- backGround
    func backgroundOperation(){
        
        //background operation
        self.timerForBackground = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (time) in
            
            let kegiatan = Activity()
            
            kegiatan.searchActivity(activityID: self.activityID ?? "") { (activities) in
                
                for activity in activities{
                    if  activity.messageID != self.messageID { //&& self.userID != activity.userID 
                        //new sos message
                        self.showSOSMessage(activity: activity)
                        
                    }
                }
            }
            
             //MARK:- Real Time Location
            //send treal time location
            let user = User()
            
            user.searchUser(userID: self.userID!, callback: { (users) in
                //cyclist.ref?.updateChildValues(["activity" : self.activityID!,"point" : 0])
                //"\(location.latitude),\(location.longitude)"
                users.first?.ref?.updateChildValues(["location":"\(self.initialLocation.latitude),\(self.initialLocation.longitude)"])
            })
            
             //MARK:- Get Friends Location
            self.mapView.removeAnnotations(self.friends)
            self.friends = []
            
            user.searchActivity(activity: self.activityID ?? "", callback: { (users) in
                for cyclist in users{
                    
                    if cyclist.userID != self.userID{
                        self.friends.append(Cyclist(user: cyclist)!)
                    }
                    
                }
                
                self.mapView.addAnnotations(self.friends)
                
                 //MARK:- Detect distance between check point in route
                
                var point = 0
                for (index, element) in self.routesPoints.enumerated() {
                    
                    guard let distance = element.location?.distance(from: CLLocation(latitude: self.initialLocation.latitude, longitude: self.initialLocation.longitude)) else {
                        return
                    }
                    
                    if distance < 50 {
                        point = index
                    }
                }
                
                user.searchUser(userID: self.userID!) { (users) in
                    users.first?.ref?.updateChildValues(["point": point])
                }
                
                //MARK:- calculating distance to destination
                let checkPointPassed = self.routesPoints[point...]
                //nedd to do this because the array slice cannot automatically converted
                let checkDistance = Array(checkPointPassed)
                 self.mapView.removeOverlays(self.mapView.overlays)
                self.drawRoutes(routes: checkDistance, draw: true)
                
            })
           
            
        }
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
            self.activityID = "\(name!.uppercased())\(Int.random(in: 1...10000))"
            
            self.navigationItem.prompt = self.activityID ?? "tes"
            
            let activity = Activity(id: self.activityID!.trimmingCharacters(in: .whitespacesAndNewlines), routes: routesShared)
            
            activity.insertData { (info) in
                let alert = UIAlertController(title: "Routes",message: info,preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
            }
            
            //join the user in the activity
            let user = User()
            
            user.searchUser(userID: self.userID!) { (users) in
                
                for cyclist in users{
                    
                    cyclist.ref?.updateChildValues(["activity" : self.activityID!,"point" : 0])
                }
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
            
            //join the user in the activity
            let user = User()
            
            user.searchUser(userID: self.userID!) { (users) in
                
                for cyclist in users{
                    
                    cyclist.ref?.updateChildValues(["activity" : self.activityID!,"point" : 0])
                }
            }
            
            navigationItem.titleView = nil
            self.navigationItem.prompt = self.activityID
            
            notShowMenu(status: true)
            notShowCycling(status: false)
            
            backgroundOperation()
            guard let timer = self.timerForBackground else {return}
            timer.fire()
            
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
            
            if self.routesPoints.count > 0{
                
                showInputDialog()
            }
            //set owner of activity
            isActivityOwner = true
            
            notShowMenu(status: true)
            notShowCycling(status: false)
            
            navigationItem.titleView = nil
            
            
            backgroundOperation()
            guard let timer = self.timerForBackground else {return}
            timer.fire()
            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard (sender as? URL) != nil else {return}
        guard let result = sender as? Activity else {return}
        
        let controller = segue.destination
        let showRoute = controller as! ShowRouteViewController
        showRoute.messageID = self.messageID
        showRoute.friend = result
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
            //print("location.speed = \(Pretiffy.getSpeed(speed: location.speed))")
            self.speedLabel.text = Pretiffy.getSpeed(speed: location.speed)
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
        
        self.navigationItem.prompt = nil
        self.isActivityOwner = false
        
        guard let timer = self.timerForBackground else {return}
        timer.invalidate()

    }
    
    func addPinInMap(placemark:MKPlacemark){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let _ = placemark.locality,
            let _ = placemark.administrativeArea {
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
        drawRoutes(routes: self.routesPoints)
    }
    
    func drawRoutes(routes:[MKPlacemark],draw:Bool = true) {
        
        self.distanceFromDestination = 0.0
        self.timeFromDestination = 0
        let sourcePlaceMark = MKPlacemark(coordinate: initialLocation)
        
        for point in routes{

            let directionRequest = MKDirections.Request()
            var source = MKMapItem(placemark: sourcePlaceMark)

            directionRequest.source = source
            directionRequest.destination = MKMapItem(placemark: point)
            directionRequest.transportType = .any

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
                
                //test
                self.distanceFromDestination += route.distance
                self.timeFromDestination += Int (route.expectedTravelTime)
                //print("distance = \(self.distanceFromDestination)")
                print("eta = \(route.expectedTravelTime)")
                DispatchQueue.main.async(execute: {
                    self.distanceLabel.text = "\(Pretiffy.getDistance(distance: self.distanceFromDestination))"
                    self.etaLabel.text = "\(Pretiffy.getETA(seconds: self.timeFromDestination))"
                })
                //end

                if draw{

                    //add rout to our mapview
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                    //setting rect of our mapview to fit the two locations
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)

                }
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
        self.activityID = activity.activityID
        drawRoutes(routes: self.routesPoints)
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
        renderer.strokeColor = RandomHelper.generateRandomColor()
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Cyclist
        //let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        //location.mapItem().openInMaps(launchOptions: launchOptions)
        print(location)
        
    }
}

extension MapViewController: UIGestureRecognizerDelegate{
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            
                let touchLocation = gestureReconizer.location(in: mapView)
                let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
                //print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
                let point = MKPlacemark(coordinate: locationCoordinate)
            
                if routesPoints.first(where: { $0.coordinate.latitude == point.coordinate.latitude && $0.coordinate.longitude == point.coordinate.longitude }) != nil{
                   
                    return
                }
                //print("ADD")
                addPinInMap(placemark: point)
                self.routesPoints.append(point)
                drawRoutes(routes: self.routesPoints)
               
                return
            
        }
        
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            
            return
        }
    }
}
    

