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
        Parser.character.assertRun("abc123", result: "a", remainder: "bc123")
        Parser.character.assertRun("123abc", result: "1", remainder: "23abc")
    }

    func testSpecificCharacter() {
        Parser.character("a").assertSucceed("abc123", remainder: "bc123")
        Parser.character("b").assertFail("abc123")
    }
    
    func testAnyCharacter() {
        let parser = Parser.anyCharacter(from: "abc")
    
        parser.assertRun("beg", result: "b", remainder: "eg")
        parser.assertFail("ged")
    }
    
    func testSpecificString() {
        Parser.string("abc1").assertSucceed("abc123", remainder: "23")
    }
    
    func testOptional() {
        Parser.number.optional.assertRun("123abc", result: 123, remainder: "abc")
        Parser.number.optional.assertRun("abc123", result: nil, remainder: "abc123")
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
        let separator = Parser.character(" ")
        let parser = Parser.number.any(separator: separator)

        parser.assertRun("123 321 234 abc", result: [123, 321, 234], remainder: " abc")
        parser.assertRun("abc 123", result: [], remainder: "abc 123")
        parser.assertRun("123 321", result: [123, 321], remainder: "")
        parser.assertRun("12345", result: [12345], remainder: "")
        parser.assertRun("", result: [], remainder: "")
    }

    func testManySeparator() {
        let separator = Parser.character(" ")
        let parser = Parser.number.many(separator: separator)

        parser.assertRun("123 321 234 abc", result: [123, 321, 234], remainder: " abc")
        parser.assertRun("123 abc", result: [123], remainder: " abc")
        parser.assertFail("abc 123")
    }
    
    func testOr() {
        let parser = Parser.string("a") ?? Parser.string("BC")
        
        parser.assertRun("abc", result: "a", remainder: "bc")
        parser.assertRun("BCD", result: "BC", remainder: "D")
    }
    
    func testOperators() {
        let parser = curry(Foo.init) <^> .string("test: ") *> Parser.number <* .string(", ") <*> Parser.word
        parser.assertRun("test: 123, hey875", result: Foo(number: 123, word: "hey"), remainder: "875")
    }
}

struct Foo: Equatable {
    let number: Int
    let word: String
    
    static func == (left: Foo, right: Foo) -> Bool {
        return left.number == right.number && left.word == right.word
    }
}
