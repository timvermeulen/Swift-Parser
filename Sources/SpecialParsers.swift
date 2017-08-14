public typealias StringParser<Result> = Parser<Result, String>

extension Parser where Stream == String, Result == Character {
    public static let character = item
    
    public static func character(_ character: Character) -> Parser {
        return Parser.character.filter { $0 == character }
    }
    
    public static func anyCharacter<S: Sequence>(from sequence: S) -> Parser where S.Element == Character {
        return sequence.map(character).reduce(zero, { $0 ?? $1 })
    }
    
    public static let lowercaseLetter = character.filter(("a"..."z").contains)
    public static let uppercaseLetter = character.filter(("A"..."Z").contains)
    public static let letter = lowercaseLetter ?? uppercaseLetter
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
    public static let digit = Parser<Character, String>.character.flatMap { Result($0) }
    public static let number = digit.many.map { $0.reduce(0, { 10 * $0 + $1 }) }
}

extension Parser where Result == Void {
    public static var empty: Parser {
        return Parser { ((), $0) }
    }
}
