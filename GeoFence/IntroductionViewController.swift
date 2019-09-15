//
//  IntroductionViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 4/11/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import Alamofire
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import UIKit
import LifetimeTracker

let db = Database.database().reference()

/**************** Global Variables ******************/
var activeUser = false //Check if user has recently logged in
var userID = "" //user identfication
var applicationOffline = true

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

class IntroductionViewController: UIViewController, CLLocationManagerDelegate, LifetimeTrackable {
    @IBOutlet weak var welcomeView: UIView!
    
    //set to location manager to location manager function
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        if welcomeView != nil{ DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.performSegue(withIdentifier: "welcomeToMain", sender: nil)
            }
        } else {
            /******************* Location manager *******************/
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            offlineCheck() //check if application is online/offline
            
            /*Check application online status*/
            if (applicationOffline == true) {
                //make trasition to offline page
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){ //Delay 5 secs then segue.
                    //change to appear offline in order to not segue
                    //self.performSegue(withIdentifier: "introToApplicationOffline", sender: nil) //segue to the main screen
                    self.offlineData()
                }
            }else {
                getUser()//Get User Creds
                activeUser = UserDefaults.standard.bool(forKey: "activeUser") //set the active user status
                if (!activeUser){ //If user has not logged in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){ //Delay 5 secs then segue.
                        self.performSegue(withIdentifier: "introToLogin", sender: nil) // into to login transition
                    }
                }else { //If user has  logged in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3){ //Delay 5 secs then segue.
                        self.performSegue(withIdentifier: "introToMain", sender: nil) //segue to the main screen
                    }
                }
            }
            self.navigationItem.setHidesBackButton(true, animated:true) //hide back button
        }
    }
    
    
    static var lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "IV")
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        trackLifetime()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        trackLifetime()
    }
    
    /*********************************************************************/
    /******************** Check if device is online***********************/
    /*********************************************************************/
    func offlineCheck(){ //determine if application is online
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            applicationOffline = false //set offline to false
        }else{
            print("Yes! internet is NOT available.")
            applicationOffline = true //set offline to true
        }
    }
    /*********************************************************************/
    /****************************** Get Users ****************************/
    /*********************************************************************/
    func getUser(){ //Determine if user uid is active
        if Auth.auth().currentUser != nil { //If user has logged on
            userID = Auth.auth().currentUser!.uid //Set the user ID variable
            UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "activeUserID") //save the uid to app
            firebaseRegion() //Gather user locations
            getUserSettings() //Get user settings
        } else {
            print("User has not logged in") //print user warning
        }
    }
    /*********************************************************************/
    /********************** Get Firebase region data *********************/
    /*********************************************************************/
    func firebaseRegion(){ //Gather user locations
        regionList.removeAll()// Remove all regions you were tracking before
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region) //stop monitoring locaitons
        }
        let locationDB = db.child("Users/\(userID)/Locations") //Set the database location
        locationDB.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() { //run if snapshot is found / if user has locaitons saved
                let snapshotValue = snapshot.value as! NSDictionary //[String: AnyObject]
                if snapshot.hasChild("items"){ //if items child is displayed then continue
                    let notes = snapshotValue["items"] as! NSDictionary // store notes
                    for (key, value) in notes {// search note strings
                        let note = notes["\(key)"] as! NSDictionary //store note title
                        var noteHolder: noteDisplay?
                        noteHolder = noteDisplay(name: note["name"] as! String, message: note["message"] as! String, time: note["time"] as! String, status: note["status"] as! Int)
                        noteList.append(noteHolder!) //append each note into array to hold
                        noteHolder = nil
                    }
                    var regionHolder: createRegion?
                    regionHolder = createRegion(longitude: snapshotValue["longitude"] as! String, latitude: snapshotValue["latitude"] as! String, location: snapshotValue["location"] as! String, header: snapshotValue["header"] as! String, notes: noteList, address: snapshotValue["address"] as! String)
                    regionList.append(regionHolder!) //append each location and note(s) to array
                    regionHolder = nil
                    noteList.removeAll() //clear noteList to retrieve new location
                }
            }else{
                print("system offline")
            }}) { (error) in
            print(error.localizedDescription)
        }
    }
    /*********************************************************************/
    /****************************** Get Users ****************************/
    /*********************************************************************/

    func getUserSettings(){
        db.child("Users/\(userID)").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                print("the user signed in")
                let locationDB = db.child("Users/\(userID)") //Set the database location
                locationDB.observe(.childAdded, with: { [weak self] (snapshot) in
                    if snapshot.exists() { //run if snapshot is found / if user has locaitons saved
                        let snapshotValue = snapshot.value as! NSDictionary
                        if snapshot.hasChild("systemColors"){
                            weak var systemColor = snapshotValue["systemColors"] as? NSDictionary// store notes
                            colorCollection = colorSettings(systemBackground: systemColor?["systemBackground"] as! String, systemForeground: systemColor?["systemForeground"] as! String, systemMenuButton: systemColor?["systemMenuButton"] as! String, systemHighlight: systemColor?["systemHighlight"] as! String)
                            //self?.colorCollection = nil //deallocate color collection class
                        }
                        if snapshot.hasChild("systemMap"){
                            weak var systemMap = snapshotValue["systemMap"] as? NSDictionary // store system maps settings
                            mapCollection = mapSettings(system3DDisplay: systemMap?["system3DDisplay"] as! Int, systemForceTouchEnable: systemMap?["systemForceTouchEnable"] as! Bool, systemGeofenceArea: systemMap?["systemGeofenceArea"] as! Int, systemMapDisplay: systemMap?["systemMapDisplay"] as! Bool,systemMapView: systemMap?["systemMapView"] as! String) //append each location and note(s) to array
                            //self?.mapCollection = nil //deallocate color collection class
                        }
                        if snapshot.hasChild("systemSettings"){
                            weak var settingsSystem = snapshotValue["systemSettings"] as? NSDictionary // store system settings
                            systemCollection = systemSettings(systemDropShadow: settingsSystem?["systemDropShadow"] as! Double, systemOpacity: settingsSystem?["systemOpacity"] as! Double, systemName: settingsSystem?["systemName"] as! String) //append each location and note(s) to array
                            //self?.systemCollection = nil
                        }
                    }else{
                        print("system offline")
                    }})
            }else{
                print("the user has not signed in")
                colorCollection = colorSettings(systemBackground: "#0f0f0f", systemForeground: "#FFFFFF", systemMenuButton: "#0F0F0F", systemHighlight: "#0F0F0F")
                mapCollection = mapSettings(system3DDisplay: 90, systemForceTouchEnable: false, systemGeofenceArea: 30, systemMapDisplay: true ,systemMapView: "default")
                systemCollection = systemSettings(systemDropShadow: 10, systemOpacity: 0.8, systemName: "Change Username")
                
                let systemColorsDB = db.child("Users/\(userID)/Settings/systemColors") //set location
                
                let systemColorsDictionary : NSDictionary = ["systemBackground": "#0f0f0f", "systemForeground": "#FFFFFF", "systemMenuButton": "#0F0F0F", "systemHighlight": "#0F0F0F"] //location dictionary to sell
                systemColorsDB.setValue(systemColorsDictionary) { //add the location dictionary to firebase
                    (error, ref) in
                    if error != nil {
                        print(error!) //display if there is an error
                    }
                    else {
                        //print("System saved successfully!") //print successfully
                    }
                }
                
                let systemSettingsDB = db.child("Users/\(userID)/Settings/systemSettings") //set location
                let systemSettingsDictionary : NSDictionary = ["systemDropShadow": 10, "systemOpacity": 0.8] //location dictionary to sell
                systemSettingsDB.setValue(systemSettingsDictionary) { //add the location dictionary to firebase
                    (error, ref) in
                    if error != nil {
                        print(error!) //display if there is an error
                    }
                    else {
                        //print("System saved successfully!") //print successfully
                    }
                }
                
                let systemMapDB = db.child("Users/\(userID)/Settings/systemMap") //set location
                let systemMapDictionary : NSDictionary = ["system3DDisplay": 90, "systemForceTouchEnable": false, "systemGeofenceArea": 30, "systemMapDisplay": true ,"systemMapView": "dark"] //location dictionary to sell
                systemMapDB.setValue(systemMapDictionary) { //add the location dictionary to firebase
                    (error, ref) in
                    if error != nil {
                        print(error!) //display if there is an error
                    }
                    else {
                        //print("System saved successfully!") //print successfully
                    }
                }
            }
        }){ (error) in
                print(error.localizedDescription)
        }
    }
    func offlineData(){
        colorCollection = colorSettings(systemBackground: "#0f0f0f", systemForeground: "#FFFFFF", systemMenuButton: "#0F0F0F", systemHighlight: "#0F0F0F")
        mapCollection = mapSettings(system3DDisplay: 90, systemForceTouchEnable: false, systemGeofenceArea: 30, systemMapDisplay: true ,systemMapView: "dark")
         systemCollection = systemSettings(systemDropShadow: 10, systemOpacity: 0.8, systemName: "Offline Mode")
        
        for index in 0...4 {// search note strings
            var noteHolder: noteDisplay?
        noteHolder = noteDisplay(name: "name\(index)", message: "message\(index)", time: "3:00pm", status: 0)
            noteList.append(noteHolder!) //append each note into array to hold
            noteHolder = nil
        }
        var regionIndex = 0
        var regionHolder: createRegion?
        regionHolder = createRegion(longitude: "100.00000", latitude: "-90.00000", location: "Somewhere\(regionIndex)", header: "Somewhere Header \(regionIndex)", notes: noteList, address: "Somewhere is the location")
        regionIndex = regionIndex + 1
        regionList.append(regionHolder!) //append each location and note(s) to array
        regionHolder = nil
        noteList.removeAll() //clear noteList to retrieve new location
        /*******************/
        for index in 0...2 {// search note strings
            var noteHolder: noteDisplay?
            noteHolder = noteDisplay(name: "name\(index)", message: "message\(index)", time: "3:00pm", status: 0)
            noteList.append(noteHolder!) //append each note into array to hold
            noteHolder = nil
        }
        
        regionHolder = createRegion(longitude: "100.00000", latitude: "-90.00000", location: "Somewhere\(regionIndex)", header: "Somewhere Header \(regionIndex)", notes: noteList, address: "Somewhere is the location")
        regionIndex = regionIndex + 1
        regionList.append(regionHolder!) //append each location and note(s) to array
        regionHolder = nil
        noteList.removeAll() //clear noteList to retrieve new location
        
        for ind in 0...3{
            for index in 0...ind {// search note strings
                var noteHolder: noteDisplay?
                noteHolder = noteDisplay(name: "name\(index)", message: "message\(index)", time: "3:00pm", status: 0)
                noteList.append(noteHolder!) //append each note into array to hold
                noteHolder = nil
            }
            regionHolder = createRegion(longitude: "100.00000", latitude: "-90.00000", location: "Somewhere\(regionIndex)-\(ind)", header: "Somewhere Header \(regionIndex)-\(ind)", notes: noteList, address: "Somewhere is the location")
            regionIndex = regionIndex + 1
            regionList.append(regionHolder!) //append each location and note(s) to array
            regionHolder = nil
            noteList.removeAll() //clear noteList to retrieve new location
        }
        self.performSegue(withIdentifier: "introToMain", sender: nil) //segue to the main screen
    }
}

