//
//  TypeHandler.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit



class TypeHandler {
    
    // MARK: TypeHandler - getter_handle
    func getter_handle(obj: AnyObject, _ name: String) -> (Bool, AnyObject?) {
        if let val = obj as? ValueType {
            return getter_valuetype(val, name)
        }
        
        let sel = Selector(name)
        guard obj.respondsToSelector(sel) else {
            return (false, nil)
        }
        let type = return_types(obj, name)
        switch type {
        case "@":
            if let inst = obj.performSelector(sel) {
                if "Unmanaged<AnyObject>" == typeof(inst) {
                    return (true, convert(inst))
                } else {
                    return (true, inst as? AnyObject)
                }
            } else {
                return (true, nil)
            }
        case "d": // d Double
            typealias F = @convention(c) (AnyObject, Selector)-> Double
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: value))
        case "q": // q CLongLong
            typealias F = @convention(c) (AnyObject, Selector)-> Int
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: value))
        case "Q": // Q CUnsignedLongLong
            typealias F = @convention(c) (AnyObject, Selector)-> UInt
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: value))
        case "{CGPoint=dd}":
            typealias F = @convention(c) (AnyObject, Selector)-> CGPoint
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: NSStringFromCGPoint(value)))
        case "{CGSize=dd}":
            typealias F = @convention(c) (AnyObject, Selector)-> CGSize
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: NSStringFromCGSize(value)))
        case "{CGRect={CGPoint=dd}{CGSize=dd}}":
            typealias F = @convention(c) (AnyObject, Selector)-> CGRect
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: NSStringFromCGRect(value)))
        case "{CGAffineTransform=dddddd}":
            typealias F = @convention(c) (AnyObject, Selector)-> CGAffineTransform
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: NSStringFromCGAffineTransform(value)))
        case "{CATransform3D=dddddddddddddddd}":
            typealias F = @convention(c) (AnyObject, Selector)-> CATransform3D
            let value = extractMethodFrom(obj, sel, F.self)(obj, sel)
            return (true, ValueType(type: type, value: NSStringFromCATransform3D(value)))
        case let val:
            Log.info("val", val)
        }
        return (false, nil)
    }
    
    func getter_valuetype(val: ValueType, _ name: String) -> (Bool, AnyObject?) {
        let value = val.value as! String
        switch val.type {
        case "{CGPoint=dd}":
            let point = CGPointFromString(value)
            switch name {
            case "x": return (true, point.x)
            case "y": return (true, point.y)
            default: return (false, nil)
            }
        case "{CGSize=dd}":
            let size = CGSizeFromString(value)
            switch name {
            case "width": return (true, size.width)
            case "height": return (true, size.height)
            default: return (false, nil)
            }
        case "{CGRect={CGPoint=dd}{CGSize=dd}}":
            let rect = CGRectFromString(value)
            switch name {
            case "origin":
                return (true, ValueType(type: "{CGPoint=dd}", value: NSStringFromCGPoint(rect.origin)))
            case "size":
                return (true, ValueType(type: "{CGSize=dd}", value: NSStringFromCGSize(rect.size)))
            default:
                return (false, nil)
            }
        case "{CGAffineTransform=dddddd}":
            let transform = CGAffineTransformFromString(value)
            switch name {
            case "a": return (true, Float(transform.a))
            case "b": return (true, Float(transform.b))
            case "c": return (true, Float(transform.c))
            case "d": return (true, Float(transform.d))
            case "tx": return (true, Float(transform.tx))
            case "ty": return (true, Float(transform.ty))
            default:
                return (false, nil)
            }
        case "{CATransform3D=dddddddddddddddd}":
            let transform = CATransform3DFromString(value)
            switch name {
            case "m11": return (true, Float(transform.m11))
            case "m12": return (true, Float(transform.m12))
            case "m13": return (true, Float(transform.m13))
            case "m14": return (true, Float(transform.m14))
            case "m21": return (true, Float(transform.m21))
            case "m22": return (true, Float(transform.m22))
            case "m23": return (true, Float(transform.m23))
            case "m24": return (true, Float(transform.m24))
            case "m31": return (true, Float(transform.m31))
            case "m32": return (true, Float(transform.m32))
            case "m33": return (true, Float(transform.m33))
            case "m34": return (true, Float(transform.m34))
            case "m41": return (true, Float(transform.m41))
            case "m42": return (true, Float(transform.m42))
            case "m43": return (true, Float(transform.m43))
            case "m44": return (true, Float(transform.m44))
            default:
                return (false, nil)
            }
        default:
            return (false, nil)
        }
    }

    // MARK: TypeHandler - setter_handle
    func setter_handle(obj: AnyObject, _ name: String, value: AnyObject?) {
        let method = "set" + name.uppercase_first() + ":"
        let sel = Selector(method)
        guard obj.respondsToSelector(sel) else {
            return
        }
        let type = argument_types(obj, method, nth: 2)
        if type != "@" && nil == value {
            return
        }
        dispatch_async(dispatch_get_main_queue(), {
            switch type {
            case "@":
                obj.performSelector(sel, withObject: value)
            case "d":
                typealias F = @convention(c) (AnyObject, Selector, Double) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, value as! Double)
            case "q":
                typealias F = @convention(c) (AnyObject, Selector, Int) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, value as! Int)
            case "Q":
                typealias F = @convention(c) (AnyObject, Selector, UInt)-> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, value as! UInt)
            case "{CGPoint=dd}":
                typealias F = @convention(c) (AnyObject, Selector, CGPoint) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, CGPointFromString(value as! String))
            case "{CGSize=dd}":
                typealias F = @convention(c) (AnyObject, Selector, CGSize) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, CGSizeFromString(value as! String))
            case "{CGRect={CGPoint=dd}{CGSize=dd}}":
                typealias F = @convention(c) (AnyObject, Selector, CGRect) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, CGRectFromString(value as! String))
            case "{CGAffineTransform=dddddd}":
                typealias F = @convention(c) (AnyObject, Selector, CGAffineTransform) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, CGAffineTransformFromString(value as! String))
            case "{CATransform3D=dddddddddddddddd}":
                typealias F = @convention(c) (AnyObject, Selector, CATransform3D) -> Void
                self.extractMethodFrom(obj, sel, F.self)(obj, sel, CATransform3DFromString(value as! String))
            case let val:
                Log.info("val", val)
            }
        })
    }
    
    // MARK: TypeHandler - typepair_function
    func typepair_function(name: String, _ args: [Float]) -> (Bool, AnyObject?) {
        switch name {
            
        case "CGRectMake":
            let rect = CGRectMake(CGFloat(args[0]), CGFloat(args[1]), CGFloat(args[2]), CGFloat(args[3]))
            return (false, NSStringFromCGRect(rect))
            
        default:
            break
        }
        return (true, nil)
    }
    
    // MARK: TypeHandler - typepair_constructor
    func typepair_constructor(name: String, _ args: [[AnyObject]]) -> (Bool, AnyObject?) {
        var dict = [String: AnyObject?]()
        for arg: [AnyObject] in args {
            if let k = arg.first as? String, let v = arg.last {
                dict[k] = v
            }
        }
        
        switch name {
            
        case "UIFont":
            if let name = dict["name"] as? String,
                let size = dict["size"] as? Float {
                return (false, UIFont(name: name, size: CGFloat(size)))
            }
            
        default:
            break
        }
        return (true, nil)
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

}



