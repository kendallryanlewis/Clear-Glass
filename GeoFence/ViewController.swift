//import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import UserNotifications
import MapKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import FirebaseDatabase
import FirebaseAuth
import LifetimeTracker


/************** Check leaks in class ****************/
class DetailItem: LifetimeTrackable {
    
    class var lifetimeConfiguration: LifetimeConfiguration {
        // There can be up to three 3 instances from the class. But only three in total including the subclasses
        return LifetimeConfiguration(maxCount: 3, groupName: "Detail Item", groupMaxCount: 3)
    }
    init() {
        self.trackLifetime()
    }
}

/***************** Global Variables ******************/
let notification = UINotificationFeedbackGenerator() //haptic feedback generator
var ref: DatabaseReference!

/**************** Store regions lists ****************/
var regionList = [createRegion]()
class createRegion{
    var longitude = ""
    var latitude = ""
    var location = ""
    var header = ""
    var notes = [noteDisplay]()
    var address = ""
    init(longitude: String, latitude: String, location: String, header: String, notes: [noteDisplay], address: String) {
        self.longitude = longitude
        self.latitude = latitude
        self.location = location
        self.header = header
        self.notes = notes
        self.address = address
        print("\(header) is being initialized.")
    }
    deinit {
        print("create region has been deallocted")
    }
}

class ViewController: UIViewController, NSUserActivityDelegate, UITextFieldDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, ModalTransitionListener{
    /*********************************************************************/
    /******************************** Outlets ****************************/
    /*********************************************************************/
    //system page view
    @IBOutlet var pageView: UIView!
    //main View container
    @IBOutlet weak var mainView: UIView!
    //geo map view
    @IBOutlet weak var geoMapView: MKMapView!
    //main google map
    @IBOutlet weak var mapView: GMSMapView!
    //Menu button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //menu view container
    @IBOutlet weak var menuView: UIView!
    //trailing border of main view
    @IBOutlet weak var trailingConstraints: NSLayoutConstraint!
    //leading border of main view
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    //Accent menu view
    @IBOutlet weak var accentView: UIView!
    //Accent trailing constraint
    @IBOutlet weak var accentTrailingConstraint: NSLayoutConstraint!
    //Accent leading constraint
    @IBOutlet weak var accentLeadingConstraint: NSLayoutConstraint!
    //Accent 2 menu view
    @IBOutlet weak var secondAccentView: UIView!
    //leading constraint for accent 2
    @IBOutlet weak var secondAccentLeadingConstraint: NSLayoutConstraint!
    //trailing contraint for accent 2
    @IBOutlet weak var secondAccentTrailingConstraint: NSLayoutConstraint!
    //menu table view
    @IBOutlet weak var menuTableView: UITableView!
    //Search table View
    @IBOutlet weak var searchTableView: UITableView!
    //search button
    @IBOutlet weak var searchButton: UIButton!
    //return button
    @IBOutlet weak var returnButton: UIButton!
    //Drop down search area
    @IBOutlet weak var searchView: UIView!
    //search bar field
    @IBOutlet weak var searchField: UIView!
    //search text
    @IBOutlet weak var searchBar: UITextField!
    //Hide search table view
    @IBOutlet weak var hideSearchTable: UIButton!
    //note view display
    @IBOutlet weak var noteView: UIView!
    //noteview table view
    @IBOutlet weak var noteTableView: SelfSizedTableView!
    //note view return home button
    @IBOutlet weak var returnHomeButton: UIButton!
    //Add note button
    @IBOutlet weak var addNoteButton: UIButton!
    //Add version Number
    @IBOutlet weak var versionNumber: UILabel!
    
