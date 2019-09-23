//
//  rootMap.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 21/06/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import Alamofire

var resultsViewController: GMSAutocompleteResultsViewController?
var searchController: UISearchController?
var resultView: UITextView?
let frame = UIScreen.main.bounds

class rootMap: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UIToolbarDelegate, DetailPlaceViewControllerDelegate, scheduleViewControllerDelegate, categoryViewControllerDelegate,
GMUClusterRendererDelegate, eventPresentationDelegate {

    
    var polylineArray : [GMSPolyline] = []
    var lastCameraPosition : GMSCameraPosition?
    var locationManager = CLLocationManager()
    var geohashes : [String:AnyObject] = [:]
    var handle : AnyObject?
    var uid : String?
    var choosenDate : Date? = Date()
    private var clusterManager: GMUClusterManager!
    
    var placesMark : [(coordinate : CLLocationCoordinate2D, title: String, idEvent: String, icon : UIImage, category : NSArray)] = []
    
    var notificationBarButtonItem : UIBarButtonItem?
    var currentLoc : CLLocationCoordinate2D?
    var userLocation : CLLocationCoordinate2D?
    let cellReuseIdentifier = "cell"
    var mapView : GMSMapView!
    let sampleTextField = UITextField(frame: CGRect(x: 0, y: 75, width: UIScreen.main.bounds.width, height: 50))
    let tableView = UITableView(frame: CGRect(x: 55, y: 91, width: 250, height: 180))

    // Declaration of Delegate for Semi Modal Presentation
    var dashboardTransitionDelegate: DashboardTransitionDelegate?
    
    // TITLEVIEW NAVIGATION BAR
    var titleViewLabel: UILabel {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.sizeToFit()
        return label
    }
    
    // Declaration of Delegate for Semi Modal Presentation
    var semiModalTransitionDelegate: SemiModalTransitionDelegate?
    var routeModalTransitionDelegate: RouteModalTransitionDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Listener to move into location when event is added
        NotificationCenter.default.addObserver(self, selector: #selector(moveToLocationByCoordinates), name: .eventAdded, object: nil)
        
        // CALL POP UP ADD EVENT DELEGATE
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///////////// A METTRE DANS WILL APPEAR /////////
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                self.uid = user.uid
                self.retrieveNotificationUser()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle! as! AuthStateDidChangeListenerHandle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func loadView() {

        super.loadView()
        
        // DELETE BORDER NAVIGATION BAR
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        // SET TITLEVIEW OF NAVIGATION
        navigationItem.titleView = titleViewLabel
        
        // SET NOTIF ITEM AT RIGHT NAVIGATION
        let notificationButton: UIButton = UIButton(type: .custom)
        //set image for button
        notificationButton.setImage(UIImage(named: "notification"), for: UIControlState.normal)
        //add function for button
        notificationButton.addTarget(self, action: #selector(presentNotificationCenter), for: UIControlEvents.touchUpInside)
        //set frame
        notificationButton.frame = CGRect(x : 0, y : 0, width : 25, height : 25)
        notificationBarButtonItem = UIBarButtonItem(customView: notificationButton)
        let calendarBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar_50.png"), style: .plain, target: self, action: #selector(presentDashbord))
        calendarBarButtonItem.tintColor = .black
        
        // ADD notification button
        navigationItem.rightBarButtonItem = notificationBarButtonItem
        navigationItem.leftBarButtonItem = calendarBarButtonItem
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 45.75, longitude: 4.85, zoom: 14.5)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        //Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
            NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        view = mapView
        
        /// CLUSTERING MAP
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Load Placemark in the database
        //retrievingEventData(Date())

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //print (NSNumber(value: coordinate.latitude).stringValue, NSNumber(value: coordinate.longitude).stringValue)
        print (Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, length: 10))
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let start = Date() // <<<<<<<<<< Start time
        var coordinateHash : [String] = []
        let visibleRegion : GMSVisibleRegion = mapView.projection.visibleRegion()
        let coordinateBounds : GMSCoordinateBounds = GMSCoordinateBounds(region: visibleRegion)
       
        let southWest : CLLocationCoordinate2D = coordinateBounds.southWest
        let northEast : CLLocationCoordinate2D = coordinateBounds.northEast
        let southEast : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: southWest.latitude, longitude: northEast.longitude)
        let northWest : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        /*let n : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: (southWest.longitude + northEast.longitude) / 2)
        let s : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: southWest.latitude, longitude: (southWest.longitude + northEast.longitude) / 2)
        let e : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (northEast.latitude + southWest.latitude) / 2, longitude: northEast.longitude)
        let w : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (northEast.latitude + southWest.latitude) / 2, longitude: southWest.longitude)*/
        
        coordinateHash.append(southWest.geohash(length: 10))
        coordinateHash.append(northEast.geohash(length: 10))
        coordinateHash.append(southEast.geohash(length: 10))
        coordinateHash.append(northWest.geohash(length: 10))
        /*coordinateHash.append(n.geohash(length: 10))
        coordinateHash.append(s.geohash(length: 10))
        coordinateHash.append(e.geohash(length: 10))
        coordinateHash.append(w.geohash(length: 10))*/
        
        let boundingLimits : [String: CLLocationCoordinate2D] = ["nw": northWest, "se": southEast]
        
        var coordinateHashPrefixes : Set<String> = coordinateHash.commonPrefix(coordinateHash)
        let shortestPrefix : String
        
        print (coordinateHashPrefixes, terminator:" ")
        
        /// Si les geohash on aucun prefix commun, donc on prend la première lettre
        if coordinateHashPrefixes.count < 1 {
                shortestPrefix = " "
                var startIndex : String.Index
                var endIndex : String.Index
                
                for hash in coordinateHash{
                    startIndex = hash.index(hash.startIndex, offsetBy: 0)
                    endIndex = hash.index(hash.startIndex, offsetBy: 1)
                    coordinateHashPrefixes.insert(hash.substring(with: Range(startIndex..<endIndex)))
                }
        } else {
            var sPrefixes = Set<String>()
            shortestPrefix = coordinateHashPrefixes.max(by: {$1.count < $0.count})!
            for sPrefix in coordinateHashPrefixes.filter({$0.count == shortestPrefix.count}){
                sPrefixes.insert(sPrefix)
            }
            coordinateHashPrefixes = sPrefixes
        }
        
         print (coordinateHashPrefixes)
        //let longestPrefix : String = coordinateHashPrefixes.max(by: {$1.count > $0.count})!
        //let susbtringPrefix : [String] = shortestPrefix.substringPrefix(string: shortestPrefix, prefixNbrChar: 3)
        
        var prefixCoordinateHash : [String] = []
        /*for coordinate in coordinateHash{
            let startIndex = coordinate.index(coordinate.startIndex, offsetBy: 0)
            var endIndex = coordinate.index(coordinate.startIndex, offsetBy: shortestPrefix.count+1)
            prefixCoordinateHash.append(coordinate.substring(with: Range(startIndex..<endIndex)))
        }*/
        // Set of prefixes
        geohashes.removeAll()
        geohashes = Geohash.proximyHash(prefixGeoboxes: Array(coordinateHashPrefixes)/*[shortestPrefix]*/, cardinalHash: ["nw": northWest.geohash(length: 10), "ne": northEast.geohash(length: 10), "se": southEast.geohash(length: 10), "sw": southWest.geohash(length: 10)], precision:shortestPrefix.count, step: Int(mapView.camera.zoom/4.9), boundingLimits: boundingLimits)
        
        let end = Date()   // <<<<<<<<<<   end time
        let timeInterval: Double = end.timeIntervalSince(start) // <<<<< Difference in seconds (double)
        let alert = UIAlertController(title: "Alert", message: "Time to evaluate function: \(timeInterval) seconds", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        print (geohashes["LPrefix"]!, separator: ".", terminator: ".")
        //self.present(alert, animated: true, completion: nil)
        /// Transform geohashes to NSDictionnary
        
        //print (prefixCoordinateHash, shortestPrefix, shortestPrefix.count, geohashes.keys.sorted().last!, mapView.camera.zoom, geohashes)
        
        
        /// Pretraitement of geohash boxes prefixe
        
        
        
        
        mapView.clear()
        
        let geoH = geohashes["setPositifGeohash"] as! [String]
        for geo in geoH /*[geohashes.keys.sorted().last!]!*/ {
            let decode = Geohash.decode(hash: geo)
            let minLat =  decode?.latitude.min
            let maxLat = decode?.latitude.max
            let minLong = decode?.longitude.min
            let maxLong = decode?.longitude.max
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2D(latitude: maxLat!, longitude: minLong!))
            path.add(CLLocationCoordinate2D(latitude: maxLat!, longitude: maxLong!))
            path.add(CLLocationCoordinate2D(latitude: minLat!, longitude: maxLong!))
            path.add(CLLocationCoordinate2D(latitude: minLat!, longitude: minLong!))
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .brown
            polyline.strokeWidth = 1.0
            polyline.map = mapView
        }
        
        
        // Separate 3 characters string from the other
        //let threeCharPrefixesConcatenated : String = susbtringPrefix.filter{$0.count == 3}.joined(separator: "/")
        //let twoCharPrefix : [String] = susbtringPrefix.filter{$0.count < 3}
        
        let databaseRef = Database.database().reference(withPath: "events/event_location/geohashdata")
        print (databaseRef)
        
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChildren(){
                
                if !self.placesMark.isEmpty{
                    self.placesMark.removeAll()
                    //self.clusterManager.clearItems()
                }
                let start = Date()
                self.treeRecursif(JSONtree: snapshot.value as! NSDictionary, keyPath: "")
                /// DO THE CLUSTERING --> Besoin de vérifier si on a itéré à travers tout l'arbre JSON et d'appeler la
                /// function cluster() une fois que les items ont été rajouté.
                //self.clusterManager.cluster() /// TESTER LA RAPIDITÉ de PLUSIEURS APPELS DE CETTE FONCTION
                let end = Date()   // <<<<<<<<<<   end time
                let timeInterval: Double = end.timeIntervalSince(start) // <<<<< Difference in seconds (double)
                print ("Time to evaluate : \(timeInterval) seconds")
                
            } else {
                return
            }
        })
    
    }
    
    func treeRecursif(JSONtree : NSDictionary, keyPath: String){
        
        let nodes = JSONtree.allValues.count
        var keyPath = keyPath
        let geogeo = geohashes["LPrefix"] as! NSMutableDictionary
        
        if nodes != 0 {
                for (keyTree, valueTree) in JSONtree {
                    
                    /// For the case of keyPath is equal to "" -> Need to be modified
                    if keyPath.count == 0 {
                            for (keyGeo, valueGeo) in geogeo {
                                print(keyTree, keyGeo, keyPath)
                                if (keyTree as AnyObject).hasPrefix(keyGeo as! String){
                                    let newTree = JSONtree[keyTree] as! NSDictionary
                                    
                                    let newKeyPath = keyPath + (keyGeo as! String)
                                    //let queue = DispatchQueue(label: newKeyPath)
                                    
                                    if (valueGeo as AnyObject).count == 0 {
                                     //   queue.async {
                                            self.recursifFindEvent(tree: newTree)
                                        //}
                                    } else {
                                        //queue.async {
                                            self.treeRecursif(JSONtree: newTree, keyPath: newKeyPath)
                                        //}
                                    }
                                }
                            }
                        
                    } else {
                            /// For the case of keyPath is equal to "" -> Need to be modified
                                for (keyGeo, valueGeo) in geogeo.value(forKeyPath: keyPath) as! NSMutableDictionary {
                                    print(keyTree, keyGeo, keyPath)
                                    if (keyTree as AnyObject).hasPrefix(keyGeo as! String){
                                        let newTree = JSONtree[keyTree] as! NSDictionary
                                        
                                        let newKeyPath = keyPath + "." + (keyGeo as! String)
                                        //let queue = DispatchQueue(label: newKeyPath)
                                        
                                        if (valueGeo as AnyObject).count == 0 {
                                            // Do asynchronoulsy because it break the loop when It found the equality
                                            //queue.async {
                                                self.recursifFindEvent(tree: newTree)
                                            //}
                                        } else {
                                            //queue.async {
                                                self.treeRecursif(JSONtree: newTree, keyPath: newKeyPath)
                                            //}
                                        }
                                    }
                                }
                        
                    }
                    
                    
                } // First Loop
        }
    }
    
    func recursifFindEvent(tree: NSDictionary){
        for key in tree.allKeys {
            
            if String(describing: key) == "final"{
                self.addEvent(data : tree[key] as! NSDictionary, date: choosenDate!)
                
            } else {
                let newTree = tree[key] as! NSDictionary
                recursifFindEvent(tree: newTree)
            }
        }
    }
    
    func addEvent(data : NSDictionary, date: Date){
        print (data)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let eventID : String = data["id"] as! String
        let titleEvent : String = data["title"] as! String
        let startDate : Date = dateFormatter.date(from:data["start"] as! String)!
        let formatEndDateToString : String = data["end"] as! String
        let endDate : Date = dateFormatter.date(from: formatEndDateToString)!
        let categoryEvent : NSArray = data["category"] as! NSArray
        let latitude : Double = data["latitude"] as! Double
        let longitude : Double = data["longitude"] as! Double
        let imgName : String = data["image"] as! String

        // If the selected Date is valide between start and end date event
        print (startDate, date, endDate)
            if date >= startDate && date <= endDate{
                
                let place : (coordinate : CLLocationCoordinate2D, title: String, idEvent: String, icon : UIImage, category : NSArray) = (CLLocationCoordinate2D(latitude : latitude, longitude : longitude), titleEvent, String(eventID),UIImage(named: "gray_square.png")!, categoryEvent)
                
                let coord : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: place.coordinate.latitude + 0.0000000001, longitude: place.coordinate.longitude - 0.0000000001)
                
                self.placesMark.append(place)
                let lastMarker = self.addMarkerToMap(coordinates: place.coordinate, image: place.icon, snippet: place.idEvent)
                
                /// Récuperer l'image correspondant à l'évenement -- START -- Async
                
                let storageRef = Storage.storage().reference(forURL: "gs://event-d8731.appspot.com/event/thumbnails/\(imgName)")
                storageRef.getData(maxSize: 1 * 1024 * 1024) { dataImg , error -> Void in
                    print ("Searching for image...")
                        if error != nil {
                            print (error!)    // Uh-oh, an error occurred!
                        } else {
                            var lastPlaceData = self.placesMark.last
                            lastPlaceData?.icon = UIImage(data: dataImg!)!
                            self.updateMarkerImage(marker: lastMarker, image: UIImage(data: dataImg!)!)
                        }
                    }
                
            } else {  print ("No fetched...") }
    }
    
    // Get Place COORDINATE and return a camera
    func moveLocation(placeID: String){
        let placesClient = GMSPlacesClient.shared()
        var location = CLLocationCoordinate2D()
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
    
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            let mapView = self.view as! GMSMapView
            location = CLLocationCoordinate2D(latitude : place.coordinate.latitude, longitude: place.coordinate.longitude)
            mapView.animate(toLocation: location)
        })
    }
    
    @objc func moveToLocationByCoordinates(notification: NSNotification){
        print ("Moving To event now...")
        let dataCoordinates = notification.object as! NSDictionary
        let coordinates : CLLocationCoordinate2D = dataCoordinates["coordinates"] as! CLLocationCoordinate2D
        let zoom : Float = dataCoordinates["zoom"] as! Float
        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: zoom)
        mapView.camera = camera
    }
    
    // MARKER TAP FUNCTION - MapView
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        // Store the current location
        currentLoc = CLLocationCoordinate2D(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
        
        let detailEvent = storyboard!.instantiateViewController(withIdentifier: "infoPlace") as! detailPlaceViewController
        
        // PASS DATA
        // Assign the delegate to get back the name company
        detailEvent.delegate = self
        detailEvent.idEvent = marker.snippet!
        detailEvent.coordinate = marker.position
        
        self.semiModalTransitionDelegate = SemiModalTransitionDelegate(viewController: self, presentingViewController: detailEvent)
        detailEvent.modalPresentationStyle = .custom
        detailEvent.transitioningDelegate = self.semiModalTransitionDelegate
        
        present(detailEvent, animated: true, completion: nil)
        return true
    }

    
    // NOTIFICATION MODAL PRESENTATION
    
    func presentNotificationCenter(_ sender: UINavigationItem){
        let vc = (storyboard?.instantiateViewController(withIdentifier: "notificationCenter"))!
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true, completion: nil)
    }
    
    // USER LOCATION
    
    /*func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.cameraWithLatitude((location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView?.animateToCameraPosition(camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
    }*/
    
    /// Retrieving all unread notification for user - add observer
    func retrieveNotificationUser(){
        let ref = Database.database().reference(withPath: "events").child(uid!).child("notification")
        var count = 0
        ref.observe( .value, with: { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let value = snap.value as! String
                print (value)
                if value != "read"{
                    count += 1
                }
            }
            self.notificationBarButtonItem?.setBadge(text: String(count))
            count = 0
        })
    }
    
    func addMarkerToMap(coordinates: CLLocationCoordinate2D, image: UIImage, snippet: String) -> GMSMarker{
        
        let markerView = UIImageView()
        markerView.backgroundColor = .lightGray
        markerView.frame.size = CGSize(width: 35, height: 35)
        markerView.contentMode = .scaleAspectFit
        markerView.layer.borderColor = UIColor.white.cgColor
        markerView.layer.cornerRadius = markerView.bounds.height / 2
        markerView.clipsToBounds = true
        markerView.layer.borderWidth = 1.5
        
        let marker = GMSMarker(position: coordinates)
        marker.appearAnimation = .pop
        marker.iconView = markerView
        marker.snippet = snippet
        marker.map = mapView
        
        return marker
    }
    
    func updateMarkerImage(marker: GMSMarker, image: UIImage){
        let markerView = UIImageView(image: image)
        markerView.frame.size = CGSize(width: 35, height: 35)
        markerView.contentMode = .scaleAspectFit
        markerView.layer.borderColor = UIColor.white.cgColor
        markerView.layer.cornerRadius = markerView.bounds.height / 2
        markerView.clipsToBounds = true
        markerView.layer.borderWidth = 1.5
        
        marker.iconView = markerView
    }
    
    // Called Twice: Once when add new marker to cluster, and recall once again when cluster() function is called
    /*func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData is POIItem{
            if let userData = marker.userData as? POIItem {
                let imageView = UIImageView(image: userData.imageIcon)
                imageView.frame.size = CGSize(width: 35, height: 35)
                imageView.contentMode = .scaleAspectFit
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.layer.cornerRadius = imageView.bounds.height / 2
                imageView.clipsToBounds = true
                imageView.layer.borderWidth = 1.5
                marker.iconView = imageView
            }
            
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.isFlat = true
            marker.appearAnimation = .pop
        }
        /*else {
            // Apply custom view for cluster
            marker.iconView = ClusterViewIcon()
            
            // Show clusters above markers
            marker.zIndex = 1000;
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.isFlat = true
            marker.appearAnimation = kGMSMarkerAnimationPop
        }*/
    }*/
    
    // DELEGATE FUNCTION OF DETAILPLACEVIEWCONTROLLER
    func passingNameProfil(string: String) {
        showProfilPage(string)
    }
    
    func passingIdEvent(dataDict: NSDictionary, imageFullSizeEvent : UIImage){
        eventOverview(dataDict: dataDict, imageFullSizeEvent: imageFullSizeEvent)
    }
    
    // SHOW PROFIL PAGE
    func showProfilPage(_ data: String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profilView") as! profile
        vc.nameProfil = data
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // SHOW PROFIL PAGE
    func eventOverview(dataDict: NSDictionary, imageFullSizeEvent: UIImage){

        let eventOverview = EventPresenterViewController()
        eventOverview.hidesBottomBarWhenPushed = true
        eventOverview.dataDict = dataDict
        eventOverview.imageFullEvent = imageFullSizeEvent
        //eventOverview.delegate = self
        //eventOverview.idEvent = idEvent
        //eventOverview.coordinate = coordinate
        navigationController?.pushViewController(eventOverview, animated: true)
    }
    
    // DELEGATE OF DASHBORD - PRESENTING
    func presentDashbord(){
        let vc = scheduleViewController()
        vc.choosenDate = choosenDate
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        
        self.dashboardTransitionDelegate = DashboardTransitionDelegate(viewController: self, presentingViewController: nc)
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = self.dashboardTransitionDelegate
        
        present(nc, animated: true, completion: nil)
    }
    
    // DELEGATE OF scheduleViewController
    
    func changeDateEvent(_ date: Date) {
        choosenDate = date
        //retrievingEventData(date)
    }
    
    // DELEGATE OF categoryViewController
    func changeCategoryEvent(_ category: String) {
       // dbShortcut.categoryShortcut.setTitle(category.uppercased(), for: .normal)
        //retrievingEventData(category)
    }
    
    /// CREATE ROUTE BY ALAMOFIRE
    func drawPath(destinationWithCoordinates : CLLocationCoordinate2D, destinationWithString : String)
    {
        
        // Set Left Arrow Back Button in Navigation Item
        let backBarButtonItem = UIBarButtonItem(title: "←" , style: .plain, target: self, action: #selector(cancelShowingPath))
        backBarButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        // Save last Camera Position
        lastCameraPosition = self.mapView.camera
        
        let origin = "\((locationManager.location?.coordinate.latitude)!),\((locationManager.location?.coordinate.longitude)!)"
        let destinationString = "\(destinationWithCoordinates.latitude),\(destinationWithCoordinates.longitude)"
        let destinationCoordinate = CLLocationCoordinate2D(latitude: destinationWithCoordinates.latitude, longitude: destinationWithCoordinates.longitude)
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destinationString)&mode=driving&key=AIzaSyAULqlDxQGW47Rf_8T3ygWrPxyNnh-kDUQ"
        
        Alamofire.request(url).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // HTTP URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            //https://developer.apple.com/swift/blog/?id=37
            if response.result.value != nil {
                let JSONData = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                if let json = JSONData as? [String : Any]{
                    let routes = json["routes"] as! NSArray
                    
                    for route in routes{
                    let r = route as? NSDictionary
                    let routeOverviewPolyline = r!["overview_polyline"] as? NSDictionary
                    let points = routeOverviewPolyline?["points"] as? String
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 3
                        polyline.map = self.mapView
                        self.polylineArray.append(polyline)
                        
                        /// ANIMATING CAMERA
                        let bounds = GMSCoordinateBounds(path: path!)
                        let fitRouteToMap = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50, 50, frame.width/2, 50))
                        self.mapView.animate(with: fitRouteToMap)
                        
                        // Present Route Info
                        self.presentRouteInfo(userCoordinate: (self.locationManager.location?.coordinate)!, destinationAdress: destinationWithString)
                        
                    }
                }
            }
        }
    }
    
    func presentRouteInfo(userCoordinate: CLLocationCoordinate2D, destinationAdress: String){
        
        let routeInfoView = routeInfo()
        routeInfoView.destinationAdress = destinationAdress
        
        self.getAdressByLocation(coordinates: userCoordinate){(adress: String?) -> Void in
            routeInfoView.userAdress = adress
            
            self.routeModalTransitionDelegate = RouteModalTransitionDelegate(viewController: self, presentingViewController: routeInfoView)
            routeInfoView.modalPresentationStyle = .custom
            routeInfoView.transitioningDelegate = self.routeModalTransitionDelegate
            
            self.present(routeInfoView, animated: true, completion: nil)
        }
    }
    
    func getAdressByLocation(coordinates: CLLocationCoordinate2D, result: @escaping (_ adress: String?) -> Void){
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinates) { response, error in
            if error != nil {
                fatalError("Unable to find adress by coordinate \(coordinates)")
            }
            
            if let location = response?.firstResult() {
                let lines = location.lines! as [String] // ["14 Chaussée Yves Kerguélen", "38090 Villefontaine"]
                    let adress = lines[0].uppercased()
                    result(adress)
                }
            }
    }
    
    // Cancel showing the path drawn
    func cancelShowingPath(){
        for poly in polylineArray{
            poly.map = nil
        }
        let calendarBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar_50.png"), style: .plain, target: self, action: #selector(presentDashbord))
        calendarBarButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = calendarBarButtonItem
        self.mapView.animate(to: lastCameraPosition!)
    }
    
