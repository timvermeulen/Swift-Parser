public typealias StringParser<Output> = Parser<Output, String>

extension Parser where Stream == String, Output == Character {
    public static let character = element
    
    public static func character(_ character: Character) -> Self {
        Parser.element(character)
    }
    
    public static let lowercaseLetter = any(from: "a"..."z")
    public static let uppercaseLetter = any(from: "A"..."Z")
    public static let letter = lowercaseLetter <|> uppercaseLetter
    public static let alphaNumeric = letter <|> any(from: "0"..."9")
    public static let whiteSpace = any(from: [" ", "\n", "\t"])
    
    public func any<Separator>(separator: StringParser<Separator>) -> StringParser<String> {
        any(String.self, separator: separator)
    }
    
    public var any: StringParser<String> {
        any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator, Stream>) -> StringParser<String> {
        any(separator: separator).nonEmpty
    }
    
    public var many: StringParser<String> {
        many(separator: .empty)
    }
}

extension Parser where Stream == String, Output == String {
    public static let word = Parser<Character, String>.letter.many.map { String($0) }
    
    public static func string(_ string: String) -> Self {
        sequence(string)
    }
}

extension Parser where Stream == String, Output == Int {
    public static let digit = Parser<Character, String>.character.compactMap { Int($0) }
    
    public static var number: Self {
        let sign = StringParser<Character>.character("-").optional.map { $0 == nil }
        let tuple = makeTuple <^> sign <*> digit.many.map { $0.reduce(0, { 10 * $0 + $1 }) }
        return tuple.map { $0 ? $1 : -$1 }
    }
}

extension Parser where Output == Void {
    public static var empty: Self {
        .init { ((), $0) }
    }
}

extension Parser where Output: RawRepresentable, Output.RawValue == String, Stream == String {
    static func value(_: Output.Type) -> Self {
        .init { input -> (Output, Substring)? in
            var remainder = input
            var rawValue = ""
            
            while let (head, tail) = remainder.split() {
                remainder = tail
                rawValue.append(head)
                
                if let result = Output(rawValue: rawValue) {
                    return (result, remainder)
                }
            }
            
            return nil
        }
    }
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Stream == String, Output == String {
    public typealias ExtendedGraphemeClusterLiteralType = String
}

extension Parser: ExpressibleByUnicodeScalarLiteral where Stream == String, Output == String {
    public typealias UnicodeScalarLiteralType = String
}

extension Parser: ExpressibleByStringLiteral where Stream == String, Output == String {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = Self.sequence(value)
    }
}
