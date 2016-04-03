//
//  ConsoleRouter.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import UIKit
import Swifter


class ConsoleRouter {
    
    let type_handler = TypeHandler()
    var env = [String: AnyObject]()
    
    enum ResultType {
        case Failed
        case Nil
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
                            return self.result_symbol(.Nil)
                        }
                    } else {
                        return self.result_symbol(.Failed)
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
                                    return self.result_symbol(.Nil)
                                }
                            } else {
                                return self.result_symbol(.Nil)
                            }
                        } else {
                            return self.result_symbol(.Failed)
                        }
                    }
                default:
                    break
                }
            }
            return self.result_symbol(.Failed)
        }
    }

    // MARK: ConsoleRouter - result
    func result(value: AnyObject) -> HttpResponse {
        switch value {
        case is ValueType:
            if let val = value as? ValueType {
                switch val.type {
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

    func result_symbol(type: ResultType) -> HttpResponse {
        switch type {
        case .Failed:
            return .OK(.Json(["type": "symbol", "value": "Failed"]))
        case .Nil:
            return .OK(.Json(["type": "symbol", "value": "nothing"]))
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
            type_handler.setter_handle(obj, pair.second as! String, value: value)
        }
        return nil
    }
    
    func typepair_chain(pair: TypePair) -> (Bool, AnyObject?) {
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

    func typepair_callargs(info: AnyObject) -> (Bool, AnyObject?) {
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

    func chain(object: AnyObject?, _ vec: [TypePair], full: Bool) -> (Bool, AnyObject?) {
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
                            let (success,ob) = type_handler.getter_handle(obj, method as! String)
                            if success {
                                if let o = ob {
                                    return chain(o, vec.slice_to_end(1), full: full)
                                } else {
                                    return (true, nil)
                                }
                            } else {
                                return (false, obj)
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



struct TypePair {
    var first: String
    var second: AnyObject
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