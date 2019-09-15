//
//  locationView.swift
//  GeoFence
//
//  Created by Kendall Lewis on 7/23/19.
//  Copyright © 2019 Kendall Lewis. All rights reserved.
//

import UIKit

class locationView: UIView {
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationNotes: UILabel!
    @IBOutlet weak var locationIndex: UILabel!
    @IBOutlet weak var tabBackground: UIView!
    @IBOutlet weak var divderView: UIView!
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var notesView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView() -> locationView{
        let locationView = Bundle.main.loadNibNamed("customInfoWindow", owner: self, options: nil)?.first as? locationView
        return locationView!
    }
}

