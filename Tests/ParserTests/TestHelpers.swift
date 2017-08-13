import XCTest
@testable import Parser

extension Parser where Result: Equatable, Stream: Equatable, State: Equatable {
    func assertRun(_ input: Stream, state: State, result: Result, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input, state: state)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder, actualState) = parseResult {
            XCTAssertEqual(result, actualResult, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
            XCTAssertEqual(state, actualState, file: file, line: line)
        }
    }
}

extension Parser where Result: Equatable, Stream: Equatable, State == Void {
    func assertRun(_ input: Stream, result: Result, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder) = parseResult {
            XCTAssertEqual(result, actualResult, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}

extension Parser where Stream: Equatable, State: Equatable {
    func assertSucceed(_ input: Stream, state: State, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input, state: state)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (_, actualRemainder, actualState) = parseResult {
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
            XCTAssertEqual(state, actualState, file: file, line: line)
        }
    }
}

extension Parser {
    func assertFail(_ input: Stream, state: State, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(run(input, state: state), file: file, line: line)
    }
}

extension Parser where Stream: Equatable, State == Void {
    func assertSucceed(_ input: Stream, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (_, actualRemainder) = parseResult {
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}

extension Parser where State == Void {
    func assertFail(_ input: Stream, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(run(input), file: file, line: line)
    }
}

// TODO: remove when we have conditional conformance

protocol _Optional {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: _Optional {
    var optional: Optional { return self }
}

extension Parser where Result: _Optional, Result.Wrapped: Equatable, Stream: Equatable, State: Equatable {
    func assertRun(_ input: Stream, state: State, result: Result.Wrapped?, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input, state: state)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder, actualState) = parseResult {
            XCTAssertEqual(result, actualResult.optional, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
            XCTAssertEqual(state, actualState, file: file, line: line)
        }
    }
}

extension Parser where Result: _Optional, Result.Wrapped: Equatable, Stream: Equatable, State == Void {
    func assertRun(_ input: Stream, result: Result.Wrapped?, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder) = parseResult {
            XCTAssertEqual(result, actualResult.optional, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}

protocol _Array {
    associatedtype Element
    var array: [Element] { get }
}

extension Array: _Array {
    var array: Array { return self }
}

extension Parser where Result: _Array, Result.Element: Equatable, Stream: Equatable, State: Equatable {
    func assertRun(_ input: Stream, state: State, result: [Result.Element], remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input, state: state)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder, actualState) = parseResult {
            XCTAssertEqual(result, actualResult.array, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
            XCTAssertEqual(state, actualState, file: file, line: line)
        }
    }
}

extension Parser where Result: _Array, Result.Element: Equatable, Stream: Equatable, State == Void {
    func assertRun(_ input: Stream, result: [Result.Element], remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseResult = run(input)
        XCTAssertNotNil(parseResult, file: file, line: line)
        
        if let (actualResult, actualRemainder) = parseResult {
            XCTAssertEqual(result, actualResult.array, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}
