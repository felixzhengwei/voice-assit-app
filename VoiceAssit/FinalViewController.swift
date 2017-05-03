//
//  FinalViewController.swift
//  VoiceAssit
//
//  Created by Felix Wei on 2017-04-30.
//  Copyright © 2017 Felix Wei. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {

    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        okayButton.layer.cornerRadius = 8
        backButton.layer.cornerRadius = 8
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
