//
//  notesViewController.swift
//  GeoFence
//
//  Created by Kendall Lewis on 7/10/19.
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

//Global variables
var updateTitle:String = ""
var updateMessage:String = ""
var updateStatus:Int = 0

var noteList = [noteDisplay]()
class noteDisplay : DetailItem  {
    override class var lifetimeConfiguration: LifetimeConfiguration {
        // There should only be one video item as the memory usage is too high
        let configuration = super.lifetimeConfiguration
        configuration.maxCount = 1
        return configuration
    }
    var name = ""
    var message = ""
    var time = ""
    var status = 0
    init(name: String, message: String, time: String, status: Int) {
        self.name = name
        self.message = message
        self.time = time
        self.status = status
    }
    deinit {
        print("note display has been allocted")
    }
}


class noteCell: UITableViewCell{
    @IBOutlet weak var noteItem: UILabel!
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var noteIndex: UILabel!
    @IBOutlet weak var noteActivity: UILabel!
    @IBOutlet weak var divderView: UIView!
}


class notesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var pageView: UIView!
    @IBOutlet weak var noteTableView: SelfSizedTableView!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var updateNoteContainer: UIView!
    @IBOutlet weak var deleteNoteView: UIView!
    @IBOutlet weak var addNoteView: UIView!
    
    //Set firebase database
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /***************** System background view ******************/
        pageView.layer.backgroundColor =  UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
        pageView.layer.opacity = Float(systemCollection!.systemOpacity)
        /***************** Transparent nav bar ******************/
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]

        if (noteTableView != nil){
            /*********************** note table view **********************/
            noteTableView.delegate = self
            noteTableView.dataSource = self
            noteTableView.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
            noteTableView.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
            noteTableView.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
            noteTableView.layer.shadowRadius = 10 //sets how wide the shadow should be
            noteTableView.estimatedRowHeight = 105.5
            //noteTableView.maxHeight = 500
            noteTableView.translatesAutoresizingMaskIntoConstraints = false
            //noteTableView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
            //addNoteButton.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
            addNoteButton.layer.shadowColor = UIColor.black.cgColor
            addNoteButton.layer.shadowOpacity = Float(systemCollection!.systemDropShadow) //sets how transparent the shadow is, where 0 is invisible and 1 is as strong as possible
            addNoteButton.layer.shadowOffset = CGSize.zero //ets how far away from the view the shadow should be, to give a 3D offset effect
            addNoteButton.layer.shadowRadius = 10
            //addNoteView.layer.cornerRadius = 8
            self.navigationItem.title = "NOTES"
            noteTableView.reloadData()
        } else if (updateNoteContainer != nil){
            updateNoteContainer.roundCorners(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], radius: 8.0)
            titleTextField.placeholder = updateTitle
            messageTextField.text = updateMessage
        }else if deleteNoteView != nil{
            self.navigationItem.title = String(selectedLocation)
            deleteNoteView.roundCorners(corners: [.bottomLeft, .bottomRight, .topRight, .topLeft], radius: 8.0)
        }
    }
    
    /*********************************************************************/
    /************************** Table row count  *************************/
    /*********************************************************************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count : Int?
        if tableView == self.noteTableView
        {
            count = noteList.count
            //dump(noteList)
        }
        return count!
    }
    
    /*********************************************************************/
    /*********************** populate note table  ************************/
    /*********************************************************************/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.noteTableView { //ensure to attach datasource and delegate
                var cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! noteCell?
                if cell == nil {
                    tableView.register(noteCell.classForCoder(), forCellReuseIdentifier: "noteCell")
                    cell = noteCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "noteCell")
                }
                if let label = cell?.noteItem{ //populate cell
                    label.text = noteList[indexPath.row].message
                } else {
                    cell? .textLabel?.text = noteList[indexPath.row].message
                }
                if let label = cell?.noteName{ //populate cell
                    label.text = noteList[indexPath.row].name
                } else {
                    cell? .textLabel?.text = noteList[indexPath.row].name
                }
                if let label = cell?.noteIndex{ //populate cell
                    label.text = String(indexPath.row + 1)
                } else {
                    cell? .textLabel?.text = String(indexPath.row + 1)
                }
                /*if (noteList[indexPath.row].status == 0){
                    if let label = cell?.noteActivity{ //populate cell
                        label.text = "Active"
                    } else {
                        cell? .textLabel?.text = "Active"
                    }
                } else {
                    if let label = cell?.noteActivity{ //populate cell
                        label.text = "Inactive"
                    } else {
                        cell? .textLabel?.text = "Inative"
                    }
                }*/
            
            addNoteButton.addTarget(self, action: #selector(addNoteButtonPressed(sender: )), for: .touchUpInside)
            addNoteButton.tag =  indexPath.row
            return cell!
                
            }
        return UITableViewCell()
    }
    
    /*********************************************************************/
    /********************** Did select table cell  ***********************/
    /*********************************************************************/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.noteTableView {
            print("Name -\(noteList[indexPath.row].name), message - \(noteList[indexPath.row].message)")
            updateMessage = noteList[indexPath.row].message
            updateTitle = noteList[indexPath.row].name
            updateStatus = noteList[indexPath.row].status
            self.performSegue(withIdentifier: "notesToNoteDisplay", sender: nil) //segue to the notes screen
        }
    }
    
    /*********************************************************************/
    /************************** Add Note Button  *************************/
    /*********************************************************************/
    @objc func addNoteButtonPressed(sender:Any){
        print("add Note now")
        notification.notificationOccurred(.success) //haptic feedback
    }
    
    /*********************************************************************/
    /***************************** Save/Add Note  ****************************/
    /*********************************************************************/
    @IBAction func saveNoteButton(_ sender: Any) {
        let name = "\(titleTextField.text!)"
        let message = "\(messageTextField.text!)"
        let time = "\(NSDate())"
        let locationDB = self.db.child("Users/\(userID)/Locations/\(selectedLocation)/items/\(name)") //set location
        let locationDictionary : NSDictionary = ["name": name, "message": message, "status": 0, "time": time] //location dictionary to sell
        locationDB.setValue(locationDictionary) { //add the location dictionary to firebase
            (error, ref) in
            if error != nil {
                print(error!) //display if there is an error
            }
            else {
                /******* region list **********/
                for (regionIndex, region) in regionList.enumerated(){ //loop through the regionList
                    if (region.header == selectedLocation){ //if the region clicked header equals the identifier
                        regionList[regionIndex].notes.append(noteDisplay(name: name, message: message, time: time, status: 0)) //append note to region
                    }
                }
                print("Location saved successfully!") //print successfully
                self.previousViewController(viewCount: 2)
            }
        }
        titleTextField.text = ""
        messageTextField.text = ""
    }
    /*********************************************************************/
    /************************ Update Note Button  ************************/
    /*********************************************************************/
    @IBAction func updateNoteButton(_ sender: Any) {
        print("update note button pressed")
        print("submit") //print the submit button
        let title = titleTextField.text! //pull in the changed text in the text field
        let message = messageTextField.text! //pull in the changed message in the text field
        print(title)
        print(message)
        if title != "" || message != "" { //Check if the either field is empty
            /************* Firebase update **************/
            let oldLocationDB = self.db.child("Users/\(userID)/Locations/\(selectedLocation)/items/\(updateTitle)") //find the location of the old notes
            oldLocationDB.removeValue() //remove old note locations
            let locationDB = self.db.child("Users/\(userID)/Locations/\(selectedLocation)/items/\(title)") //set new location to save the new note
            let locationDictionary : NSDictionary = ["name": "\(title)", "message": "\(message)", "status": 0, "time": "\(NSDate())"] //create array to save the new note in firebase
            locationDB.setValue(locationDictionary) { //set the array in firebase
                (error, ref) in
                if error != nil {
                    print(error!) //Print if there is an error
                }
                else {
                    /******* region list **********/
                    for (regionIndex, region) in regionList.enumerated(){ //loop through the regionList
                        if (region.header == selectedLocation){ //if the region clicked header equals the identifier
                            for (index, notes) in region.notes.enumerated(){ //loop through the notes array
                                if (notes.name == title){ //if note is equal to the title of the note to delete
                                    regionList[regionIndex].notes.remove(at: index) //remove note
                                    regionList[regionIndex].notes.append(noteDisplay(name: "\(title)", message: "\(message)", time: "\(NSDate())", status: 0)) //append note to region
                                }
                            }
                        }
                    }
                    print("Location saved successfully!") //print if the note is saved
                    self.previousViewController(viewCount: 1)
                }
            }
        }
    }
    
    /*********************************************************************/
    /************************ Delete Note Button  ************************/
    /*********************************************************************/
    @IBAction func deleteNoteButton(_ sender: Any) {
        print("delete button pressed")
        let oldLocationDB = self.db.child("Users/\(userID)/Locations/\(selectedLocation)/items/\(updateTitle)") //find location to delete
        oldLocationDB.removeValue() //remove the values from the old location
        /******* region list **********/
        for (regionIndex, region) in regionList.enumerated(){ //loop through the regionList
            if (region.header == selectedLocation){ //if the region clicked header equals the identifier
                for (index, notes) in region.notes.enumerated(){ //loop through the notes array
                    if (notes.name == updateTitle){ //if note is equal to the title of the note to delete
                        regionList[regionIndex].notes.remove(at: index) //remove note
                    }
                }
            }
        }
        previousViewController(viewCount: 2)
    }
    
    @IBAction func returnHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*********************************************************************/
    /**************************** Note Display  **************************/
    /*********************************************************************/
    func displayNotes(header: String){
        print("header - \(header)")
        var collectNotes = [noteDisplay]() //Empty array to hold user
        //print("header = \(header)")
        for items in regionList{
            if header == items.header{
                print(header,items.header)
                for items in items.notes{ //loop through the all the items notes array
                    dump(items)
                    collectNotes.append(noteDisplay(name: items.name, message: items.message, time: items.time, status: items.status)) //append all user notes associated to the discription array
                }
            }
        }
        noteList = collectNotes
    }
    
    /*********************************************************************/
    /************** Transition to previous view controller ***************/
    /*********************************************************************/
    func previousViewController(viewCount: Int){
        for n in 1...viewCount {
            navigationController?.popViewController(animated: true) //return to previous page
        }
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
    func textFieldShouldReturn(messageTextField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        messageTextField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
}
