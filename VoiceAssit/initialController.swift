//
//  initialController.swift
//  VoiceAssit
//
//  Created by Felix Wei on 2017-04-29.
//  Copyright © 2017 Felix Wei. All rights reserved.
//

import UIKit
import Foundation


class initialController: UIViewController {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var washroomButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var nauseaButton: UIButton!
    @IBOutlet weak var earlyDischargeButton: UIButton!
    @IBOutlet weak var painButton: UIButton!
    
    @IBOutlet weak var washroomWidth: NSLayoutConstraint!
    @IBOutlet weak var dischargeWidth: NSLayoutConstraint!
    @IBOutlet weak var otherWidth: NSLayoutConstraint!
    @IBOutlet weak var nauseaWidth: NSLayoutConstraint!
    @IBOutlet weak var painWidth: NSLayoutConstraint!
    @IBOutlet weak var foodWidth: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        foodButton.layer.cornerRadius = 8
        nauseaButton.layer.cornerRadius = 8
        otherButton.layer.cornerRadius = 8
        washroomButton.layer.cornerRadius = 8
        earlyDischargeButton.layer.cornerRadius = 8
        painButton.layer.cornerRadius = 8
        
        foodWidth.constant = (screenSize.width / 2.5)
        painWidth.constant = (screenSize.width / 2.5)
        nauseaWidth.constant = (screenSize.width / 2.5)
        otherWidth.constant = (screenSize.width / 2.5)
        washroomWidth.constant = (screenSize.width / 2.5)
        dischargeWidth.constant = (screenSize.width / 2.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func foodAction(_ sender: Any) {
        Helper.postRequest(message: "I want some food")
        
    }
    
    @IBAction func washroomAction(_ sender: Any) {
        Helper.postRequest(message: "I need to use the washroom")
    }
    
    @IBAction func painAction(_ sender: Any) {
        Helper.postRequest(message: "This is an emergency")
    }
    
    @IBAction func nauseaAction(_ sender: UIButton) {
        Helper.postRequest(message: "I feel nauseous")
    }
    
    @IBAction func dischargeAction(_ sender: UIButton) {
        Helper.postRequest(message: "I want early discharge")
    }
    
    @IBAction func otherAction(_ sender: UIButton) {
    }
}
