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
        let frame = (val as! ValueType).value as? String
        Assert.equal("{CGRect={CGPoint=dd}{CGSize=dd}}", (val as! ValueType).type)
        Assert.equal("{{0, 0}, {100, 100}}", frame)
    }
    
    func test_setter_handle() {
        let handler = TypeHandler()
        let view = UIView(frame: CGRectZero)
        
        let rect = CGRectMake(0,0,100,100)
        handler.setter_handle(view, "frame", value: NSStringFromCGRect(rect))
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            //            let (_, val) = handler.getter_handle(view, "frame")
            //            let frame = (val as! ValueType).value as? String
            //            Log.info("frame", frame)
        })
    }
    
    func test_CATransform3DFromString() {
        let t = CATransform3DFromString("CATransform3D(m11: 1.0, m12: 2.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)")
        Assert.equal(1.0, t.m11)
        Assert.equal(2.0, t.m12)
    }
    
}