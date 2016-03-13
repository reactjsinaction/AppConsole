//
//  Extensions.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation


// MARK: String

extension String {
    func uppercase_first() -> String {
        switch self.characters.count {
        case 0:
            return ""
        case 1:
            return uppercaseString
        default:
            return String(self[characters.startIndex.advancedBy(0)]).uppercaseString + self.slice_to_end(1)
        }
    }
    
    public func slice_to_end(index: Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func slice(from: Int, to: Int) -> String {
        return self[self.startIndex.advancedBy(from)..<self.startIndex.advancedBy(to)]
    }
}


// MARK: Array

extension Array {
    func slice_to_end(nth: Int) -> Array {
        let s: ArraySlice = self[nth..<self.endIndex]
        return Array(s)
    }
}


// MARK: typeof
func typeof(a: Any) -> String {
    let mirror = Mirror(reflecting: a)
    let type = String(mirror.subjectType)
    return type
}

// MARK: convert
func convert(a: Any) -> AnyObject? {
    if let obj = a as? Unmanaged<AnyObject> {
        return obj.takeUnretainedValue()
    } else {
        return nil
    }
}

// MARK: return_types
func return_types(obj: AnyObject, _ name: String) -> String {
    let m: Method = class_getInstanceMethod(object_getClass(obj), Selector(name))
    let returnType = method_copyReturnType(m)
    defer {
        returnType.destroy()
    }
    if let str = String.fromCString(returnType) {
        return str
    } else {
        return ""
    }
}



// MARK: UnitTest

// using some part of bnickel/RestorationDefender.swift
// https://gist.github.com/bnickel/410a1bdc02f12fbd9b5e

func enumerateCArray<T>(array: UnsafePointer<T>, count: UInt32, f: (UInt32, T) -> ()) {
    var ptr = array
    for i in 0..<count {
        f(i, ptr.memory)
        ptr = ptr.successor()
    }
}

func methodName(m: Method) -> String? {
    let sel = method_getName(m)
    let nameCString = sel_getName(sel)
    return String.fromCString(nameCString)
}

public func objc_TestClassList() -> [AnyClass] {
    let expectedClassCount = objc_getClassList(nil, 0)
    let allClasses = UnsafeMutablePointer<AnyClass?>.alloc(Int(expectedClassCount))
    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)
    let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
    
    var classes = [AnyClass]()
    for i in 0 ..< actualClassCount {
        if let currentClass: AnyClass = allClasses[Int(i)] {
            if String(currentClass).hasPrefix("Test") {
                classes.append(currentClass)
            }
        }
    }
    allClasses.dealloc(Int(expectedClassCount))
    return classes
}

public func testMethodsForClass(cls: AnyClass) -> [String] {
    var methodCount: UInt32 = 0
    let methodList = class_copyMethodList(cls, &methodCount)
    var list = [String]()
    if methodList != nil && methodCount > 0 {
        enumerateCArray(methodList, count: methodCount) { i, m in
            if let name = methodName(m) {
                if name.hasPrefix("test") {
                    list.append(name)
                }
            }
        }
        free(methodList)
    }
    return list
}

struct TestResult {
    var tests: Int
    var passed: Int
    var failed: Int
    var errors: Int
}

let ansi_escape = "\u{001b}["
let ansi_brown  = ansi_escape + "fg52,91,151;"
let ansi_red    = ansi_escape + "fg215,50,50;"
let ansi_green  = ansi_escape + "fg0,155,0;"
let ansi_reset  = ansi_escape + ";"

class UnitTest {
    static var tests: Int = 0
    static var passed: Int = 0
    static var failed: Int = 0
    static var errors: Int = 0
    
    class func runClasses(classes: [AnyClass]) {
        for c in classes {
            switch c {
            case let classInst as NSObject.Type:
                let instance = classInst.init()
                for name in testMethodsForClass(c) {
                    instance.performSelector(NSSelectorFromString(name))
                    tests += 1
                }
            default:
                break
            }
        }
    }
    
    class func run(only only: String) -> TestResult {
        return run(only: [only])
    }
    
    class func run(only only: [String] = [String]()) -> TestResult {
        let started_at = NSDate()
        print("Started")
        if only.count > 0 {
            var list = [AnyClass]()
            for name in only {
                let bundleName = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
                if let c: AnyClass = NSClassFromString("\(bundleName).\(name)") {
                    list.append(c)
                }
            }
            runClasses(list)
        } else {
            runClasses(objc_TestClassList())
        }
        
        let elapsed: NSTimeInterval = -started_at.timeIntervalSinceNow
        print(String(format: "\nFinished in %.3g seconds.", elapsed))
        if failed > 0 {
            print(ansi_red)
        } else if passed > 0 {
            print(ansi_green)
        }
        print(String(format: "%d tests, %d assertions, %d failures, %d errors",
            tests, passed, failed, errors))
        print(ansi_reset)
        return TestResult(tests: tests, passed: passed, failed: failed, errors: errors)
    }
}




// MARK: Logger

class Logger {
    func info(args: Any..., file: StaticString = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__ ) {
        let filename = (String(file) as NSString).lastPathComponent
        
        var str = ""
        str += "\(filename) #\(line) "
        str += "\(function)() "
        let length = args.count
        for (index, x) in args.enumerate() {
            str += String(x)
            if length==index+1 {
                
            } else {
                str += " "
            }
        }
        str += "\n"
        print(str)
    }
}

let Log = Logger()