    /*********************************************************************/
    /****************************** Variables ****************************/
    /*********************************************************************/
    //set map angle
    var mapViewAngle: Int? = 90
    //set menu to close
    var menuIsVisible: Bool? = false
    //set to location manager to location manager function
    var locationManager = CLLocationManager()
    //set the current location of the user
    var currentLocation: CLLocation!
    //long press recognizer
    var longPressRecognizer = UILongPressGestureRecognizer()
    //set geofence to not display
    var geofenceDisplay: Bool? = false
    //Determine if map has been set
    var mapSet: Bool? = false
    //Results array
    var resultsArray:[Dictionary<String, AnyObject>] = Array()
    //Set firebase database
    let db = Database.database().reference()
    //set location string
    var location:String = "" //User Identification
    //Set current address
    var currentAddress : String = ""
    //Set current Location
    var currentLoc : String = ""
    //tapped marker variable
    var tappedMarker : GMSMarker?
    //custom window varibale
    var customInfoWindow : locationView?
    //location view xib image
    var locationView = Bundle.main.loadNibNamed("customInfoWindow", owner: self, options: nil)?.first as? locationView
    //appVersion number
    var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    
    
    /*********************************************************************/
    /************************ View Loading screen  ***********************/
    /*********************************************************************/
    override func viewWillAppear(_ animated: Bool) {
        //print("view wiill appear!")
       // loadViewController()
    }
    override func viewDidAppear(_ animated: Bool) {
            loadViewController()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        loadViewController()
    }
    //required delegate func
    func popoverDismissed() {
        performSegue(withIdentifier: "mainToConfirmation", sender: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
        /*********************** Menu View **********************/
        menuTableView.reloadData()
        print("This is the system name \(systemCollection!.systemName)")
    }
    /*********************************************************************/
    /************************ Load View Controller ***********************/
    /*********************************************************************/
    func loadViewController(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in } //create user notification
        
        /*********************** Parallax ***********************/
        //parallax()
        dump(menuList)
        /***************** Transparent nav bar ******************/
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        /***************** System background view ******************/
        pageView.layer.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
        menuButton.tintColor = UIColor().HexToColor(hexString: colorCollection!.systemMenuButton, alpha: 1.0)
        
        /******************* Location manager *******************/
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location
        locationManager.distanceFilter = 50
        
        /*********************** Search Field View **********************/
        
        searchBar.isHidden = false
        searchBar.delegate = self
        searchField.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        searchField.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)//sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        searchField.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchView.isHidden = true //hide searchbar until called
        hideSearchTable.isHidden = true //hide return to home button
        searchView.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        searchView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        searchView.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        searchField.layer.cornerRadius = 8.0
        searchButton.roundCorners(corners: [.topRight,.bottomRight], radius: 8.0) //remove rounded corner
        searchView.layer.cornerRadius = 8.0
        /*********************** note table view **********************/
        noteTableView.delegate = self
        noteTableView.dataSource = self
        noteTableView.estimatedRowHeight = 105.5
        noteTableView.maxHeight = 500
        noteTableView.translatesAutoresizingMaskIntoConstraints = false
        noteTableView.roundCorners(corners: [.topRight, .topLeft], radius: 8.0)
        addNoteButton.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
        noteView.isHidden = true // hide note view to start
        returnHomeButton.layer.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
        returnHomeButton.layer.opacity = 0.9
        /*********************** Main View **********************/
        mainView.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        mainView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        mainView.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        mainView.layer.shadowRadius = 20 //sets how wide the shadow should be
        /*********************** Accent Views **********************/
        accentView.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        accentView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        accentView.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        accentView.layer.shadowRadius = 20 //sets how wide the shadow should be
        secondAccentView.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        secondAccentView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        secondAccentView.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        secondAccentView.layer.shadowRadius = 20 //sets how wide the shadow should be
        
        mapView.delegate = self
        mapView.isBuildingsEnabled = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.scrollGestures = true//add to settings page
        mapView.settings.tiltGestures   = false //add to settings page
        mapView.settings.rotateGestures = true //add to settings page
        
