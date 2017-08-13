import XCTest
@testable import Parser

extension Parser where Result: Equatable {
    func assertRun(_ string: String, result: Result, remainder: String, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(string)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder) = parseResult {
            XCTAssertEqual(result, actualResult, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}

extension Parser {
    func assertFail(_ string: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(run(string), file: file, line: line)
    }
}

// TODO: remove when we have conditional conformance

protocol _Array {
    associatedtype Element
    var array: [Element] { get }
}

extension Array: _Array {
    var array: Array { return self }
}

extension Parser where Result: _Array, Result.Element: Equatable {
    func assertRun(_ string: String, result: [Result.Element], remainder: String, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(string)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder) = parseResult {
            XCTAssertEqual(result, actualResult.array, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}
