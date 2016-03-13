//
//  WTest.swift
//  ConsoleApp
//
//  Created by wookyoung on 3/13/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

public class WTestCaseProvider: NSObject {
}

public class WTestCase : WTestCaseProvider {
    func setUp() {
        
    }
    func tearDown() {
        
    }
    
    func measureBlock(block: ()->Void) {
        
    }
    
}



import UIKit

private enum _XCTAssertion {
    case Equal
    case EqualWithAccuracy
    case GreaterThan
    case GreaterThanOrEqual
    case LessThan
    case LessThanOrEqual
    case NotEqual
    case NotEqualWithAccuracy
    case Nil
    case NotNil
    case True
    case False
    case Fail
    case ThrowsError
    
    var name: String? {
        switch(self) {
        case .Equal: return "equal"
        case .EqualWithAccuracy: return "XCTAssertEqualWithAccuracy"
        case .GreaterThan: return "XCTAssertGreaterThan"
        case .GreaterThanOrEqual: return "XCTAssertGreaterThanOrEqual"
        case .LessThan: return "XCTAssertLessThan"
        case .LessThanOrEqual: return "XCTAssertLessThanOrEqual"
        case .NotEqual: return "XCTAssertNotEqual"
        case .NotEqualWithAccuracy: return "XCTAssertNotEqualWithAccuracy"
        case .Nil: return "XCTAssertNil"
        case .NotNil: return "XCTAssertNotNil"
        case .True: return "XCTAssertTrue"
        case .False: return "XCTAssertFalse"
        case .ThrowsError: return "XCTAssertThrowsError"
        case .Fail: return nil
        }
    }
}

private enum _XCTAssertionResult {
    case Success
    case ExpectedFailure(String?)
    case UnexpectedFailure(ErrorType)
    
    var expected: Bool {
        switch (self) {
        case .UnexpectedFailure(_):
            return false
        default:
            return true
        }
    }
    
    func failureDescription(assertion: _XCTAssertion) -> String {
        let explanation: String
        switch (self) {
        case .Success:
            explanation = "passed"
        case .ExpectedFailure(let details?):
            explanation = "\(ansi_red)Failed:\(ansi_reset) \(details)"
        case .ExpectedFailure(_):
            explanation = "Failed"
        case .UnexpectedFailure(let error):
            explanation = "threw error \"\(error)\""
        }
        
        //        if let _ = assertion.name {
        //            return "\(explanation)"
        //        } else {
        return explanation
        //        }
    }
}

internal func XCTPrint(items: Any..., separator: String = " ", terminator: String = "\n") {
    print(items, separator: separator, terminator: terminator)
    fflush(stdout)
}

struct XCTFailure {
    var message: String
    var failureDescription: String
    var expected: Bool
    var file: StaticString
    var function: String
    var line: UInt
    
    func emit(method: String) {
        XCTPrint("\(file):\(line): \(expected ? "" : "unexpected ")error: \(method) : \(failureDescription) - \(message)")
    }
}

internal typealias TimeInterval = Double
internal struct XCTRun {
    var duration: TimeInterval
    var method: String
    var passed: Bool
    var failures: [XCTFailure]
    var unexpectedFailures: [XCTFailure] {
        get { return failures.filter({ failure -> Bool in failure.expected == false }) }
    }
}


func print_dot() {
    print(".", terminator: "")
}

func print_ln() {
    print("")
}


internal var XCTFailureHandler: (XCTFailure -> Void)?
internal var XCTAllRuns = [XCTRun]()


class Assertion {
    private func _XCTEvaluateAssertion(assertion: _XCTAssertion, @autoclosure message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__, @noescape expression: () throws -> _XCTAssertionResult) {
        let result: _XCTAssertionResult
        do {
            result = try expression()
        } catch {
            result = .UnexpectedFailure(error)
        }
        
        switch result {
        case .Success:
            print_dot()
            UnitTest.passed += 1
            return
            
        default:
            print_ln()
            Log.info(result.failureDescription(assertion), file: file, function: function, line: Int(line))
            UnitTest.failed += 1
            if let handler = XCTFailureHandler {
                handler(XCTFailure(message: message(), failureDescription: result.failureDescription(assertion), expected: result.expected, file: file, function: function, line: line))
            }
        }
    }
    
