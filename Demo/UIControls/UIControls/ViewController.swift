//
//  ViewController.swift
//  UIControls
//
//  Created by wookyoung on 5/1/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var button: UIButton!
    @IBOutlet var switch_: UISwitch!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var slider: UISlider!
    @IBOutlet var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        label.text = AppConsole(initial: self).run()
    }

    @IBAction func tapControl(sender: UIControl) {
        Log.info("tap", sender)
    }
    
    @IBAction func valueChanged(sender: UIControl) {
        Log.info("valueChanged", sender)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

