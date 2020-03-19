import XCTest
@testable import Parser

extension Parser where Output: Equatable, Stream: Equatable {
    func assertRun(_ input: Stream, result: Output, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseOutput = run(input)
        XCTAssertNotNil(parseOutput, file: file, line: line)
        
        if let (actualOutput, actualRemainder) = parseOutput {
            XCTAssertEqual(result, actualOutput, file: file, line: line)
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
}

extension Parser where Stream: Equatable {
    func assertSucceed(_ input: Stream, remainder: Stream, file: StaticString = #file, line: UInt = #line) {
        let parseOutput = run(input)
        XCTAssertNotNil(parseOutput, file: file, line: line)
        
        if let (_, actualRemainder) = parseOutput {
            XCTAssertEqual(remainder, actualRemainder, file: file, line: line)
        }
    }
    
    func assertFail(_ input: Stream, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(run(input), file: file, line: line)
    }
}
