//
//  ViewController.swift
//  TestApp
//
//  Created by wookyoung on 4/3/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit



class A {
    var s = "a string"
    var n = 1
    var b = true
    var t = (5,6)
    func f() -> String {
        return "a call"
    }
    init() {
    }
}

let a = A()



class B: NSObject {
    var s = "b string"
    var n = 0
    var b = false
    var t = (5,6)
    func f() -> String {
        return "b call"
    }
    override init() {
    }
}

let b = B()



class ViewController: UIViewController {
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        label.text = AppConsole(initial: self).run { app in
            app.register("a", object: a)
            app.register("b", object: b)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

