import XCTest
@testable import Parser

let errorMessage = "`continueAfterFailure` should be set to `false` inside `setUp()`, and set to `true` inside `tearDown()`"

public func XCTFatal(_ message: String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    XCTFail(message, file: file, line: line)
    fatalError(errorMessage)
}

public func XCTUnwrap<T>(_ expression: @autoclosure () throws -> T?, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> T {
    XCTAssertNotNil(try expression(), message(), file: file, line: line)
    
    do {
        guard let result = try expression() else { fatalError(errorMessage) }
        return result
    } catch {
        fatalError(errorMessage)
    }
}

open class SafeXCTestCase: XCTestCase {
    override open func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }
    
    override open func tearDown() {
        self.continueAfterFailure = true
        super.tearDown()
    }
}

class ParserTests: SafeXCTestCase {
    func testDigit() {
        let (result, remainder) = XCTUnwrap(Parsers.digit.run("123abc"))
        
        XCTAssertEqual(result, 1)
        XCTAssertEqual(remainder, "23abc")
        
        XCTAssertNil(Parsers.digit.run("abc123"))
    }
    
    func testNumber() {
        let (result, remainder) = XCTUnwrap(Parsers.number.run("123abc"))
        
        XCTAssertEqual(result, 123)
        XCTAssertEqual(remainder, "abc")
        
        XCTAssertNil(Parsers.number.run("abc123"))
    }
    
    func testCharacter() {
        let parser = Parser(Parsers.character, where: { $0 == "a" })
        XCTAssertNil(parser.run("123abc"))
        
        let (result, remainder) = XCTUnwrap(parser.run("abc123"))
        XCTAssertEqual(result, "a")
        XCTAssertEqual(remainder, "bc123")
    }
    
    func testAny() {
        do {
            let (result, remainder) = XCTUnwrap(Parsers.digit.any().run("123abc"))
            
            XCTAssertEqual(result, [1, 2, 3])
            XCTAssertEqual(remainder, "abc")
        }
        
        do {
            let (result, remainder) = XCTUnwrap(Parsers.digit.any().run("abc123"))
            
            XCTAssertEqual(result, [])
            XCTAssertEqual(remainder, "abc123")
        }
    }
    
    func testMany() {
        let (result, remainder) = XCTUnwrap(Parsers.digit.many().run("123abc"))
        
        XCTAssertEqual(result, [1, 2, 3])
        XCTAssertEqual(remainder, "abc")
        
        XCTAssertNil(Parsers.digit.many().run("abc123"))
    }
    
    func testAnySeparator() {
        let separator = Parser(Parsers.character, where: { $0 == " " }).many()
        let parser = Parsers.number.any(separator: separator)
        
        do {
            let (result, remainder) = XCTUnwrap(parser.run("123 321 234 abc"))
            
            XCTAssertEqual(result, [123, 321, 234])
            XCTAssertEqual(remainder, " abc")
        }
        
        do {
            let (result, remainder) = XCTUnwrap(parser.run("abc 123"))
            
            XCTAssertEqual(result, [])
            XCTAssertEqual(remainder, "abc 123")
        }
    }
    
    func testManySeparator() {
        let separator = Parser(Parsers.character, where: { $0 == " " }).many()
        let parser = Parsers.number.many(separator: separator)
        
        let (result, remainder) = XCTUnwrap(parser.run("123 321 234 abc"))
        
        XCTAssertEqual(result, [123, 321, 234])
        XCTAssertEqual(remainder, " abc")
        
        XCTAssertNil(parser.run("abc 123"))
    }
}
