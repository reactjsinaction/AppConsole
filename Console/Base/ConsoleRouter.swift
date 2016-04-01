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
                            if let val = obj as? ValueType {
                                return self.result(val.value)
                            } else {
                                return self.result(obj)
                            }
                        } else {
                            return self.result(.Nil)
                        }
                    } else {
                        return self.result(.Failed)
                    }
                case "Setter":
                    if let rhs = query["rhs"] {
                        let (success, left) = self.chain(nil, self.json_parse(lhs), full: false)
                        let (_, value) = self.chain_getter(rhs)
                        if success {
                            if let obj = left {
                                self.chain_setter(obj, lhs: lhs, value: value)
                                if let v = value {
                                    if let val = value as? ValueType {
                                        return self.result(val.value)
                                    } else {
                                        return self.result(v)
                                    }
                                } else {
                                    return self.result(.Nil)
                                }
                            } else {
                                return self.result(.Nil)
                            }
                        } else {
                            return self.result(.Failed)
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
    func result(type: ResultType) -> HttpResponse {
        switch type {
        case .Failed:
            return .OK(.Json(["symbol": String(type)]))
        case .Nil:
            return .OK(.Json(["symbol": "nothing"]))
        }
    }
    
    func result(value: AnyObject) -> HttpResponse {
        switch value {
        case is Int:
            return .OK(.Json(["result": value]))
        case is String:
            return .OK(.Json(["result": value]))
        case is [String: AnyObject]:
            var d = [String: String]()
            for (k,v) in (value as! [String: AnyObject]) {
                d[k] = String(v)
            }
            return .OK(.Json(["result": d]))
        case is [AnyObject]:
            let a = (value as! [AnyObject]).map { x in String(x) }
            return .OK(.Json(["result": a]))
        default:
            return .OK(.Json(["result": String(value)]))
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
                    return type_handler.typepair_constructor(name, args as! [[AnyObject]])
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
                    let (success,ob) = type_handler.getter_handle(obj, self.var_or_method(pair))
                    if success {
                        if let o = ob {
                            return chain(o, vec.slice_to_end(1), full: full)
                        } else {
                            return (true, nil)
                        }
                    } else {
                        return (false, obj)
                    }
                } else {
                    Log.info("chain", val, vec, full)
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
    
    func var_or_method(pair: TypePair) -> String {
        if let str = pair.second as? String {
            if str.hasSuffix("()") {
                let method = str.slice(0, to: str.characters.count - 2)
                return method
            } else {
                return str
            }
        } else {
            return ""
        }
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