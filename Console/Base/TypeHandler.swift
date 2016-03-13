//
//  TypeHandler.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit


class TypeHandler {
    
    // MARK: TypeHandler -handle
    
    func handle(obj: AnyObject, _ name: String) -> AnyObject? {
        let sel = Selector(name)
        switch return_types(obj, name) {
        case "@":
            let inst = obj.performSelector(sel)
            if "Unmanaged<AnyObject>" == typeof(inst) {
                return convert(inst)
            } else {
                return inst as? AnyObject
            }
        case "{CGRect={CGPoint=dd}{CGSize=dd}}":
            typealias F = @convention(c) (AnyObject, Selector)-> CGRect
            return NSStringFromCGRect(extractMethodFrom(obj, sel, F.self)(obj, sel))
        case "d":
            typealias F = @convention(c) (AnyObject, Selector)-> Float
            return String(extractMethodFrom(obj, sel, F.self)(obj, sel))
        case let val:
            Log.info("val", val)
        }
        return nil
    }    
}


func extractMethodFrom<U>(owner: AnyObject, _ selector: Selector, _ F: U.Type) -> U {
    let method: Method
    if owner is AnyClass {
        method = class_getClassMethod(owner as! AnyClass, selector)
    } else {
        method = class_getInstanceMethod(owner.dynamicType, selector)
    }
    let implementation: IMP = method_getImplementation(method)
    return unsafeBitCast(implementation, F.self)
}