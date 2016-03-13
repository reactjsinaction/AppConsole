//
//  TypeHandlerTests.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit

class TypeHandlerTests: WTestCase {

    func test_handler() {
        let handler = TypeHandler()
        let view = UIView(frame: CGRectMake(0,0,100,100))
        Assert.equal("{{0, 0}, {100, 100}}", handler.handle(view, "frame") as? String)
    }
    
}
