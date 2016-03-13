//
//  ConsoleRouter.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation
import Swifter


class ConsoleRouter {
    
    let type_handler = TypeHandler()
    var env = [String: AnyObject]()
    
    enum FailType {
        case failed
    }
    
    
    // MARK: ConsoleRouter - route
    func route(server: HttpServer, initial: UIViewController) {

        server["/"] = { req in
            let info = [String]()
            return self.result(info)
        }
        
        server["/initial"] = { req in
            let info = self.push_to_env(initial)
            return self.result(info)
        }
        
        server["/query"] = { req in
            if let type = req.query["type"], lhs = req.query["lhs"] {
                switch type {
                case "Property":
                    if let prop = self.chain_getter(lhs) {
                        return self.result(prop)
                    } else {
                        return self.result(0)
                    }
                case "Assign":
                    if let rhs = req.query["rhs"] {
                        if let obj = self.chain(nil, self.json_parse(lhs), full: false),
                            let val = self.chain_getter(rhs) {
                                self.chain_setter(obj, lhs: lhs, val: val)
                                return self.result(val)
                        } else {
                            return self.result(.failed)
                        }
                    }
                default:
                    break
                }
            }
            return self.result(1)
        }
    }

    // MARK: ConsoleRouter - result
    func result(type: FailType) -> HttpResponse {
        switch type {
        case .failed:
            return .OK(.Json(["failed": String(type)]))
        }
    }
    
    func result(value: AnyObject) -> HttpResponse {
        switch value {
        case is Int:
            return .OK(.Json(["result": value]))
        case is String:
            return .OK(.Json(["result": value]))
        case is [String: String]:
            return .OK(.Json(["result": value]))
        case is [String]:
            return .OK(.Json(["result": value]))
        default:
            return .OK(.Json(["result": String(value)]))
        }
    }
}





// MARK: ConsoleRouter - chains

extension ConsoleRouter {
    
    func chain_getter(lhs: String) -> AnyObject? {
        let vec: [String] = json_parse(lhs)
        let object = chain(nil, vec, full: false)
        if vec.count == 1 {
            return object
        } else {
            if let obj = object {
                if let name = vec.last {
                    let method = var_or_method(name)
                    if obj.respondsToSelector(Selector(method)) {
                        return type_handler.handle(obj, method)
                    }
                }
            }
        }
        return nil
    }

    func chain_setter(obj: AnyObject, lhs: String, val: AnyObject?) -> AnyObject? {
        let vec: [String] = json_parse(lhs)
        if let name = vec.last {
            let method = "set" + name.uppercase_first() + ":"
            let sel = Selector(method)
            let responds = obj.respondsToSelector(sel)
            
            if responds {
                dispatch_async(dispatch_get_main_queue(), {
                    (obj as AnyObject).performSelector(sel, withObject: val)
                })
            }
        }
        return nil
    }

    func chain(object: AnyObject?, _ vec: [String], full: Bool) -> AnyObject? {
        if let obj = object {
            let cnt = vec.count
            for (idx,method) in vec.enumerate() {
                if !full && idx == cnt-1 {
                    continue
                }
                let sel = Selector(self.var_or_method(method))
                let responds = obj.respondsToSelector(sel)
                if responds {
                    let inst = obj.performSelector(sel)
                    if "Unmanaged<AnyObject>" == typeof(inst) {
                        return chain(convert(inst), vec.slice_to_end(1), full: full)
                    } else {
                        return chain(inst as? AnyObject, vec.slice_to_end(1), full: full)
                    }
                } else {
                    return nil
                }
            }
            return obj
        } else {
            if let one = vec.first {
                if one.hasPrefix("0x") {
                    if let o = from_env(one) {
                        return chain(o, vec.slice_to_end(1), full: full)
                    }
                } else {
                    if let c: AnyClass = NSClassFromString(one) {
                        return chain(c, vec.slice_to_end(1), full: full)
                    }
                }
            }
            return nil
        }
    }
}



// MARK: ConsoleRouter - utils

extension ConsoleRouter {
    
    func from_env(address: String) -> AnyObject? {
        return env[address]
    }
    
    func memoryof(obj: AnyObject) -> String {
        return NSString(format: "%p", unsafeBitCast(obj, Int.self)) as String
    }
    
    func push_to_env(obj: AnyObject) -> [String: String] {
        let address = memoryof(obj)
        env[address] = obj
        return ["address": address]
    }
    
    func var_or_method(str: String) -> String {
        if str.hasSuffix("()") {
            let method = str.slice(0, to: str.characters.count - 2)
            return method
        } else {
            return str
        }
    }

    func json_parse(str: String?) -> [String] {
        if let s = str {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(s.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions())
                return json as! [String]
            } catch {
            }
            return [s]
        } else {
            return [String]()
        }
    }
}


// MARK: HttpRequest - query

extension HttpRequest {
    var query: Dictionary<String, String> {
        get {
            var dict = Dictionary<String, String>()
            for (k,v) in queryParams {
                dict[k] = v
            }
            return dict
        }
    }
}