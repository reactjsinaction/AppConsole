//
//  ConsoleRouter.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit
import Swifter

typealias ChainResult = (Bool, AnyObject?)

class ConsoleRouter {
    
    let type_handler = TypeHandler()
    var env = [String: AnyObject]()

    // MARK: ConsoleRouter - route
    func route(server: HttpServer, initial: AnyObject) {

        server["/"] = { req in
            let info = [String]()
            return self.result(info)
        }
        
        server["/initial"] = { req in
            let info = self.push_to_env(initial)
            return self.result(info)
        }
        
        server["/image"] = { req in
            for (name, value) in req.queryParams {
                if "path" == name {
                    let path = value.componentsSeparatedByString(".")
                    var lhs = [TypePair]()
                    for item in path {
                        if item.hasPrefix("0x") {
                            lhs.append(TypePair(first: "address", second: item))
                        } else {
                            lhs.append(TypePair(first: "symbol", second: item))
                        }
                    }

                    let (_,object) = self.chain(nil, lhs, full: true)
                    if let view = object as? UIView {
                        return self.result_image(view.to_data())
                    } else if let screen = object as? UIScreen {
                        return self.result_image(screen.to_data())
                    }
                }
            }

            return self.result_failed()
        }

        server["/query"] = { req in
            var query = [String: String]()
            do {
                let data = NSData(bytes: req.body, length: req.body.count)
                query = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : String]
            } catch {
            }
            
            if let type = query["type"], lhs = query["lhs"] {
                switch type {
                case "Getter":
                    let (success,object) = self.chain_getter(lhs)
                    if success {
                        if let obj = object {
                            return self.result(obj)
                        } else {
                            return self.result_nil()
                        }
                    } else {
                        return self.result_failed()
                    }
                case "Setter":
                    if let rhs = query["rhs"] {
                        let (success, left) = self.chain(nil, self.json_parse(lhs), full: false)
                        let (_, value) = self.chain_getter(rhs)
                        if success {
                            if let obj = left {
                                self.chain_setter(obj, lhs: lhs, value: value)
                                if let val = value {
                                    return self.result(val)
                                } else {
                                    return self.result_nil()
                                }
                            } else {
                                return self.result_nil()
                            }
                        } else {
                            return self.result_failed()
                        }
                    }
                default:
                    break
                }
            }
            return self.result_failed()
        }
    }
}



// MARK: ConsoleRouter - chains

extension ConsoleRouter {
    
    func chain_getter(lhs: String) -> (Bool,AnyObject?) {
        let vec: [TypePair] = json_parse(lhs)
        return chain(nil, vec, full: true)
    }

    func chain_setter(obj: AnyObject, lhs: String, value: AnyObject?) -> AnyObject? {
        let vec: [TypePair] = json_parse(lhs)
        if let pair = vec.last {
            self.type_handler.setter_handle(obj, pair.second as! String, value: value)
        }
        return nil
    }
    
    func typepair_chain(pair: TypePair) -> ChainResult {
        switch pair.first {
        case "string":
            return (false, pair.second)
        case "int":
            return (false, ValueType(type: "q", value: pair.second))
        case "float":
            return (false, ValueType(type: "f", value: pair.second))
        case "bool":
            return (false, ValueType(type: "B", value: pair.second))
        case "address":
            return (false, from_env(pair.second as! String))
        case "symbol":
            if let str = pair.second as? String {
                switch str {
                case "nil":
                    return (false, nil)
                default:
                    return (true, nil)
                }
            } else {
                return (true, nil)
            }
        case "call":
            return typepair_callargs(pair.second)
        default:
            return (true, nil)
        }
    }

    func typepair_callargs(info: AnyObject) -> ChainResult {
        if let nameargs = info as? [AnyObject] {
            if let name = nameargs.first as? String,
                let args = nameargs.last {
                switch args {
                case is [Float]:
                    return type_handler.typepair_function(name, args as! [Float])
                case is [AnyObject]:
                    if let a = args as? [[AnyObject]] {
                        return type_handler.typepair_constructor(name, a)
                    }
                default:
                    break
                }
            }
        }
        return (true, nil)
    }

    func chain_dictionary(dict: [String: AnyObject], _ key: String, _ nth: Int, _ vec: [TypePair], full: Bool) -> ChainResult {
        if let obj = dict[key] {
            return chain(obj, vec.slice_to_end(nth), full: full)
        } else {
            switch key {
            case "keys":
                return chain([String](dict.keys), vec.slice_to_end(nth), full: full)
            case "values":
                return chain([AnyObject](dict.values), vec.slice_to_end(nth), full: full)
            default:
                break
            }
        }
        return (false, dict)
    }

    func chain_array(arr: [AnyObject], _ method: String, _ nth: Int, _ vec: [TypePair], full: Bool) -> ChainResult {
        switch method {
        case "sort":
            if let a = arr as? [String] {
                return chain(a.sort(<), vec.slice_to_end(nth), full: full)
            }
        case "first":
            return chain(arr.first, vec.slice_to_end(nth), full: full)
        case "last":
            return chain(arr.last, vec.slice_to_end(nth), full: full)
        default:
            break
        }
        return (false, arr)
    }

