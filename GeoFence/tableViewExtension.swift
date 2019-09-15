import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps

var menuList = [menuDisplay(menuItem: String(systemCollection!.systemName), menuDetails: Int(0)),
                menuDisplay(menuItem: "Locations", menuDetails: Int(3)),
                menuDisplay(menuItem: "Show Geofence", menuDetails: Int(0)),
                menuDisplay(menuItem: "Settings", menuDetails: Int(0)),
                menuDisplay(menuItem: "Help", menuDetails: Int(1)),
                menuDisplay(menuItem: "Logout", menuDetails: Int(0))]

var  description = [noteDisplay]() //Empty array to hold user notes

class menuDisplay {
    var menuItem = ""
    var menuDetails = 0
    init(menuItem: String, menuDetails:Int) {
        self.menuItem = menuItem
        self.menuDetails = menuDetails
    }
    deinit {
        print("Menu display has been allocted")
    }
}

class menuCell: UITableViewCell{ //Edit the menu cells
    @IBOutlet weak var menuItem: UILabel!
    @IBOutlet weak var menuDetails: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBInspectable var selectionColor: UIColor = .black {//adds selection color feature
        didSet {
            configureSelectedBackgroundView()
        }
    }
    func configureSelectedBackgroundView() {
        let view = UIView()
        view.backgroundColor = selectionColor
        selectedBackgroundView = view
        view.layer.masksToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.23
        view.layer.shadowRadius = 4
    }
}

