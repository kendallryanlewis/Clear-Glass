//
//  InterfaceController.swift
//  GeoFence (watch) Extension
//
//  Created by Kendall Lewis on 5/4/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    let tableData = ["one","two", "three", "four", "five", "six", "seven", "eight", "nine" , "ten"]
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadDataTabel()
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func loadDataTabel() {
        tableView.setNumberOfRows(tableData.count, withRowType: "locationRowController")
        
        
        for (index, roleModel) in tableData.enumerated(){
            if let rowController = tableView.rowController(at: index) as? locationRowController {
                rowController.locationRowLabel.setText(roleModel)
            }
        }
    }
}
