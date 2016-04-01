//
//  RootViewController.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/20/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = AppConsole(initial: self).run()
    }
}