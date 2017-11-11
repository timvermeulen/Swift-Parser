public typealias StringParser<Result> = Parser<Result, String>

extension Parser where Stream == String, Result == Character {
    public static let character = item
    
    public static func character(_ character: Character) -> Parser {
        return Parser.item(character)
    }
    
    public static let lowercaseLetter = any(from: "a" ... "z")
    public static let uppercaseLetter = any(from: "A" ... "Z")
    public static let letter = lowercaseLetter <|> uppercaseLetter
    public static let alphaNumeric = letter <|> any(from: "0" ... "9")
    public static let whiteSpace = any(from: [" ", "\n", "\t"])
    
    public func any<Separator>(separator: StringParser<Separator>) -> StringParser<String> {
        return any(String.self, separator: separator)
    }
    
    public var any: StringParser<String> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator, Stream>) -> StringParser<String> {
        return any(separator: separator).nonEmpty
    }
    
    public var many: StringParser<String> {
        return many(separator: .empty)
    }
}

extension Parser where Stream == String, Result == String {
    public static let word = Parser<Character, String>.letter.many.map { String($0) }
    
    public static func string(_ string: String) -> Parser {
        return Parser { input in
            let result = string.reduce(Optional.some(input[...])) { remainder, character in
                remainder.flatMap { Parser<Character, String>.character(character).parse($0)?.remainder }
            }
            
            return result.map { (string, $0) }
        }
    }
}

extension Parser where Stream == String, Result == Int {
    public static let digit = Parser<Character, String>.character.flatMap { Int($0) }
    public static let number = digit.many.map { $0.reduce(0, { 10 * $0 + $1 }) }
}

extension Parser where Result == Void {
    public static var empty: Parser {
        return Parser { ((), $0) }
    }
}
