//
//  locationsViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 5/19/19.
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
import LifetimeTracker

class locationCell: UITableViewCell{
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationNotes: UILabel!
    @IBOutlet weak var locationDate: UILabel!
    @IBOutlet weak var locationIndex: UILabel!
    @IBOutlet weak var tabBackground: UIView!
    @IBOutlet weak var divderView: UIView!
}

//location description array
var locationDescription = [locationDetails]()
//locationDetails class
class locationDetails: DetailItem {
    override class var lifetimeConfiguration: LifetimeConfiguration {
        // There should only be one video item as the memory usage is too high
        let configuration = super.lifetimeConfiguration
        configuration.maxCount = 1
        return configuration
    }
    var lat: Double
    var long: Double
    var id: String?
    var name: String
    var openNow: Int?
    var photos: [[String : Any]]?
    var placeID: String?
    var priceLevel: Int?
    var rating: Double?
    var types: [String]?
    init?(lat: Double, long: Double, id: String?, name: String, openNow: Int?, photos: [[String : Any]]?, placeID: String?, priceLevel: Int?, rating: Double?, types: [String]?) {
        self.lat = lat
        self.long = long
        self.id = id
        self.name = name
        self.openNow = openNow
        self.photos = photos
        self.placeID = placeID
        self.priceLevel = priceLevel
        self.rating = rating
        self.types = types
    }
    deinit {
        print("Location details has been allocted")
    }
}

var createdLocation = [tempLocation]()
class tempLocation : DetailItem {
    override class var lifetimeConfiguration: LifetimeConfiguration {
        // There should only be one video item as the memory usage is too high
        let configuration = super.lifetimeConfiguration
        configuration.maxCount = 1
        return configuration
    }
    var longitude = ""
    var latitude = ""
    var address = ""
    var location = ""
    init(longitude: String, latitude: String, address: String, location: String) {
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
        self.location = location
    }
    deinit {
        print("Temp location has been allocted")
    }
}


var selectedLocation = "" //save the location globally that was clicked

class locationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var pageView: UIView!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var locationMainView: UIView!
    @IBOutlet weak var locationTitle: UITextField!
    @IBOutlet weak var deleteLocationView: UIView!
    //Set firebase database
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController!.navigationBar.isTranslucent = false
        if locationTableView != nil{
            locationTableView.dataSource = self
            locationTableView.delegate = self
            self.navigationItem.title = "LOCATIONS"
            locationTableView.layer.shadowColor = UIColor.black.cgColor
            locationTableView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
            locationTableView.layer.shadowOffset = CGSize.zero
            locationTableView.layer.shadowRadius = 10
            locationTableView.layer.cornerRadius = 8
        }else if locationMainView != nil{
            //locationMainView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
            locationMainView.layer.shadowColor = UIColor.black.cgColor
            locationMainView.layer.cornerRadius = 8
            locationMainView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
            locationMainView.layer.shadowRadius = 10
            locationMainView.layer.shadowOffset = CGSize.zero
        }else if deleteLocationView != nil{
            //deleteLocationView.roundCorners(corners: [.topLeft, .topRight,.bottomLeft, .bottomRight], radius: 8.0)
            
            deleteLocationView.layer.shadowColor = UIColor.black.cgColor
            deleteLocationView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow)
            deleteLocationView.layer.shadowRadius = 10
            deleteLocationView.layer.shadowOffset = CGSize.zero
        }

        /***************** System background view ******************/
        if pageView != nil {
            pageView.layer.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
            pageView.layer.opacity = Float(systemCollection!.systemOpacity)
        }
        
        /***************** Transparent nav bar ******************/
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]  
    }
    func animateTransition(){
        print("menu Active")
       /* self.menuView.frame.origin.x -= 500
        leadingConstraints.constant = 0 //shift
        trailingConstraints.constant = 0//shift
        menuIsVisible = true //set main menu to false
        menuView.isHidden = false
        returnButton.isHidden = false
        menuButton.tintColor = UIColor().HexToColor(hexString: "#ccb47c", alpha: 1.0)
        menuTableView.isHidden = false
        let scaledTransform = self.mainView.transform.scaledBy(x: 0.8, y: 0.8)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.7) {//slide animation
            self.mainView.transform = scaledAndTranslatedTransform
            //self.mainView.layer.cornerRadius=25
            self.mainView.frame.origin.x += 300 //change the slide view for the menu
        }
        UIView.animate(withDuration: 0.75) {//slide animation
            self.menuView.frame.origin.x += 500
        }*/
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count : Int?
        if tableView == self.locationTableView {
            count = regionList.count
        }
        return count!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.locationTableView  {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "locationCell") as! locationCell?)!
            if (indexPath.row % 2 == 0 ){
                cell.tabBackground.backgroundColor =  UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
                cell.divderView.backgroundColor = UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)
                cell.divderView.backgroundColor = UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)
                cell.locationNotes.textColor  = UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)
            } else{
                cell.tabBackground.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemForeground, alpha: 1.0)
                cell.divderView.backgroundColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
                cell.locationNotes.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
            }
            if cell == nil {
                tableView.register(locationCell.classForCoder(), forCellReuseIdentifier: "locationCell")
                cell = locationCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "locationCell")
            }
            if let label = cell.locationTitle{
                label.text = regionList[indexPath.row].header
            }else{
                cell.textLabel?.text = regionList[indexPath.row].header
            }
            if let label = cell.locationIndex{
                label.text = String(indexPath.row + 1)
            }else{
                cell.textLabel?.text = String(indexPath.row + 1)
            }
           /*i f let label = cell.locationAddress{
                label.text = String(indexPath.row + 1)
            }else{
                cell.textLabel?.text = String(indexPath.row + 1)
            }*/
            
            if let label = cell.locationNotes{
                label.text = String(regionList[indexPath.row].notes.count)
            }else{
                cell.textLabel?.text = String(regionList[indexPath.row].notes.count)
            }
            if let label = cell.locationDate{
                label.text = "04/23/19"
            }else{
                cell.textLabel?.text = "04/23/19"
            }
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.locationTableView{
            /*let cell:locationCell = tableView.cellForRow(at: indexPath) as! locationCell
            cell.locationTitle.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
            cell.locationDate.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
            cell.locationNotes.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
            cell.locationIndex.textColor = UIColor().HexToColor(hexString: "#ffffff", alpha: 1.0)
            cell.locationDate.alpha = 0.6
            cell.tabBackground.backgroundColor = UIColor().HexToColor(hexString: "#404040", alpha: 1.0)*/
            selectedLocation = regionList[indexPath.row].header
            noteList.removeAll() //clear array notes
            notesViewController().displayNotes(header: selectedLocation)
            self.performSegue(withIdentifier: "locationsToNotesSegue", sender: nil) //segue to the notes screen
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == self.locationTableView{
            let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete") { (action , indexPath ) -> Void in
                self.isEditing = false
                print("Add button pressed")
                //self.performSegue(withIdentifier: "locationsToDeleteLocation", sender: self) //segue to the delete location screen
            }
            deleteAction.backgroundColor = UIColor.red
            return[deleteAction]
        }
        return [UITableViewRowAction].init()
    }
    func locaitonRSSFeed(){
       /* var item = 0
        print("This is first block")
        repeat {
            sleep(2)
            print(regionList[item].header)
            DispatchQueue.main.async {
                self.rssFeed.text = regionList[item].header
            }
            if item == 2 {
                item = 0
            }else{
                item += 1
            }
        } while (rssFeed != nil)*/
    }
    

    @IBAction func addLocationButton(_ sender: Any) {
        print("set address \(createdLocation[0].address)")
        let titleTextField = locationTitle.text!
        if titleTextField != ""{
            selectedLocation = titleTextField
            let longitude = createdLocation[0].longitude
            let latitude = createdLocation[0].latitude
            let currentAddress = createdLocation[0].address
            let currentLoc = createdLocation[0].location
            let locationDictionary : NSDictionary = [
                "location": "\(currentLoc)", //add username to database
                "header": "\(titleTextField)",
                "longitude": "\(longitude)", //add longitude
                "latitude": "\(latitude)", //add latitude
                "address": "\(currentAddress)" // add name to address
            ]
            locationDescription.removeAll() //clear all location details elements
            db.child("Users/\(userID)/Locations/\(titleTextField)").setValue(locationDictionary) {
                (error, ref) in
                if error != nil {
                    print(error!)
                }
                else {
                    regionList.append(createRegion(longitude: "\(longitude)", latitude: "\(latitude)", location: "\(currentLoc)", header: "\(titleTextField)", notes: noteList, address: "\(currentAddress)"))//append each location and note(s) to array
                    //add notes to this section
                    print("Location saved successfully!")
                }
            }
        }
    }
    @IBAction func returnHome(_ sender: Any) {

        dismiss(animated: true, completion: nil)
        //ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
    }
    
    @IBAction func cancelLocationButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func closeLocations(_ sender: Any) {
        //ViewController().transitionToMain()
    }
    /*********************************************************************/
    /************** Transition to previous view controller ***************/
    /*********************************************************************/
    func previousViewController(viewCount: Int){
        for n in 1...viewCount {
            navigationController?.popViewController(animated: true) //return to previous page
        }
    }
}
