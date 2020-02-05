import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import ChromaColorPicker

var menuList = [menuDisplay(menuItem: String(systemCollection!.systemName), menuDetails: Int(0)),
                menuDisplay(menuItem: "Locations", menuDetails: Int(3)),
                menuDisplay(menuItem: "Show Geofence", menuDetails: Int(0)),
                menuDisplay(menuItem: "3D View", menuDetails: Int(0)),
                menuDisplay(menuItem: "Map View", menuDetails: Int(4)),
                menuDisplay(menuItem: "Theme Settings", menuDetails: Int(5)),
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
                    if menuList[indexPath.row].menuDetails == 0{ //if menu detail is 0 do not display
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
            if(menuList[indexPath.row].menuItem == menuList[3].menuItem){
                let switchView = UISwitch(frame: .zero)
                switchView.setOn(false, animated: true)
                switchView.thumbTintColor = UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0)
                switchView.layer.cornerRadius = 1
                switchView.tag = indexPath.row // for detect which row switch Changed
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                cell!.accessoryView = switchView
                switchView.backgroundColor = UIColor.lightGray
                switchView.layer.cornerRadius = 16.0
                switchView.onTintColor = UIColor.white
                switchView.thumbTintColor = UIColor().HexToColor(hexString: colorCollection!.systemMenuButton, alpha: 1.0)
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
    @objc func switchChanged(_ sender : UISwitch!){
          print("table row switch Changed \(sender.tag)")
          print("The switch is \(sender.isOn ? "ON" : "OFF")")
        if (sender.isOn == true){
            mapCollection!.system3DDisplay = 90
            createMapView() //Create map for view
            print("3D display active")
        }else{
            mapCollection!.system3DDisplay = 0
            createMapView() //Create map for view
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ //Delay 2 secs then segue.
            self.closeMenu()//close the menu
        }
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
            }else if menuList[indexPath.row].menuItem == "Theme Settings"{
                print("Theme Settings")
                closeMenu()//close the menu
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){ //Delay 2 secs then segue.
                /*
                let alert = UIAlertController(title: "Theme",message: "Change theme color", preferredStyle: .actionSheet)
                let doneAction = UIAlertAction(title: "Done", style: .cancel, handler: {(alert: UIAlertAction!) in print("Done")})
                    

                    
                    
                alert.addAction(doneAction)
 */
                let alertController = UIAlertController(title: "Theme",message: "Change theme color", preferredStyle: .actionSheet)
               //let neatColorPicker = ChromaColorPicker(frame: CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 500))
                    //neatColorPicker.delegate = self as? ChromaColorPickerDelegate //ChromaColorPickerDelegate
               //neatColorPicker.padding = 5
               //neatColorPicker.stroke = 3
               //neatColorPicker.hexLabel.textColor = UIColor.white
                    
                    
                /* Calculate relative size and origin in bounds */
                let pickerSize = CGSize(width: alertController.view.bounds.width*0.8, height: alertController.view.bounds.width*0.8)
                let pickerOrigin = CGPoint(x: alertController.view.bounds.midX - pickerSize.width/2, y: alertController.view.bounds.midY - pickerSize.height)
                let neatColorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
                neatColorPicker.padding = 0
                neatColorPicker.hexLabel.isHidden = true
                neatColorPicker.adjustToColor(UIColor.green)
                //neatColorPicker.supportsShadesOfGray = true // Normally false be default
                neatColorPicker.layout()

                alertController.view.translatesAutoresizingMaskIntoConstraints = false
                alertController.view.heightAnchor.constraint(equalToConstant: 600).isActive = true
                alertController.view.addSubview(neatColorPicker)
                //neatColorPicker.center = self.view.center
                neatColorPicker.center.x = self.view.center.x

                    
                let selectAction = UIAlertAction(title: "Select", style: .default) { (action) in
                    print("selection")
                    let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                
                    neatColorPicker.supportsShadesOfGray = true // Normally false be default
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alertController.addAction(selectAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                    

                

                    
                /*
                subview.layer.cornerRadius = 0
                subview.layer.borderWidth = 1
                subview.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
                subview.layer.opacity = 0.7
                subview.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
                subview.layer.shadowOpacity = 1
                subview.layer.shadowOffset = CGSize.zero //ets how far away
                subview.backgroundColor = UIColor(red: (195/255.0), green: (68/255.0), blue: (122/255.0), alpha: 1.0)
              
                    
                    
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion:{})
                }
                    
                    
                    
                    
                    */
                                      
                    
                    /*
                    let alert = UIAlertController(title: "Theme",message: "Change theme color", preferredStyle: .actionSheet)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                    alert.addAction(dismissAction)
                    self.present(alert, animated: true, completion:  nil)
                    // change the background color

                    let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
                    subview.layer.cornerRadius = 0
                    subview.layer.borderWidth = 1
                    subview.layer.borderColor = UIColor().HexToColor(hexString: colorCollection!.systemBackground , alpha: 1.0).cgColor
                    subview.layer.opacity = 0.7
                    subview.layer.shadowColor = UIColor.black.cgColor //sets the color of the shadow, and needs to be a CGColor
                    subview.layer.shadowOpacity = 1
                    subview.layer.shadowOffset = CGSize.zero //ets how far away
                    subview.layer.shadowColor = UIColor().HexToColor(hexString: "#000000" , alpha: 1.0).cgColor
                    subview.backgroundColor = UIColor(red: (195/255.0), green: (68/255.0), blue: (122/255.0), alpha: 1.0)*/
                }
            }else if menuList[indexPath.row].menuItem == "3D View"{
                print("3D View")
            }else if menuList[indexPath.row].menuItem == "Map View"{
                print("Pull up Map View")
                let alertController = UIAlertController(title: "Theme",message: "Change theme color", preferredStyle: .actionSheet)
                alertController.view.translatesAutoresizingMaskIntoConstraints = false
                alertController.view.heightAnchor.constraint(equalToConstant: 600).isActive = true
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let defaultAction = UIAlertAction(title: "Default", style: .default, handler: { (action) in
                    setMapView = false
                    self.createMapView() //Create map for view
                })
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 70, width: alertController.view.frame.width - 15, height: 405))
                var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
                
                scrollView.delegate = self
                scrollView.isPagingEnabled = true
                self.view.addSubview(scrollView)
                for index in 0...4 {
                    let subView = UIView(frame: frame)
                    let viewButton = UIButton()
                    if (index == 1) {
                        viewButton.tag = 1
                        viewButton.backgroundColor = UIColor(patternImage: UIImage(named: "paperMap.jpeg")!)
                    } else if (index == 2) {
                        viewButton.tag = 2
                        viewButton.backgroundColor = UIColor(patternImage: UIImage(named: "grayscaleMap.jpeg")!)
                    }else if (index == 3){
                        viewButton.tag = 3
                        viewButton.backgroundColor = UIColor(patternImage: UIImage(named: "darkMap.jpeg")!)
                    }else if (index == 4){
                        viewButton.tag = 4
                        viewButton.backgroundColor = UIColor(patternImage: UIImage(named: "retroMap.jpeg")!)
                    }
                    frame.origin.x = scrollView.frame.size.width * CGFloat(index)
                    frame.size = scrollView.frame.size
                    viewButton.layer.cornerRadius = 10
                    viewButton.frame = CGRect(x: 10, y: 0, width: frame.size.width - 20, height: frame.size.height - 10)
                    viewButton.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
                    subView.addSubview(viewButton)
                    //subView.backgroundColor = backgroundColors[index]
                    scrollView.addSubview(subView)
                }
                scrollView.contentSize = CGSize(width:scrollView.frame.size.width * 4,height: scrollView.frame.size.height)
                alertController.view.addSubview(scrollView)
                alertController.addAction(defaultAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                closeMenu()//close the menu
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
    @objc func pressed(sender: UIButton!) {
        setMapView = true
        switch sender.tag{
        case 1:
            mapView.mapStyle(withFilename: "paper", andType: "json")
        case 2:
            mapView.mapStyle(withFilename: "grayscale", andType: "json")
        case 3:
            mapView.mapStyle(withFilename: "dark", andType: "json")
        case 4:
            mapView.mapStyle(withFilename: "retro", andType: "json")
        default:
            mapView.mapStyle(withFilename: "default", andType: "json")
        }
        dismiss(animated: true, completion: nil)
    }

    func createSwitch () -> UISwitch{
        let switchControl = UISwitch(frame:CGRect(x: 10, y: 20, width: 0, height: 0));
        switchControl.isOn = true
        switchControl.setOn(true, animated: false);
        //switchControl.addTarget(self, action: "switchValueDidChange:", for: .valueChanged);
        return switchControl
    }
    
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == self.noteTableView{ //Select the menu list
            let editAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "edit") { (action , indexPath) -> Void in
                self.isEditing = false
                print("Edit button pressed")
                updateMessage = noteList[indexPath.row].message
                self.updateTitle = noteList[indexPath.row].name
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
extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}
