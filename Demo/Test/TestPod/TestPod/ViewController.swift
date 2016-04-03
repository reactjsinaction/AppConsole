//
//  ViewController.swift
//  TestPod
//
//  Created by wookyoung on 4/3/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit
import AppConsole

class ViewController: UIViewController {
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = AppConsole(initial: self).run()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}