    func chain(object: AnyObject?, _ vec: [TypePair], full: Bool) -> ChainResult {
        if let obj = object {
            let cnt = vec.count
            for (idx,pair) in vec.enumerate() {
                if !full && idx == cnt-1 {
                    continue
                }
                let (cont, val) = typepair_chain(pair)
                if cont {
                    if let method = self.var_or_method(pair) {
                        switch method {
                        case is String:
                            let meth = method as! String
                            let (success,ob) = type_handler.getter_handle(obj, meth)
                            if success {
                                if let o = ob {
                                    return chain(o, vec.slice_to_end(1), full: full)
                                } else {
                                    return (true, nil)
                                }
                            } else if let dict = obj as? [String: AnyObject] {
                                return chain_dictionary(dict, meth, 1, vec, full: full)
                            } else if let arr = obj as? [AnyObject] {
                                return chain_array(arr, meth, 1, vec, full: full)
                            } else {
                                return (false, nil)
                            }
                        case is Int:
                            if let arr = obj as? NSArray,
                                let idx = method as? Int {
                                if arr.count > idx {
                                    return chain(arr[idx], vec.slice_to_end(1), full: full)
                                }
                            }
                        default:
                            break
                        }
                    }
                    return (false, obj)
                } else {
                    return chain(val, vec.slice_to_end(1), full: full)
                }
            }
            return (true, obj)
        } else {
            if let pair = vec.first {
                let (cont, val) = typepair_chain(pair)
                if cont {
                    if let one = pair.second as? String {
                        if let c: AnyClass = NSClassFromString(one) {
                            return chain(c, vec.slice_to_end(1), full: full)
                        } else {
                            return type_handler.typepair_constant(one)
                        }
                    }
                    return (true, nil)
                } else {
                    return chain(val, vec.slice_to_end(1), full: full)
                }
            } else {
                return (false, nil)
            }
        }
    }
}

struct TypePair: CustomStringConvertible {
    var first: String
    var second: AnyObject
    var description: String {
        get {
            return "TypePair(\(first), \(second))"
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

    func var_or_method(pair: TypePair) -> AnyObject? {
        switch pair.second {
        case is String:
            if let str = pair.second as? String {
                if str.hasSuffix("()") {
                    let method = str.slice(0, to: str.characters.count - 2)
                    return method
                } else if let num = Int(str) {
                    return num
                } else {
                    return str
                }
            }
        case is Int:
            if let num = pair.second as? Int {
                return num
            }
        default:
            break
        }
        return nil
    }

    func typepairs(array: [[String: AnyObject]]) -> [TypePair] {
        var list = [TypePair]()
        for dict in array {
            if let k = dict["first"], let v = dict["second"] {
                list.append(TypePair(first: k as! String, second: v))
            }
        }
        return list
    }
    
    func json_parse(str: String?) -> [TypePair] {
        if let s = str {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(s.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions())
                if let j = json as? [[String: AnyObject]] {
                    return typepairs(j)
                }
            } catch {
            }
            return [TypePair(first: "raw", second: s)]
        } else {
            return [TypePair]()
        }
    }
}



// MARK: ConsoleRouter - result
extension ConsoleRouter {
    func result(value: AnyObject) -> HttpResponse {
        switch value {
        case is ValueType:
            if let val = value as? ValueType {
                switch val.type {
                case "B":
                    return result_bool(val.value)
                case "{CGRect={CGPoint=dd}{CGSize=dd}}", "{CGRect={CGPoint=ff}{CGSize=ff}}":
                    return result_string(val.value)
                default:
                    if let num = val.value as? NSNumber {
                        if num.stringValue.containsString("e+") {
                            return result_any(String(num))
                        } else {
                            return result_any(num.floatValue)
                        }
                    } else {
                        return result_any(val.value)
                    }
                }
            }
        case is Int:
            return result_any(value)
        case is String:
            return result_string(value)
        case is UIView, is UIScreen:
            return .OK(.Json(["type": "view", "value": String(value)]))
        case is [String: AnyObject]:
            var d = [String: String]()
            for (k,v) in (value as! [String: AnyObject]) {
                d[k] = String(v)
            }
            return result_any(d)
        case is [AnyObject]:
            let a = (value as! [AnyObject]).map { x in String(x) }
            return result_any(a)
        default:
            break
        }
        return result_any(String(value))
    }

    func result_any(value: AnyObject) -> HttpResponse{
        return .OK(.Json(["type": "any", "value": value]))
    }

    func result_string(value: AnyObject) -> HttpResponse{
        return .OK(.Json(["type": "string", "value": value]))
    }

    func result_bool(value: AnyObject) -> HttpResponse{
        return .OK(.Json(["type": "bool", "value": value]))
    }

    func result_image(imagedata: NSData?) -> HttpResponse {
        let headers = ["Content-Type": "image/png"]
        if let data = imagedata {
            let writer: (HttpResponseBodyWriter -> Void) = { writer in
                writer.write(Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length)))
            }
            return .RAW(200, "OK", headers, writer)
        }
        return result_failed()
    }

    func result_nil() -> HttpResponse {
        return .OK(.Json(["type": "symbol", "value": "nothing"]))
    }

    func result_failed() -> HttpResponse {
        return .OK(.Json(["type": "symbol", "value": "Failed"]))
    }
}