//
//  systemViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 5/29/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import UIKit
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
import EPCSpinnerView

/**************** Global Variables ******************/
var colorCollection: colorSettings?
var mapCollection: mapSettings?
var systemCollection: systemSettings?
var loadUpdatedSettings: Bool = false

//Color Settings Class
class colorSettings{
    var systemBackground = ""
    var systemForeground = ""
    var systemMenuButton = ""
    var systemHighlight = ""
    init(systemBackground: String, systemForeground: String, systemMenuButton: String, systemHighlight: String) {
        self.systemBackground = systemBackground
        self.systemForeground = systemForeground
        self.systemMenuButton = systemMenuButton
        self.systemHighlight = systemHighlight
    }
    deinit {
        print("memory returned from color settings")
    }
}
//Map Settings Class
class mapSettings{
    var system3DDisplay = 0
    var systemForceTouchEnable = true
    var systemGeofenceArea = 0
    var systemMapDisplay = true
    var systemMapView = ""
    init(system3DDisplay: Int, systemForceTouchEnable: Bool, systemGeofenceArea: Int, systemMapDisplay: Bool, systemMapView: String) {
        self.system3DDisplay = system3DDisplay
        self.systemForceTouchEnable = systemForceTouchEnable
        self.systemGeofenceArea = systemGeofenceArea
        self.systemMapDisplay = systemMapDisplay
        self.systemMapView = systemMapView
    }
    deinit {
        print("memory returned from map settings")
    }
}
//System settings
var systemDropShadow: Double = 0.0
//Ssytem Settings Class
class systemSettings{
    var systemDropShadow = 0.00
    var systemOpacity = 0.0
    var systemName = ""
    init(systemDropShadow: Double, systemOpacity: Double, systemName: String) {
        self.systemDropShadow = systemDropShadow
        self.systemOpacity = systemOpacity
        self.systemName = systemName
    }
    deinit {
        print("memory returned from system settings")
    }
}


var tempBackgroundColor = 0.0

class systemViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var pageView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var mapViewOne: UIButton!
    @IBOutlet weak var mapViewTwo: UIButton!
    @IBOutlet weak var mapViewThree: UIButton!
    @IBOutlet weak var mapViewFour: UIButton!
    @IBOutlet weak var mapViewFive: UIButton!
    @IBOutlet weak var forceTouchSwitch: UISwitch!
    @IBOutlet weak var mapDisplaySwitch: UISwitch!
    @IBOutlet weak var map3DSwitch: UISwitch!
    @IBOutlet weak var mapViewDisplayText: UILabel!
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var spinnerview: UIView!
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var backgroundSlider: GradientSlider!
    @IBOutlet weak var backgroundSwitch: UISwitch!
    @IBOutlet weak var foregroundSwitch: UISwitch!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var saveUsername: UIButton!
    
    var mapViewSelection = ""
    var optionIsVisible = false //set main menu to false
    var backgroundGrayscale = false
    var foregroundGrayscale = false
    var sliderBrightness = 1.0
    var sliderSaturation = 1.0
    var sliderAlpha = 1.0
    var editMode = false
    
    //Set firebase database
    let db = Database.database().reference()
    let spinner = EPCSpinnerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if confirmationView != nil {
            performSegue(withIdentifier: "ConfirmationToMain", sender: nil)
            /*navigationItem.hidesBackButton = true
            navigationItem.setHidesBackButton(true, animated:true) //hide back button
            spinner.frame = CGRect(x: 0, y: 0, width: 290, height: 290)
            spinnerview.addSubview(spinner)
            spinner.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                self.spinner.state = .success
            }
            
            if let navController = self.navigationController {
                for controller in navController.viewControllers {
                    if controller is ViewController { // Change to suit your menu view controller subclass
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                            navController.popToViewController(controller, animated:true)
                        }
                        break
                    }
                }
            }*/
        }else{

            
            performSegue(withIdentifier: "settingsToConfirmation", sender: nil)
            optionView.isHidden = true //hide option View
            /***************** Swipe gesture ******************/
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeUp.direction = UISwipeGestureRecognizer.Direction.up
            self.view.addGestureRecognizer(swipeUp)
            /***************** System background view ******************/
            pageView.layer.backgroundColor = UIColor().HexToColor(hexString: "#0f0f0f" , alpha: 0.9
                ).cgColor
            mapViewOne.layer.cornerRadius = 8
            mapViewTwo.layer.cornerRadius = 8
            mapViewThree.layer.cornerRadius = 8
            mapViewFour.layer.cornerRadius = 8
            mapViewFive.layer.cornerRadius = 8
            /***************** Transparent nav bar ******************/
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = .white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            
            /***************** Image Drop Shadows ******************/
            buttonDisplay() //add drop shadows
            highlightBanner() //Highlight selected banner
            
            /***************** UI Switch States ******************/
            if mapCollection!.system3DDisplay != 90 {
                map3DSwitch.isOn = false
            }
            if mapCollection!.systemMapDisplay != true {
                mapDisplaySwitch.isOn = false
                mapsButton.isHidden = true
            }
            if mapCollection!.systemForceTouchEnable != true {
                forceTouchSwitch.isOn = false
            }
            usernameField.delegate = self
            username.text = systemCollection?.systemName
            usernameField.isHidden = true
            usernameField.placeholder = systemCollection?.systemName
            usernameView.layer.cornerRadius = 8.0
            usernameView.roundCorners(corners: [.topRight, .bottomRight], radius: 8.0)
            
            backgroundSlider.thumbColor = UIColor().HexToColor(hexString: colorCollection!.systemBackground, alpha: 1.0)
            backgroundSlider.actionBlock = {slider,newValue,finished in
                CATransaction.begin()
                CATransaction.setValue(true, forKey: kCATransactionDisableActions)
                if newValue < 0.001 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "E4E4E4", alpha: 1.0)
                    colorCollection!.systemBackground = "E4E4E4"
                }else if newValue > 0.0011 && newValue < 0.0049999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#DFDEDE", alpha: 1.0)
                    colorCollection!.systemBackground = "#DFDEDE"
                }else if newValue > 0.005 && newValue < 0.009999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#C3C3C3", alpha: 1.0)
                    colorCollection!.systemBackground = "#C3C3C3"
                }else if newValue > 0.01 && newValue < 0.0149999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#AEAEAE", alpha: 1.0)
                    colorCollection!.systemBackground = "#AEAEAE"
                }else if newValue > 0.015 && newValue < 0.019999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#949494", alpha: 1.0)
                    colorCollection!.systemBackground = "#949494"
                }else if newValue > 0.02 && newValue < 0.0249999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#838383", alpha: 1.0)
                    colorCollection!.systemBackground = "#838383"
                }else if newValue > 0.025 && newValue < 0.029999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#727272", alpha: 1.0)
                    colorCollection!.systemBackground = "#727272"
                }else if newValue > 0.03 && newValue < 0.0349999 {
                    slider.thumbColor = UIColor().HexToColor(hexString: "#5F5F5F", alpha: 1.0)
                    colorCollection!.systemBackground = "#5F5F5F"
                }else if newValue > 0.990 && newValue < 0.994999{
                    slider.thumbColor = UIColor().HexToColor(hexString: "#3C3C3C", alpha: 1.0)
                    colorCollection!.systemBackground = "#3C3C3C"
                }else if newValue > 0.995 && newValue < 0.99899{
                    slider.thumbColor = UIColor().HexToColor(hexString: "#222222", alpha: 1.0)
                    colorCollection!.systemBackground = "#222222"
                }else if newValue > 0.999 && newValue <= 1.0{
                    slider.thumbColor = UIColor().HexToColor(hexString: "#181818", alpha: 1.0)
                    colorCollection!.systemBackground = "#181818"
                }else{
                    slider.thumbColor = UIColor(hue: newValue, saturation: CGFloat(self.sliderSaturation), brightness: CGFloat(self.sliderBrightness), alpha: CGFloat(self.sliderAlpha))
                    colorCollection!.systemBackground = UIColor(hue: newValue, saturation: CGFloat(self.sliderSaturation), brightness: CGFloat(self.sliderBrightness), alpha: CGFloat(self.sliderAlpha)).toHex!
                }
                CATransaction.commit()
            }
            
            
            hueSlider.thumbColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0)
            hueSlider.thumbSize = 30
            hueSlider.actionBlock = {slider,newValue,finished in
                CATransaction.begin()
                CATransaction.setValue(true, forKey: kCATransactionDisableActions)
                self.hueSlider.maxColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                slider.thumbColor = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                colorCollection!.systemHighlight = UIColor(hue: newValue, saturation: 1.0, brightness: 1.0, alpha: 1.0).toHex!
                CATransaction.commit()
            }
        }
    
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func mapViewOne(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        bannerOne()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ //Delay 2 secs then segue.
            self.closeOptionMenu()
        }
    }
    @IBAction func mapViewTwo(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        bannerTwo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ //Delay 2 secs then segue.
            self.closeOptionMenu()
        }
    }
    @IBAction func mapViewThree(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        bannerThree()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ //Delay 2 secs then segue.
            self.closeOptionMenu()
        }
    }
    @IBAction func mapViewFour(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        bannerFour()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ //Delay 2 secs then segue.
            self.closeOptionMenu()
        }
    }
    @IBAction func mapViewFive(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        bannerFive()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ //Delay 2 secs then segue.
            self.closeOptionMenu()
        }
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        notification.notificationOccurred(.success) //haptic feedback
        map3DViewSwitch() //check if 3D is enabled
        mapViewSwitch() //Check if map view Switch is enabled
        touchForcehSwitch()// check if force touch is enabled
        systemColors() //Set system colors
        systemMapDisplay() //Set system map color
        systemSettings() //System settings
        loadUpdatedSettings = true
        performSegue(withIdentifier: "settingsToConfirmation", sender: nil)
        ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        if usernameField.text! != "" || usernameField.text! != systemCollection!.systemName{
            menuList.remove(at: 0)
            menuList.insert(menuDisplay(menuItem: systemCollection!.systemName, menuDetails: Int(0)), at: 0)
        }
    }
    
    /*********************************************************************/
    /************************** Map View switch **************************/
    /*********************************************************************/
    @IBAction func mapViewSwitch(_ sender: Any) {
        if (mapDisplaySwitch.isOn == true){
            mapCollection!.systemMapDisplay = true
            mapsButton.isHidden = false
        }else{
            mapCollection!.systemMapDisplay = false
            mapsButton.isHidden = true
        }
    }
    /*********************************************************************/
    /***************************** Force touch  **************************/
    /*********************************************************************/
    func systemMapDisplay(){
        let systemMapDisplayDB = self.db.child("Users/\(userID)/Settings/systemMap/systemMapDisplay") //set location
        systemMapDisplayDB.setValue(mapCollection!.systemMapDisplay) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
        let systemMapViewDB = self.db.child("Users/\(userID)/Settings/systemMap/systemMapView") //set location
        systemMapViewDB.setValue(mapCollection!.systemMapView) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
        let systemGeofenceAreaDB = self.db.child("Users/\(userID)/Settings/systemMap/systemGeofenceArea") //set location
        systemGeofenceAreaDB.setValue(mapCollection!.systemGeofenceArea) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
    }

    
    /*********************************************************************/
    /************************ systemBackground  **************************/
    /*********************************************************************/
    func systemSettings(){
        let systemDropShadowDB = self.db.child("Users/\(userID)/Settings/systemSettings/systemDropShadow") //set location
        systemDropShadowDB.setValue(systemCollection!.systemDropShadow) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("systemDropShadow successfully!") //print successfully
            }
        }
        let systemOpacityDB = self.db.child("Users/\(userID)/Settings/systemSettings/systemOpacity") //set location
        systemOpacityDB.setValue(systemCollection!.systemOpacity) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("systemOpacity successfully!") //print successfully
            }
        }
        systemCollection!.systemName = String(usernameField.text!)
        let systemNameDB = self.db.child("Users/\(userID)/Settings/systemSettings/systemName") //set location
        systemNameDB.setValue(systemCollection!.systemName) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("systemName successfully!") //print successfully
            }
        }
    }
    
    /*********************************************************************/
    /************************ systemBackground  **************************/
    /*********************************************************************/
    func systemColors(){
        let locationDB = self.db.child("Users/\(userID)/Settings/systemColors/systemBackground") //set location
        locationDB.setValue(colorCollection!.systemBackground) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
        let systemMenuButtonDB = self.db.child("Users/\(userID)/Settings/systemColors/systemMenuButton") //set location
        systemMenuButtonDB.setValue(colorCollection!.systemMenuButton) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
        let systemHighlightDB = self.db.child("Users/\(userID)/Settings/systemColors/systemHighlight") //set location
        systemHighlightDB.setValue(colorCollection!.systemHighlight) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
        let systemForegroundDB = self.db.child("Users/\(userID)/Settings/systemColors/systemForeground") //set location
        systemForegroundDB.setValue(colorCollection!.systemForeground) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
    }
    
    /*********************************************************************/
    /***************************** Force touch  **************************/
    /*********************************************************************/
    func touchForcehSwitch(){
        if (forceTouchSwitch.isOn == true){
            mapCollection!.systemForceTouchEnable = true
        }else{
            mapCollection!.systemForceTouchEnable = false
        }
        let locationDB = self.db.child("Users/\(userID)/Settings/systemMap/systemForceTouchEnable") //set location
        locationDB.setValue(mapCollection!.systemForceTouchEnable) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
    }
    /*********************************************************************/
    /************************** Map View Switch **************************/
    /*********************************************************************/
    func mapViewSwitch(){
        if (mapDisplaySwitch.isOn == true){
            mapViewDisplayText.layer.opacity = 1
        }else{
            mapViewDisplayText.layer.opacity = 0.5
            mapViewDisplayText.layer.opacity = 1
            mapCollection!.systemMapView = "default"
        }
        let locationDB = self.db.child("Users/\(userID)/Settings/systemMap/systemMapView") //set location
        locationDB.setValue(mapCollection!.systemMapView) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
    }
    /*********************************************************************/
    /***************************** 3D Map View  **************************/
    /*********************************************************************/
    func map3DViewSwitch() {
        if (map3DSwitch.isOn == true){
            mapCollection!.system3DDisplay = 90
            print("3D display active")
        }else{
            mapCollection!.system3DDisplay = 0
            print("3D display inactive")
        }
        let locationDB = self.db.child("Users/\(userID)/Settings/systemMap/system3DDisplay") //set location
        locationDB.setValue(mapCollection!.system3DDisplay) { //set the for touch to database
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                print("Settings saved successfully!") //print successfully
            }
        }
    }
    /*********************************************************************/
    /************************** Close Option menu ************************/
    /*********************************************************************/
    func closeOptionMenu(){
        print("option Closed")
        optionView.isHidden = true
        mainView.isHidden = false
        leadingConstraint.constant -= 500 //shift
        trailingConstraint.constant -= 500//shift
        optionIsVisible = false //set main menu to false
    }
    /*********************************************************************/
    /************************** Close edit username ************************/
    /*********************************************************************/
    @IBAction func usernameUpdateField(_ sender: Any) {
        //sender.resignFirstResponder()
        usernameField.resignFirstResponder() //clear keyboard
    }
    var tempName = systemCollection!.systemName
    @IBAction func editUsernameButton(_ sender: Any) {
        usernameField.resignFirstResponder() //clear keyboard
        //usernameField.text = systemCollection!.systemName
        if editMode == false { //hide username
            username.isHidden = true
            usernameField.isHidden = false
            usernameField.placeholder = tempName
            editMode = true
            let image = UIImage(named: "save.png") as UIImage?
            saveUsername.setImage(image, for: .normal)
        } else{ //hide text field
            if usernameField.text! != "" {
                username.isHidden = false
                usernameField.isHidden = true
                usernameField.text = String(usernameField.text!)
                tempName = String(usernameField.text!)
                username.text = tempName
                editMode = false
                saveUsername.setImage(UIImage(named: "editIcon.png"), for: .normal)
                //image change to edit icon
            }
        }
    } /*********************************************************************/
    /********************** Display map view themes **********************/
    /*********************************************************************/
    @IBAction func displayMapViews(_ sender: Any) {
        if (mapCollection!.systemMapDisplay == true){
            print("option Active")
            optionView.isHidden = false
            mainView.isHidden = true
            leadingConstraint.constant += 500 //shift
            trailingConstraint.constant += 500//shift
            optionIsVisible = true //set main menu to false
        }
    }
    /*********************************************************************/
    /************************** Background switch **************************/
    /*********************************************************************/
    @IBAction func backgroundColorSwitch(_ sender: Any) {
        if (backgroundSwitch.isOn == true){
            sliderBrightness = 0.5
            sliderSaturation = 0.8
            sliderAlpha = 0.5
        }else{
            sliderBrightness = 0.5
            sliderSaturation = 0.2
            sliderAlpha = 1.0
        }
    }
    
    /*********************************************************************/
    /************************** Foreground switch ************************/
    /*********************************************************************/
    @IBAction func foregroundColorSwitch(_ sender: Any) {
        if (foregroundSwitch.isOn == true){
            foregroundGrayscale = true
            hueSlider.hasRainbow = false
        }else{
            foregroundGrayscale = false
            hueSlider.hasRainbow = true
        }
    }
    /*********************************************************************/
    /************************** Banner Displays **************************/
    /*********************************************************************/
    func highlightBanner(){
        switch mapCollection!.systemMapView {
        case "dark":
            print("Highlight dark theme")
            buttonDisplay() //reset buttons
            mapViewOne.layer.borderWidth = 0
            mapViewOne.layer.borderWidth = 8
            mapViewOne.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
            mapViewSelection = "dark"
            colorCollection!.systemMenuButton = colorCollection!.systemForeground
        case "grayscale":
            print("Highlight grayscale theme")
            buttonDisplay() //reset buttons
            mapViewTwo.layer.borderWidth = 0
            mapViewTwo.layer.borderWidth = 8
            mapViewTwo.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
            mapViewSelection = "grayscale"
            colorCollection!.systemMenuButton = colorCollection!.systemBackground
        case "paper":
            print("Highlight paper theme")
            buttonDisplay() //reset buttons
            mapViewThree.layer.borderWidth = 8
            mapViewThree.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
            mapViewSelection = "paper"
            colorCollection!.systemMenuButton = colorCollection!.systemBackground
        case "retro":
            print("Highlight retro theme")
            buttonDisplay() //reset buttons
            mapViewFour.layer.borderWidth = 8
            mapViewFour.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
            mapViewSelection = "retro"
            colorCollection!.systemMenuButton = colorCollection!.systemBackground
        case "transparent":
            print("Highlight Transparent theme")
            buttonDisplay() //reset buttons
            mapViewFive.layer.borderWidth = 8
            mapViewFive.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
            mapViewSelection = "transparent"
            colorCollection!.systemMenuButton = colorCollection!.systemBackground
        default:
            print("Default theme")
            colorCollection!.systemMenuButton = colorCollection!.systemBackground
        }
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
            case UISwipeGestureRecognizer.Direction.up:
                dismiss(animated: true, completion: nil)
                print("Swiped up")
            default:
                break
            }
        }
    }
    /*********************************************************************/
    /******* Hide keyboard when the users touches outside keyboard *******/
    /*********************************************************************/
    //ensure , UITextFieldDelegate is attached to class
    //Ensure to add usernameField.delegate = self to view did load
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    /*********************************************************************/
    /******* Hide keyboard when the users clicks return on keyboard ******/
    /*********************************************************************/
    func textFieldShouldReturn(_ usernameField: UITextField) -> Bool {
        usernameField.resignFirstResponder()
        self.view.endEditing(true)
        if usernameField.text! != "" {
            username.isHidden = false
            usernameField.isHidden = true
            usernameField.text = String(usernameField.text!)
            tempName = String(usernameField.text!)
            username.text = tempName
            editMode = false
            saveUsername.setImage(UIImage(named: "editIcon.png"), for: .normal)
            //image change to edit icon
        }
        return true
    }
    
    func buttonDisplay(){
        mapViewOne.layer.shadowColor = UIColor.black.cgColor
        mapViewOne.layer.shadowOpacity = Float(systemDropShadow)
        mapViewOne.layer.shadowOffset = CGSize.zero
        mapViewOne.layer.shadowRadius = 7
        mapViewOne.layer.borderWidth = 0
        
        mapViewTwo.layer.shadowColor = UIColor.black.cgColor
        mapViewTwo.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
        mapViewTwo.layer.shadowOffset = CGSize.zero
        mapViewTwo.layer.shadowRadius = 7
        mapViewTwo.layer.borderWidth = 0
        
        mapViewThree.layer.shadowColor = UIColor.black.cgColor
        mapViewThree.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
        mapViewThree.layer.shadowOffset = CGSize.zero
        mapViewThree.layer.shadowRadius = 7
        mapViewThree.layer.borderWidth = 0
        
        mapViewFour.layer.shadowColor = UIColor.black.cgColor
        mapViewFour.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
        mapViewFour.layer.shadowOffset = CGSize.zero
        mapViewFour.layer.shadowRadius = 7
        mapViewFour.layer.borderWidth = 0
        
        mapViewFive.layer.shadowColor = UIColor.black.cgColor
        mapViewFive.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
        mapViewFive.layer.shadowOffset = CGSize.zero
        mapViewFive.layer.shadowRadius = 7
        mapViewFive.layer.borderWidth = 0
    }
    func bannerOne(){
        mapCollection!.systemMapView = "dark"
        buttonDisplay() //reset buttons
        mapViewOne.layer.borderWidth = 10
        mapViewOne.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
    }
    func bannerTwo(){
        mapCollection!.systemMapView = "grayscale"
        buttonDisplay() //reset buttons
        mapViewTwo.layer.borderWidth = 8
        mapViewTwo.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
    }
    func bannerThree(){
        mapCollection!.systemMapView = "paper"
        buttonDisplay() //reset buttons
        mapViewThree.layer.borderWidth = 8
        mapViewThree.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
    }
    func bannerFour(){
        mapCollection!.systemMapView = "retro"
        buttonDisplay() //reset buttons
        mapViewFour.layer.borderWidth = 8
        mapViewFour.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
    }
    func bannerFive(){
        mapCollection!.systemMapView = "transparent"
        buttonDisplay() //reset buttons
        mapViewFive.layer.borderWidth = 8
        mapViewFive.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemHighlight, alpha: 1.0).cgColor
    }
}
extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        //blet length = hexSanitized.characters.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
}

// spinner - https://github.com/evertoncunha/EPCSpinnerView/blob/master/Example/EPCSpinnerView/ViewController.swift
