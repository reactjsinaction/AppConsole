//
//  ConsoleRouterTests.swift
//  TestApp
//
//  Created by wookyoung on 4/14/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation
import XCTest

class ConsoleRouterTests: XCTestCase {

    func test_result() {
        let router = ConsoleRouter()
        Assert.True( .OK(.Json(["typ": "any", "value": 1])) == router.result(1) )
        Assert.True( .OK(.Json(["typ": "string", "value": "hello"])) == router.result("hello") )
    }

}
