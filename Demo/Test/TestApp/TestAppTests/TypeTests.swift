//
//  ValueTypeTests.swift
//  TestApp
//
//  Created by wookyoung on 4/15/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

import XCTest

class TypeTests: XCTestCase {

    func test_valuetype() {
        let val = ValueType(type: "q", value: 1)
        Assert.equal(1, val.value as? Int)
    }

    func test_chaintype() {
        Assert.equal(ChainType.Go, ChainType.Go)
        Assert.equal(ChainType.Stop, ChainType.Stop)
    }

    func test_typematchtype() {
        Assert.equal(TypeMatchType.Match, TypeMatchType.Match)
        Assert.equal(TypeMatchType.None, TypeMatchType.None)
    }

}