class searchCell: UITableViewCell{ //Edit the menu cells
    @IBOutlet weak var searchName: UILabel!
    @IBOutlet weak var searchItem: UILabel!
    @IBOutlet weak var searchType: UILabel!
    @IBOutlet weak var searchIndex: UILabel!
    @IBOutlet weak var searchDistance: UILabel!
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        // code to check for a particular tableView.
        if tableView == self.menuTableView //access the menu table view
        {
            count = menuList.count
        } else if tableView == self.searchTableView //access the menu table view
        {
            count = resultsArray.count
        } else if tableView == self.noteTableView
        {
            count = noteList.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.menuTableView {//access the menu table view
            var cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! menuCell?
            if cell == nil {
                tableView.register(menuCell.classForCoder(), forCellReuseIdentifier: "menuCell")
                cell = menuCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "menuCell")
            }
            if let label = cell?.menuItem{ //populate cell with menu item name
                label.text = menuList[indexPath.row].menuItem
                
            } else {
                cell?.textLabel?.text = menuList[indexPath.row].menuItem
            }
            if let label = cell?.menuDetails{ //populate cell with menu details
                if (menuList[indexPath.row].menuItem != "Locations") {
                    if menuList[indexPath.row].menuDetails == 0{ //if menu detail is 0 do not display
                        label.text = ""
                    }else{
                        label.text = String(menuList[indexPath.row].menuDetails)
                    }
                } else {
                    label.text = String(regionList.count)
                }
            } else {
                if (menuList[indexPath.row].menuItem != "Locations") {
                    if menuList[indexPath.row].menuDetails == 0{ ////if menu detail is 0 do not display
                        cell?.textLabel?.text = ""
                    }else{
                        cell?.textLabel?.text = String(menuList[indexPath.row].menuDetails)
                    }
                } else {
                    cell?.textLabel?.text = String(regionList.count)
                }
            }
            if(menuList[indexPath.row].menuItem == menuList[0].menuItem){
                cell?.menuIcon?.image = UIImage(named: "Account")
            }else{
                cell?.menuIcon?.image = UIImage(named: menuList[indexPath.row].menuItem)
            }
            return cell!
        } else if tableView == self.noteTableView{ //ensure to attach datasource and delegate
            //dump(noteList)
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
            if (noteList[indexPath.row].status == 0){
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
            }
            addNoteButton.addTarget(self, action: #selector(addNoteButtonPressed(sender: )), for: .touchUpInside)
            addNoteButton.tag =  indexPath.row
            return cell!
        }else if tableView == self.searchTableView {//access the menu table view
            print("search cell table view")
            var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! searchCell?
            if cell == nil {
                tableView.register(searchCell.classForCoder(), forCellReuseIdentifier: "searchCell")
                cell = searchCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "searchCell")
            }
            if let label = cell?.searchName{ //populate cell with menu item name
                let place = self.resultsArray[indexPath.row]
                label.text = "\(place["name"] as!String)"
                print("\(place["name"] as!String)")
            } else {
                let place = self.resultsArray[indexPath.row]
                cell?.textLabel?.text = "\(place["name"] as!String)"
                print("\(place["name"] as!String)")
            }
            if let label = cell?.searchItem{ //populate cell with menu item name
                let place = self.resultsArray[indexPath.row]
                label.text = "\(place["formatted_address"] as! String)"
                print("\(place["formatted_address"] as! String)")
            } else {
                let place = self.resultsArray[indexPath.row]
                cell?.textLabel?.text = "\(place["formatted_address"] as! String)"
                print("\(place["formatted_address"] as! String)")
            }
            if let label = cell?.searchType{ //populate cell with menu item name
                let place = self.resultsArray[indexPath.row]
                label.text = "\(place["types"] as! Array<String>)"
                print("\(place["types"] as! Array<String>)")
            } else {
                let place = self.resultsArray[indexPath.row]
                cell?.textLabel?.text = "\(place["types"] as! Array<String>)"
            }
            if let label = cell?.searchIndex{
                label.text = String(indexPath.row + 1)
            }else{
                cell?.textLabel?.text = String(indexPath.row + 1)
                
            }
            
            let place = self.resultsArray[indexPath.row]
            print("place \(place["coordinate"]?.latitude as Any)")
            if let label = cell?.searchDistance{
                let place = self.resultsArray[indexPath.row]
                label.text = "\(place["name"] as!String)"
            }else{
                let place = self.resultsArray[indexPath.row]
                cell?.textLabel?.text = "\(place["name"] as!String)"
            }
            return cell!
        }
        return UITableViewCell()
    }
    
    @objc func addNoteButtonPressed(sender:Any){
        print(selectedLocation)
        notification.notificationOccurred(.success) //haptic feedback
    }
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {//disables swipe to delete function for specific cells
       if tableView == menuTableView { //access the menu table view
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//cells that were selected item
        if tableView == menuTableView{ //Select the menu list
            if menuList[indexPath.row].menuItem == String(systemCollection!.systemName){
                print(String(systemCollection!.systemName))
                //performSegue(withIdentifier: "mainToAccount", sender: self)//segues to the settings page
            }else if menuList[indexPath.row].menuItem == "Locations"{
                print("Locations")
                closeMenu() //close the menu
                //searchField.isHidden = true //hide search menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ //Delay 2 secs then segue.
                    self.performSegue(withIdentifier: "mainToLocation", sender: nil)//segues to the settings page
                }
            }else if menuList[indexPath.row].menuItem == "Settings"{
                print("Settings")
                closeMenu()//close the menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){ //Delay 2 secs then segue.
                    self.performSegue(withIdentifier: "mainToSettings", sender: nil)//segues to the settings page
                }
            }else if menuList[indexPath.row].menuItem == "Help"{
                print("Help")
                performSegue(withIdentifier: "mainToHelp", sender: nil)//segues to the feed page
            }else if menuList[indexPath.row].menuItem == "Show Geofence"{
                
                UIView.transition(with: self.navigationController!.view, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: nil, completion: nil)
                if (geofenceDisplay == false){
                    geoMapView.isHidden = true//hide menu
                    geofenceDisplay = true
                }else{
                    geoMapView.isHidden = false//show menu
                    geofenceDisplay = false
                    print("Displaying GeoFence")
                }
                closeMenu()
            }else if menuList[indexPath.row].menuItem == "Logout"{
                print("Logout")
                handleLogout()
            }
        } else if(tableView == noteTableView) {
            updateMessage = noteList[indexPath.row].message
            updateTitle = noteList[indexPath.row].name
            updateStatus = noteList[indexPath.row].status
            self.performSegue(withIdentifier: "mainToNoteDisplay", sender: nil) //segue to the notes screen
        } else if tableView == searchTableView { //Select the menu list
            searchTableView.deselectRow(at: indexPath, animated: true)
            getSearchLocation(indexPath: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == self.noteTableView{ //Select the menu list
            let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "edit") { (action , indexPath) -> Void in
                self.isEditing = false
                print("Edit button pressed")
                updateMessage = noteList[indexPath.row].message
                updateTitle = noteList[indexPath.row].name
                updateStatus = noteList[indexPath.row].status
                self.performSegue(withIdentifier: "mainToNoteDisplay", sender: nil) //segue to the notes screen
            }
            editAction.backgroundColor = UIColor.gray
            return[editAction]
        }else if tableView == searchTableView{
            let addAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Add") { (action , indexPath ) -> Void in
                self.isEditing = false
                print("Add button pressed")
            }
            addAction.backgroundColor = UIColor.green
            return[addAction]
        }
        return [UITableViewRowAction].init()
    }
    
    func handleLogout(){
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                activeUser = false //set user to inactive
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "activeUser") //set user to inactive
                UserDefaults.standard.set("", forKey: "activeUserID")
                UserDefaults.standard.set("", forKey: "region")
                regionList.removeAll()
                locationManager.stopUpdatingLocation()//stop updating to increase battery
                
                //let loginManager = FBSDKLoginManager() //facebook log out
                //loginManager.logOut() // this is an instance function
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                
                self.performSegue(withIdentifier: "mainToIntro", sender: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
