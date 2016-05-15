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
    
    var initial: AnyObject
    let server = HttpServer()

    public init(initial: AnyObject) {
        self.initial = initial
    }
    
    // MARK: AppConsole - run
    public func run(port: Int = 8080, _ block: (ConsoleRouter->Void)? = nil) -> String {
        let router = ConsoleRouter()
        router.route(server, initial: initial)
        try! server.start(UInt16(port))
        let url = "http://\(localip()):\(port)"
        Log.info("AppConsole Server has started on \(url)")
        block?(router)
        return url
    }
    
    func localip() -> String {
        for interface in Interface.allInterfaces() {
            if (interface.name == "en0") {
                if ["IPv4"].contains(interface.family.toString()) {
                    if let addr = interface.address {
                        return addr
                    }
                }
            }
        }
        return "localhost"
    }
}