        /******************* Geofence Map View ******************/
        geoMapView.isHidden = true //Hide behind main map view
        geofenceDisplay = true //Set geofence to not display variable
        geoMapView.delegate = self
        geoMapView.showsUserLocation = true //Display user location
        geoMapView.userTrackingMode = .follow //follow user location
        
        /******************** Menu table View ********************/
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        menuView.isHidden = true//hide menu
        accentView.isHidden = true//hide menu
        secondAccentView.isHidden = true//hide menu
        menuTableView.isHidden = true
        versionNumber.text = appVersion //add version number to menu
        
        /******************** long press gesture ******************/
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.addRegion))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delegate = self
        mapView.addGestureRecognizer(longPressRecognizer)
        
        /****************** return button pressed *****************/
        returnButton.isHidden = true //return button is hidden
        
        /***************** Functions ******************/
        createMapView() //Create map for view
        addMarker() //Set marker to display
    }
    
    /*********************************************************************/
    /**************************** Create map view ************************/
    /*********************************************************************/
    func createMapView() {
        /******************* Google Map View ********************/
        if currentLocation != nil {
            currentLocation = locationManager.location
            mapView.camera = GMSCameraPosition.camera(withLatitude: Double((locationManager.location?.coordinate.latitude)!), longitude: Double((locationManager.location?.coordinate.longitude)!), zoom: 18, bearing: 0, viewingAngle: Double(mapCollection!.system3DDisplay))
            mapView.mapStyle(withFilename: mapCollection!.systemMapView, andType: "json")
            UIView.animate(withDuration: 0.5) {//slide animation
                self.mapView.animate(toZoom: 18)
            }
        }else{
            print("Map View cannot be displayed")//Transition to mapView can not be displayed page
        }
    }
    
    /*********************************************************************/
    /*********************** Add Markers to map view *********************/
    /*********************************************************************/
    func addMarker() {
        var markerIndex = 0
        for items in regionList{
            if items != nil{
                locationManager.delegate = self
                let header = items.header
                let marker = GMSMarker() //create new marker
                let longitude:Double = Double(items.longitude)!
                let latitude:Double = Double(items.latitude)!

                // I have taken a pin image which is a custom image
                let markerImage = UIImage(named: "markerIcon")!
                //creating a marker view
                let markerView = UIImageView(image: markerImage)
                //changing the tint color of the image
                markerView.tintColor = UIColor().HexToColor(hexString: "853737", alpha: 1.0)

                marker.iconView = markerView
                marker.title = items.header
                marker.snippet = items.address//"View Notes: \(items.notes.count)"
                marker.position = CLLocationCoordinate2DMake(latitude, longitude)
                marker.map = mapView
                
                //marker.icon = GMSMarker.markerImage(with: UIColor().HexToColor(hexString: "#404040", alpha: 1.0))
                marker.appearAnimation = .pop
                marker.tracksInfoWindowChanges = true //allow info window to change
                marker.accessibilityLabel = String(markerIndex)
                markerIndex = markerIndex + 1
                marker.accessibilityElements = [header, items.location, latitude, longitude]
                
                let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(mapCollection!.systemGeofenceArea), identifier: header)
                locationManager.startMonitoring(for: region)
                let geoCircle = MKCircle(center: coordinate, radius: region.radius)
                geoMapView.addOverlay(geoCircle)
                
                self.tappedMarker = marker
                self.locationView = locationView!.loadView()
            }
        }
    }
    
    /*********************************************************************/
    /**************************** Marker tapped **************************/
    /*********************************************************************/
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        locationView!.removeFromSuperview()
        locationView!.locationTitle.text = marker.title
        //locationView!.locationDate.text = marker.snippet
        for (element, item) in regionList.enumerated(){
            if String(marker.title!) == item.header{
                locationView!.locationNotes.text = String(item.notes.count)
                locationView!.locationIndex.text = String(element + 1)
            }
        }
        locationView!.notesView.roundCorners(corners: [.topRight,.bottomRight], radius: 8.0) //remove rounded corner
                locationView!.locationTitle.textColor = UIColor().HexToColor(hexString: "#000000", alpha: 1.0)
        //locationView!.locationDate.textColor = UIColor().HexToColor(hexString: "#404040", alpha: 1.0)
        locationView!.locationNotes.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
        locationView!.locationIndex.textColor = UIColor().HexToColor(hexString: "#404040", alpha: 1.0)
        locationView!.tabBackground.backgroundColor = UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)
        locationView!.layer.opacity = 0.95
        locationView!.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
        locationView!.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
        locationView!.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
        //locationView!.layer.shadowRadius = 5 //sets how wide the shadow should be
        view.addSubview(locationView!) //Add this to enable Feature to display in scrollview
        return false
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        locationView!.removeFromSuperview()
        return self.locationView
    }
    // take care of the close event
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
       locationView!.removeFromSuperview()
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        markerTapped(header: String(marker.title!))
    }
    func markerTapped(header: String){
        notesViewController().displayNotes(header: header)
        selectedLocation = header
        noteTableView.reloadData()
        noteView.isHidden = false
        let when = DispatchTime.now() + 30
        DispatchQueue.main.asyncAfter(deadline: when){
            self.noteView.isHidden = true
        }
        showNotification(title: header, items: description.count)//Display notification if app is closed
    }

    /*********************************************************************/
    /*********************** Click the search button *********************/
    /*********************************************************************/
    @IBAction func searchButton(_ sender: Any) {
        searchBar.resignFirstResponder() //clear keyboard
        searchGoogleMaps(place: searchBar.text!) //Find location
    }
    
    @IBAction func donePressed(_ sender: Any) {
        print("done")
        searchBar.resignFirstResponder()
        searchGoogleMaps(place: searchBar.text!) //Find location
    }
    
    /*********************************************************************/
    /************************** Search google maps ***********************/
    /*********************************************************************/
    func searchGoogleMaps(place:String){
        let long = (locationManager.location?.coordinate.latitude)!
        let lat = (locationManager.location?.coordinate.longitude)!
        var textGoogleApi = "https://maps.googleapis.com/maps/api/place/textsearch/json?location=\(lat),\(long)&query=\(place)&key= AIzaSyAfK-_j0Va1EFO-Kg63VVVeSV0zuASh6gg"
        textGoogleApi = textGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var urlRequest = URLRequest(url: URL(string: textGoogleApi)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if error == nil {
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                //print ("Json == \(jsonDict)")
                self.resultsArray.removeAll() //clear array
                if let dict = jsonDict as? Dictionary<String, AnyObject> {
                    if let results = dict["results"] as? [Dictionary<String, AnyObject>] {
                        for item in results{
                            self.resultsArray.append(item)
                            //dump(self.resultsArray)
                        }
                        if self.resultsArray.count == 0{
                            //Do nothing
                            print("no items found")
                            //Add text to say "Location not found"
                        } else if self.resultsArray.count == 1{
                            //go straight to the location
                            DispatchQueue.main.async {
                                self.getSearchLocation(indexPath: 0)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.searchTableView.reloadData()
                                self.searchView.isHidden = false //show searchbar until
                                self.hideSearchTable.isHidden = false //show searchbar until called
                            }
                        }
                    }
                }
            } else {
                //There is an error
                print("There is a search maps error")
            }
        }
        task.resume()
    }
    
    /*********************************************************************/
    /************************ Populate Search table **********************/
    /*********************************************************************/
    func getSearchLocation(indexPath: Int){
        let place = self.resultsArray[indexPath]
        if let locationGeometry = place["geometry"] as? Dictionary<String, AnyObject>{
            if let location = locationGeometry["location"] as? Dictionary<String, AnyObject> {
                if let latitude = location["lat"] as? Double {
                    if let longitude = location["lng"] as? Double {
                        self.searchView.isHidden = true //show searchbar until
                        self.hideSearchTable.isHidden = true //show searchbar until called
                        mapView.camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 18, bearing: 0, viewingAngle: Double(mapCollection!.system3DDisplay))
                    }
                }
            }
        }
    }
    
    /*********************************************************************/
    /************** Click background to hide search table ****************/
    /*********************************************************************/
    @IBAction func hideSearchView(_ sender: Any) {
        searchView.isHidden = true //hide search table view
        hideSearchTable.isHidden = true
        print("hide search iew")
    }
    
    /*********************************************************************/
    /************************ Click the menu button **********************/
    /*********************************************************************/
    @IBAction func menuButtonTapped(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        if menuIsVisible == false{ //If menu is not visible, display menu (OPENED)
            openMenu() //Open menu
            swipeLeftMenu()
        }else{//if menu is visible move the menu back (CLOSED)
            closeMenu() //Close Menu
        }
    }
    
    /*********************************************************************/
    /************ Click the map from the menu  to close menu  ************/
    /*********************************************************************/
    @IBAction func returnMainButton(_ sender: Any) {
        closeMenu() //Close Menu
    }
    
    /*********************************************************************/
    /*********************** Swipe Left to close Menu ********************/
    /*********************************************************************/
    func swipeLeftMenu(){
        /******************** swipe gesture ******************/
        //let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        //let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        //swipeLeft.direction = UISwipeGestureRecognizer.Direction.right
        //swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    /*********************************************************************/
    /******************************* Open Menu ***************************/
    /*********************************************************************/
    func openMenu(){
        print("menu Active")
        navigationItem.leftBarButtonItem?.isEnabled = false
        menuIsVisible = true //set main menu to false
        menuTableView.isHidden = false
        menuButton.tintColor =  UIColor().HexToColor(hexString: "#00FFFFFF", alpha: 0.0) // hide menu button
        /******** menu *******/
        self.menuView.frame.origin.x -= 500
        leadingConstraints.constant = 0 //shift
        trailingConstraints.constant = 0//shift
        menuView.isHidden = false
        mainView.layer.cornerRadius = 4.0
        let scaledTransform = self.mainView.transform.scaledBy(x: 0.8, y: 0.8)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: 0.0)
        /******** accent one menu *******/
        accentLeadingConstraint.constant = 0 //shift
        accentTrailingConstraint.constant = 0//shift
        accentView.isHidden = false
        let accentScaledTransform = self.accentView.transform.scaledBy(x: 0.7, y: 0.7)
        let accentScaledAndTranslatedTransform = accentScaledTransform.translatedBy(x: 0.0, y: 0.0)
        accentView.layer.cornerRadius = 4.0
        /******** accent two menu *******/
        secondAccentLeadingConstraint.constant = 0 //shift
        secondAccentTrailingConstraint.constant = 0//shift
        secondAccentView.isHidden = false
        let secondAccentScaledTransform = self.accentView.transform.scaledBy(x: 0.6, y: 0.6)
        let secondAccentScaledAndTranslatedTransform = secondAccentScaledTransform.translatedBy(x: 0.0, y: 0.0)
        secondAccentView.layer.cornerRadius = 4.0
        returnButton.isHidden = false
        
        UIView.animate(withDuration: 0.7) {//slide animation
            self.mainView.transform = scaledAndTranslatedTransform
            self.mainView.frame.origin.x += 300 //change the slide view for the menu
        }
        UIView.animate(withDuration: 0.72) {//slide animation
            self.accentView.transform = accentScaledAndTranslatedTransform
            self.accentView.frame.origin.x += 250 //change the slide view for the menu
        }
        UIView.animate(withDuration: 0.74) {//slide animation
            self.secondAccentView.transform = secondAccentScaledAndTranslatedTransform
            self.secondAccentView.frame.origin.x += 200 //change the slide view for the menu
        }
        UIView.animate(withDuration: 0.75) {//slide animation
            self.menuView.frame.origin.x += 500
        }
    }
    
    /*********************************************************************/
    /******************************* Close Menu **************************/
    /*********************************************************************/
    func closeMenu(){
        print("close menu")
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem = menuButton
        menuButton.tintColor =  UIColor().HexToColor(hexString: colorCollection!.systemMenuButton, alpha: 1.0)
        self.menuView.frame.origin.x += 500
        leadingConstraints.constant = 0 //reset main menu back to zero
        trailingConstraints.constant = 0 // reset main menu back to zero
        menuIsVisible = false //set main menu to false
        menuView.isHidden = true//hide menu
        mainView.layer.cornerRadius = 0.0
        returnButton.isHidden = true
        let scaledTransform = self.mainView.transform.scaledBy(x: 1.25, y: 1.25)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: 0.0)
        
        accentLeadingConstraint.constant = 0 //shift
        accentTrailingConstraint.constant = 0//shift
        accentView.isHidden = true
        let accentScaledTransform = self.accentView.transform.scaledBy(x: 1.428, y: 1.428)
        let accentScaledAndTranslatedTransform = accentScaledTransform.translatedBy(x: 0.0, y: 0.0)
        accentView.layer.cornerRadius = 0.0
        
        secondAccentLeadingConstraint.constant = 0 //shift
        secondAccentTrailingConstraint.constant = 0//shift
        secondAccentView.isHidden = true
        let secondAccentScaledTransform = self.secondAccentView.transform.scaledBy(x: 1.60, y: 1.60)
        let secondAccentScaledAndTranslatedTransform = secondAccentScaledTransform.translatedBy(x: 0.0, y: 0.0)
        secondAccentView.layer.cornerRadius = 0.0
        
        UIView.animate(withDuration: 0.3) { //slide animation
            self.mainView.transform = scaledAndTranslatedTransform
            self.accentView.transform = accentScaledAndTranslatedTransform
            self.secondAccentView.transform = secondAccentScaledAndTranslatedTransform
            self.mainView.frame.origin.x -= 300 //change the slide view for the menu
            self.accentView.frame.origin.x -= 250 //change the slide view for the menu
            self.secondAccentView.frame.origin.x -= 200 //change the slide view for the menu
        }
        UIView.animate(withDuration: 0.3) { //slide animation
            self.menuView.frame.origin.x -= 500
        }
    }
    
    /*********************************************************************/
    /************************* Add regions to map  ***********************/
    /*********************************************************************/
    @IBAction func addRegion(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began  && menuIsVisible == false { //run action right after long press
            notification.notificationOccurred(.success) //haptic feedback
            let coordinate = mapView.projection.coordinate(for: sender.location(in: mapView))//geoMapView.convert(touchLocation, toCoordinateFrom: mapView)
            let holder = "geofence" + String(coordinate.latitude)
            let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(mapCollection!.systemGeofenceArea), identifier: holder)
            locationManager.startMonitoring(for: region)
            let geoCircle = MKCircle(center: coordinate, radius: region.radius)
            let newMarker = GMSMarker(position: mapView.projection.coordinate(for: sender.location(in: mapView))) //Create a new marker
            createdLocation.removeAll()
            createdLocation.append(tempLocation(longitude: String(coordinate.longitude), latitude: String(coordinate.latitude), address: currentAddress, location: currentLoc))
            getLocationAddress(longitude: String(coordinate.longitude), latitude: String(coordinate.latitude))
            self.geoMapView.addOverlay(geoCircle)
            newMarker.map = self.mapView //Add new marker to view
            self.performSegue(withIdentifier: "mainToAddLocation", sender: nil) //segue to the main screen
            mapView.clear() //clear map view
            addMarker() //add marker to map view
            print("Location saved successfully!")
        }
    }
    
    /*********************************************************************/
    /**************** Return to home screen  ****************/
    /*********************************************************************/
    @IBAction func returnHome(_ sender: Any) {
        self.noteView.isHidden = true
    }
    
    /*********************************************************************/
    /***************** Grab the selected address location ****************/
    /*********************************************************************/
    func getLocationAddress(longitude: String, latitude: String){
        var resultItem = 0
        var textGoogleApi = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyAfK-_j0Va1EFO-Kg63VVVeSV0zuASh6gg"
        print(textGoogleApi)
        textGoogleApi = textGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var urlRequest = URLRequest(url: URL(string: textGoogleApi)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if error == nil {
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                if let dict = jsonDict as? Dictionary<String, AnyObject> {
                    if let results = dict["results"] as! [Any]?{
                        for result in results {
                            resultItem += 1
                            if resultItem == 1 {
                                if let locationDictionary = result as? [String : Any] {
                                    //self.address.removeAll()
                                    let addressDict = locationDictionary["formatted_address"]! as! String
                                    self.currentAddress = String(addressDict)
                                    print(String(addressDict))
                                    createdLocation[0].address = String(addressDict)
                                }else{
                                    print("address not located")
                                }
                            }else if resultItem == 8{
                                if let locationDictionary = result as? [String : Any] {
                                    let addressDict = locationDictionary["formatted_address"]! as! String
                                    self.currentLoc = String(addressDict)
                                    print(String(addressDict))
                                    createdLocation[0].location = String(addressDict)
                                }
                            }
                        }
                    }
                } else {
                    //There is an error
                    print("There is a search maps error")
                }
            }
        }
        task.resume()
        print("Is this returning on the first run? \(currentAddress)")
    }
    
    /*********************************************************************/
    /**************** Display note when entering locaiton ****************/
    /*********************************************************************/
    var holdHeader = ""
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) { //This determines what happens whe user is in the region
        if let region = region as? CLCircularRegion { //region in area
            let header = region.identifier //identifier = location name
            if holdHeader == "" {
                print("holder empty")
                holdHeader = header
                displaylocationNotes(header:header)
            }else if (holdHeader != header){
                print("holder populated")
                displaylocationNotes(header:header)
                holdHeader = header
            }else{
                print("location has not changed")
            }
            noteTableView.reloadData()
        }
    }
    
    /*********************************************************************/
    /***************** Display notes when exit location ******************/
    /*********************************************************************/
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion { //region in area
            let header = region.identifier //identifier = location name
            if holdHeader == "" {
                print("holder empty")
                holdHeader = header
                displaylocationNotes(header:header)
            }else if (holdHeader != header){
                print("holder populated")
                displaylocationNotes(header:header)
                holdHeader = header
            }else{
                print("location has not changed")
            }
            noteTableView.reloadData()
        }
    }
    
    /*********************************************************************/
    /***************** location manager  notes display  ******************/
    /*********************************************************************/
    func displaylocationNotes(header:String){
        notesViewController().displayNotes(header: header)
        //noteTableView.reloadData()
        let description =  [noteDisplay]() //Empty array to hold user notes
        noteView.isHidden = false
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            self.noteView.isHidden = true
        }
        showNotification(title: header, items: description.count)//Display notification if app is closed
    }
    
    /*********************************************************************/
    /********** Location managment when location changes/updates *********/
    /*********************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locationManager.location
        mapView.camera = GMSCameraPosition.camera(withLatitude: Double((locationManager.location?.coordinate.latitude)!), longitude: Double((locationManager.location?.coordinate.longitude)!), zoom: 18, bearing: 0, viewingAngle: Double(mapCollection!.system3DDisplay))
        //mapView = nil
        //locationManager.stopUpdatingLocation()//stop updating to increase battery
    }
    
    /*********************************************************************/
    /******************** manage location when changed *******************/
    /*********************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.stopUpdatingLocation()
    }
    /*********************************************************************/
    /*************** Display notification when app is closed *************/
    /*********************************************************************/
    var uuidString = ""
    func showNotification(title: String, items: Int) {
        let content = UNMutableNotificationContent()
        var body = "There are 0 items here"
        let subtitle = "There seems to be items at this location"
        if (items == 1){
            body = "There is one item waiting for you."
        }else if (items > 1 && items < 10){
            body = "There are \(items) items waiting for you."
        }else if (items > 10){
            body = "There are several items waiting for you."
        }
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = 1
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
       /* if uuidString != uuidString{
            uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger) //insert UUID for multiple notifications
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }*/
        let request = UNNotificationRequest(identifier: "1", content: content, trigger: trigger) //insert UUID for multiple notifications
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /*********************************************************************/
    /********************** Swipe Gesture recognizers ********************/
    /*********************************************************************/
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
                if menuIsVisible == true {
                    closeMenu() //close menu
                }
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    /*********************************************************************/
    /************************** Parallax Map FX **************************/
    /*********************************************************************/
    func parallax(){
        let min = CGFloat(-10)
        let max = CGFloat(10)
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion,yMotion]
        mainView.addMotionEffect(motionEffectGroup)
        /*********menu table view*********/
    }
    
    /*********************************************************************/
    /******* Hide keyboard when the users touches outside keyboard *******/
    /*********************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    /*********************************************************************/
    /******* Hide keyboard when the users clicks return on keyboard ******/
    /*********************************************************************/
    func textFieldShouldReturn(searchBar: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
}