// MARK: ValueType
class ValueType: Equatable {
    var type: String
    var value: AnyObject
    init(type: String, value: AnyObject) {
        self.type = type
        self.value = value
    }
}

func ==(lhs: ValueType, rhs: ValueType) -> Bool {
    if lhs.type == rhs.type {
        switch lhs.type {
        case "d", "q", "Q":
            return lhs.value as? Double == rhs.value as? Double
        default:
            return lhs.value as? String == rhs.value as? String
        }
    } else {
        return false
    }
}

// MARK: CATransform3D
func CATransform3DFromString(str: String) -> CATransform3D {
    let scan = NSScanner(string: str)
    scan.scanLocation = "CATransform3D(m11: ".characters.count
    var m11: Float = 0; scan.scanFloat(&m11); scan.scanLocation += 7
    var m12: Float = 0; scan.scanFloat(&m12); scan.scanLocation += 7
    var m13: Float = 0; scan.scanFloat(&m13); scan.scanLocation += 7
    var m14: Float = 0; scan.scanFloat(&m14); scan.scanLocation += 7
    var m21: Float = 0; scan.scanFloat(&m21); scan.scanLocation += 7
    var m22: Float = 0; scan.scanFloat(&m22); scan.scanLocation += 7
    var m23: Float = 0; scan.scanFloat(&m23); scan.scanLocation += 7
    var m24: Float = 0; scan.scanFloat(&m24); scan.scanLocation += 7
    var m31: Float = 0; scan.scanFloat(&m31); scan.scanLocation += 7
    var m32: Float = 0; scan.scanFloat(&m32); scan.scanLocation += 7
    var m33: Float = 0; scan.scanFloat(&m33); scan.scanLocation += 7
    var m34: Float = 0; scan.scanFloat(&m34); scan.scanLocation += 7
    var m41: Float = 0; scan.scanFloat(&m41); scan.scanLocation += 7
    var m42: Float = 0; scan.scanFloat(&m42); scan.scanLocation += 7
    var m43: Float = 0; scan.scanFloat(&m43); scan.scanLocation += 7
    var m44: Float = 0; scan.scanFloat(&m44)
    return CATransform3D(
        m11: CGFloat(m11), m12: CGFloat(m12), m13: CGFloat(m13), m14: CGFloat(m14),
        m21: CGFloat(m21), m22: CGFloat(m22), m23: CGFloat(m23), m24: CGFloat(m24),
        m31: CGFloat(m31), m32: CGFloat(m32), m33: CGFloat(m33), m34: CGFloat(m34),
        m41: CGFloat(m31), m42: CGFloat(m42), m43: CGFloat(m43), m44: CGFloat(m44))
}

func NSStringFromCATransform3D(transform: CATransform3D) -> String {
    return String(transform)
}