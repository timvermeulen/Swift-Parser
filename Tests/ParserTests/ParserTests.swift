import XCTest
@testable import Parser

final class ParserTests: XCTestCase {
    func testDigit() {
        Parser.digit.assertRun("123abc", result: 1, remainder: "23abc")
        Parser.digit.assertFail("abc123")
    }
    
    func testNumber() {
        Parser.number.assertRun("123abc", result: 123, remainder: "abc")
        Parser.number.assertFail("abc123")
    }

    func testCharacter() {
        Parser(.character, where: { $0 == "a" }).assertRun("abc123", result: "a", remainder: "bc123")
    }

    func testAny() {
        Parser.digit.any.assertRun("123abc", result: [1, 2, 3], remainder: "abc")
        Parser.digit.any.assertRun("abc123", result: [], remainder: "abc123")
    }

    func testMany() {
        Parser.digit.many.assertRun("123abc", result: [1, 2, 3], remainder: "abc")
        Parser.digit.many.assertFail("abc123")
    }

    func testAnySeparator() {
        let separator = Parser(.character, where: { $0 == " " })
        let parser = Parser.number.any(separator: separator)

        parser.assertRun("123 321 234 abc", result: [123, 321, 234], remainder: " abc")
        parser.assertRun("abc 123", result: [], remainder: "abc 123")
        parser.assertRun("123 321", result: [123, 321], remainder: "")
        parser.assertRun("12345", result: [12345], remainder: "")
        parser.assertRun("", result: [], remainder: "")
    }

    func testManySeparator() {
        let separator = Parser(.character, where: { $0 == " " })
        let parser = Parser.number.many(separator: separator)

        parser.assertRun("123 321 234 abc", result: [123, 321, 234], remainder: " abc")
        parser.assertRun("123 abc", result: [123], remainder: " abc")
        parser.assertFail("abc 123")
    }
}
