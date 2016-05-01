//
//  ViewController.swift
//  TableViewController
//
//  Created by wookyoung on 4/3/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = AppConsole(initial: self).run()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let colors: [(String,UIColor)] = [
        ("red",.redColor()),
        ("blue",.blueColor()),
        ("green",.greenColor()),
        ("yellow",.yellowColor()),
        ("brown",.brownColor()),
        ("cyan",.cyanColor()),
        ]

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = colors[indexPath.row].0
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Log.info("didselect", indexPath)
        let color = colors[indexPath.row].1
        let identifier = "ColorViewController"
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier(identifier)
        controller.view.backgroundColor = color
        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
