//
//  Console.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit
import Swifter
import NetUtils

public class AppConsole {
    
    var initial: UIViewController
    let server = HttpServer()

    public init(initial: UIViewController) {
        self.initial = initial
    }
    
    
    // MARK: AppConsole - run
    
    public func run(port: Int = 8080) -> String {
        ConsoleRouter().route(server, initial: initial)
        try! server.start(UInt16(port))
        let url = "http://\(localip()):\(port)"
        Log.info("Console Server has started on \(url)")
        return url
    }
    
    func localip() -> String {
        for interface in Interface.allInterfaces() {
            if (interface.getName() == "en0") && (interface.getFamily().toString() == "IPv4") {
                if let addr = interface.getAddress() {
                    return addr
                }
            }
        }
        return "localhost"
    }
}