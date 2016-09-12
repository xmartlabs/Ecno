//
//  ViewController.swift
//  Example
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import UIKit
import Twice

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    let task = "Tap button 3 times task"

    override func viewDidLoad() {
        super.viewDidLoad()
        Twice.initialize()
        button.setTitle("Tap me 3 times!", for: UIControlState())
    }

    @IBAction func buttonDidTouch(_ sender: UIButton) {
        Twice.markDone(task)
        if Twice.beenDone(task, scope: .appSession, numberOfTimes: .moreThan(2)) {
            let alert = UIAlertController(title: "Congratulations", message: "You have tapped three times", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            show(alert, sender: nil)
            Twice.clearDone(task)
        }
    }

}