    /// This function emits a test failure if the general Bool expression passed
    /// to it evaluates to false.
    ///
    /// - Requires: This and all other XCTAssert* functions must be called from
    ///   within a test method, as indicated by `XCTestCaseProvider.allTests`.
    ///   Assertion failures that occur outside of a test method will *not* be
    ///   reported as failures.
    ///
    /// - Parameter expression: A boolean test. If it evaluates to false, the
    ///   assertion fails and emits a test failure.
    /// - Parameter message: An optional message to use in the failure if the
    ///   assertion fails. If no message is supplied a default message is used.
    /// - Parameter file: The file name to use in the error message if the assertion
    ///   fails. Default is the file containing the call to this function. It is
    ///   rare to provide this parameter when calling this function.
    /// - Parameter line: The line number to use in the error message if the
    ///   assertion fails. Default is the line number of the call to this function
    ///   in the calling file. It is rare to provide this parameter when calling
    ///   this function.
    ///
    /// - Note: It is rare to provide the `file` and `line` parameters when calling
    ///   this function, although you may consider doing so when creating your own
    ///   assertion functions. For example, consider the following custom assertion:
    ///
    ///   ```
    ///   // AssertEmpty.swift
    ///
    ///   func AssertEmpty<T>(elements: [T]) {
    ///       XCTAssertEqual(elements.count, 0, "Array is not empty")
    ///   }
    ///   ```
    ///
    ///  Calling this assertion will cause XCTest to report the failure occured
    ///  in the file where `AssertEmpty()` is defined, and on the line where
    ///  `XCTAssertEqual` is called from within that function:
    ///
    ///  ```
    ///  // MyFile.swift
    ///
    ///  AssertEmpty([1, 2, 3]) // Emits "AssertEmpty.swift:3: error: ..."
    ///  ```
    ///
    ///  To have XCTest properly report the file and line where the assertion
    ///  failed, you may specify the file and line yourself:
    ///
    ///  ```
    ///  // AssertEmpty.swift
    ///
    ///  func AssertEmpty<T>(elements: [T], file: StaticString = __FILE__, line: UInt = __LINE__) {
    ///      XCTAssertEqual(elements.count, 0, "Array is not empty", file: file, function: function, line: line)
    ///  }
    ///  ```
    ///
    ///  Now calling failures in `AssertEmpty` will be reported in the file and on
    ///  the line that the assert function is *called*, not where it is defined.
    func XCTAssert(@autoclosure expression: () throws -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        XCTAssertTrue(expression, message, file: file, function: function, line: line)
    }
    
    func equal<T: Equatable>(@autoclosure expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(@autoclosure expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(@autoclosure expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(@autoclosure expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T, U: Equatable>(@autoclosure expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func XCTAssertEqualWithAccuracy<T: FloatingPointType>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.EqualWithAccuracy, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if abs(value1.distanceTo(value2)) <= abs(accuracy.distanceTo(T(0))) {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) != \(value2) +/- (\"\(accuracy)\")")
            }
        }
    }
    
    func XCTAssertFalse(@autoclosure expression: () throws -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.False, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if !value.boolValue {
                return .Success
            } else {
                return .ExpectedFailure(nil)
            }
        }
    }
    
    func XCTAssertGreaterThan<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.GreaterThan, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 > value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is not greater than \(value2)")
            }
        }
    }
    
    func XCTAssertGreaterThanOrEqual<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.GreaterThanOrEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 >= value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is less than \(value2)")
            }
        }
    }
    
    func XCTAssertLessThan<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.LessThan, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 < value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is not less than \(value2)")
            }
        }
    }
    
    func XCTAssertLessThanOrEqual<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.LessThanOrEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 <= value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is greater than \(value2)")
            }
        }
    }
    
    func XCTAssertNil(@autoclosure expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Nil, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value == nil {
                return .Success
            } else {
                return .ExpectedFailure("\"\(value!)\"")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T, U: Equatable>(@autoclosure expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqualWithAccuracy<T: FloatingPointType>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, _ accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.NotEqualWithAccuracy, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if abs(value1.distanceTo(value2)) > abs(accuracy.distanceTo(T(0))) {
                return .Success
            } else {
                return .ExpectedFailure("\(value1) is equal to \(value2) +/- (\"\(accuracy)\")")
            }
        }
    }
    
    func XCTAssertNotNil(@autoclosure expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Nil, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value != nil {
                return .Success
            } else {
                return .ExpectedFailure(nil)
            }
        }
    }
    
    func True(@autoclosure expression: () throws -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.True, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value.boolValue {
                return .Success
            } else {
                return .ExpectedFailure(String(value))
            }
        }
    }
    
    func XCTAssertTrue(@autoclosure expression: () throws -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.True, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value.boolValue {
                return .Success
            } else {
                return .ExpectedFailure(nil)
            }
        }
    }
    
    func XCTFail(message: String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Fail, message: message, file: file, function: function, line: line) {
            return .ExpectedFailure(nil)
        }
    }
    
    func XCTAssertThrowsError<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__, _ errorHandler: (error: ErrorType) -> Void = { _ in }) {
        _XCTEvaluateAssertion(.ThrowsError, message: message, file: file, function: function, line: line) {
            var caughtErrorOptional: ErrorType?
            do {
                _ = try expression()
            } catch {
                caughtErrorOptional = error
            }
            
            if let caughtError = caughtErrorOptional {
                errorHandler(error: caughtError)
                return .Success
            } else {
                return .ExpectedFailure("did not throw error")
            }
        }
    }
}

extension Assertion {
    // (Int, Int)
    func equal(expression1: (Int,Int), _ expression2: (CGFloat, CGFloat), @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let a = (CGFloat(expression1.0), CGFloat(expression1.1))
            let b = expression2
            if a.0 == b.0 && a.1 == b.1 {
                return .Success
            } else {
                return .ExpectedFailure("\(a) != \(b)")
            }
        }
    }
    
    func equal(expression1: (CGFloat,CGFloat), _ expression2: (CGFloat, CGFloat), @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, function: String = __FUNCTION__, line: UInt = __LINE__) {
        _XCTEvaluateAssertion(.Equal, message: message, file: file, function: function, line: line) {
            let a = expression1
            let b = expression2
            if a.0 == b.0 && a.1 == b.1 {
                return .Success
            } else {
                return .ExpectedFailure("\(a) != \(b)")
            }
        }
    }
}


let Assert = Assertion()
