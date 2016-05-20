//
//  TypeHandlerTests.swift
//  TestApp
//
//  Created by wookyoung on 4/3/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit

import XCTest

class TypeHandlerTests: XCTestCase {
    
    func test_getter_handle() {
        let handler = TypeHandler()
        let view = UIView(frame: CGRectMake(0,0,100,100))
        let (_, val) = handler.getter_handle(view, "frame")
        let frame = (val as! ValueObject).value as? String
        Assert.equal("{CGRect={CGPoint=dd}{CGSize=dd}}", (val as! ValueObject).type)
        Assert.equal("{{0, 0}, {100, 100}}", frame)
    }
    
    func test_setter_handle() {
        let handler = TypeHandler()
        let view = UIView(frame: CGRectZero)
        
        let rect = CGRectMake(0,0,100,100)
        handler.setter_handle(view, "setFrame:", value: NSStringFromCGRect(rect), second: nil)
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            //            let (_, val) = handler.getter_handle(view, "frame")
            //            let frame = (val as! ValueType).value as? String
            //            Log.info("frame", frame)
        })
    }
    
    func test_UIFontFromString() {
        if let font = UIFontFromString("<UICTFont: 0x7fe6cc035190> font-family: \"Helvetica\"; font-weight: normal; font-style: normal; font-size: 25.00pt>") {
            Assert.equal(25.00, font.pointSize)
        }
    }

    func test_UIColorFromString() {
        let color = UIColorFromString("UIDeviceRGBColorSpace 0 1 1 1")
        Assert.equal("UIDeviceRGBColorSpace 0 1 1 1", String(color))

        let white = UIColorFromString("UIDeviceWhiteColorSpace 0 1")
        Assert.equal("UIDeviceWhiteColorSpace 0 1", String(white))
    }

}