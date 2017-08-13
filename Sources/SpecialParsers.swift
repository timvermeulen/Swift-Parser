extension Parser where Result == Character {
    public static let character = Parser { input in
        guard let first = input.first else { return nil }
        return (first, input.dropFirst())
    }
    
    public static func character(_ character: Character) -> Parser {
        return Parser<Character>.character.filter { $0 == character }
    }
    
    public static func anyCharacter<S: Sequence>(from sequence: S) -> Parser<Character> where S.Element == Character {
        return sequence.map(character).reduce(zero, { $0 ?? $1 })
    }
    
    public static let lowercaseLetter = character.filter(("a"..."z").contains)
    public static let uppercaseLetter = character.filter(("A"..."Z").contains)
    public static let letter = lowercaseLetter ?? uppercaseLetter
}

extension Parser where Result == String {
    public static let word = Parser<Character>.letter.many.map { String($0) }
    
    public static func string(_ string: String) -> Parser {
        return Parser { input in
            let result = string.reduce(Optional.some(input[...])) { remainder, character in
                remainder.flatMap { Parser<Character>.character(character).parse($0)?.remainder }
            }
            
            return result.map { (string, $0) }
        }
    }
}

extension Parser where Result == Int {
    public static let digit = Parser<Character>.character.flatMap { Result($0) }
    public static let number = digit.many.map { $0.reduce(0, { 10 * $0 + $1 }) }
}

extension Parser where Result == Void {
    public static let empty = Parser { ((), $0) }
}
