//
//  XCTest.swift
//  Test
//
//  Created by wookyoung on 2/22/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

import XCTest
typealias WTestCase = XCTestCase

class AssertBase {
    
    func equal<T: Equatable>(expression1: T?, _ expression2: T?, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message, file: file, line: line)
    }
    
    func equal<T: Equatable>(expression1: T, _ expression2: T, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message, file: file, line: line)
    }
    
    func equal<T: Equatable>(expression1: [T], _ expression2: [T], _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message, file: file, line: line)
    }
    
    func equal<T: Equatable>(expression1: ArraySlice<T>, _ expression2: ArraySlice<T>, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message, file: file, line: line)
    }
    
    func True(expression: BooleanType, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertTrue(expression, message, file: file, line: line)
    }
    
    // (Int, Int)
    func equal(expression1: (Int,Int), _ expression2: (CGFloat, CGFloat), _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        let a = (CGFloat(expression1.0), CGFloat(expression1.1))
        equal(a, expression2, file: file, function: function, line: line)
    }
    
    func equal(expression1: (CGFloat,CGFloat), _ expression2: (CGFloat, CGFloat), _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(String(expression1), String(expression2), message, file: file, line: line)
    }
    
    // NSRange
    func equal(expression1: NSRange, _ expression2: NSRange, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(String(expression1), String(expression2), message, file: file, line: line)
    }
}

let Assert = AssertBase()