// END CODE
}

extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var imageIcon : UIImage
    
    init(position: CLLocationCoordinate2D, name: String, imageIcon : UIImage) {
        self.position = position
        self.name = name
        self.imageIcon = imageIcon
    }
}

extension Array {
    func commonPrefix(_ sender: [String]) -> Set<String> {
        var data : Set = Set<String>()
        print (sender)
        var str = ""
        var compairedStr = ""
        let i = 0

        for i in i...sender.count-1{
            if i < sender.count-1{
                for j in i+1...sender.count-1{
                    compairedStr = sender[j]
                    str = sender[i].commonPrefix(with: compairedStr)
                    if str != ""{data.insert(str)}
                }
            }
        }
        return data
    }
}

extension String {
    
    // Pendant qu'il hash les prefix, il les clash par nil
    
    func substringPrefix(string : String, prefixNbrChar : Int) -> [String]{
        
        let prefix_nbr_car = prefixNbrChar
        var multiple = 1
        var prefix : [String]
        var startIndex : String.Index
        var endIndex : String.Index
        // If prefix < prefixNbrCar
        
        if string.count < prefixNbrChar {
            startIndex = string.index(string.startIndex, offsetBy: 0)
            endIndex = string.index(string.startIndex, offsetBy: string.count)
            prefix = [string.substring(with: Range(startIndex..<endIndex))]
            return prefix
        }
        
        startIndex = string.index(string.startIndex, offsetBy: 0)
        endIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car)
        prefix =  [string.substring(with: Range(startIndex..<endIndex))]
        
        repeat {
            startIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * multiple)
            if prefix_nbr_car * (multiple + 1) <= string.count {
                endIndex = string.index(string.startIndex, offsetBy: prefix_nbr_car * (multiple + 1))
                prefix.append(string.substring(with: Range(startIndex..<endIndex)))
                multiple += 1
            } else {
                /*endIndex = string.index(string.startIndex, offsetBy: string.count)
                prefix.append(string.substring(with: Range(startIndex..<endIndex)))*/
                multiple += 1
            }
            
        } while prefix_nbr_car * multiple < string.count - prefix_nbr_car
        prefix.append(string)
        
        return prefix
    }
}