extension GMSMapView {
    /*********************************************************************/
    /************************* Set map view style ************************/
    /*********************************************************************/
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            print(name)
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}

/***************** Map gesture extension ******************/
extension ViewController : UIGestureRecognizerDelegate
{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

/***************** Map circle extension *******************/
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .black
        circleRenderer.fillColor = .gray
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}

extension UIColor{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
       DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
    }
}
class SelfSizedTableView: UITableView{
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
    deinit {
        print("self sized table has been deInitialized")
    }
}

protocol ModalTransitionListener {
    func popoverDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }
    private var listener: ModalTransitionListener?
    private init() {}
    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }
    func sendPopoverDismissed(modelChanged: Bool) {
        listener?.popoverDismissed()
    }
}


/*************************************************************************************
*********************** Search for View controller leaks *****************************
**************************************************************************************
 // Add Lifetime trackable to the view controller class ", LifetimeTrackable"
 static var lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "VC")
 // MARK: - Initialization
 override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
 super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
 trackLifetime()
 }
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 trackLifetime()
 }
**************************************************************************************
********************** Paste inside View Controller class ****************************
*************************************************************************************/

/*************************************************************************************
********************************* Info.plist file ************************************
**************************************************************************************
(Privacy - Location Always and When In Use Usage Description) -> (When you are near a location that is interesting.)
(Privacy - Location When In Use Usage Description) -> (We want to let you know when youre somewhere that you have mapped.)
**************************************************************************************
**************************************************************************************
*************************************************************************************/

/*************************************************************************************
********************************** Websites sused ************************************
**************************************************************************************
Map styles = https://snazzymaps.com/explore
Map styles = https://mapstyle.withgoogle.com
ICON= https://icons8.com/icons/set/unlock
Icons = http://getdrawings.com/paper-icon
Icons = https://www.iconsdb.com/white-icons/white-home-icons.html
Colors = https://www.color-hex.com/color/2b2b2b
**************************************************************************************
**************************************************************************************
*************************************************************************************/

/*************************************************************************************
********************************* Constant Colors ************************************
**************************************************************************************
Gold - #DEA77E
matte black = #1D1D1D #2b2b2b, #262626, #222222, #191919, #0f0f0f, #050505, #404040
white - E4E4E4
**************************************************************************************
**************************************************************************************
*************************************************************************************/

/*************************************************************************************
********************************* Info.plist file ************************************
**************************************************************************************
Useful = https://blog.bobthedeveloper.io/completion-handlers-in-swift-with-bob-6a2a1a854dc4
**************************************************************************************
**************************************************************************************
*************************************************************************************/
