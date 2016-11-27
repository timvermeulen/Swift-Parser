enum Parsers {
    static var character: Parser<Character> {
        return Parser { input in
            guard let first = input.first else { return nil }
            return (first, input.dropFirst())
        }
    }
    
    static func character(_ char: Character) -> Parser<Character> {
        return Parser(character, where: { $0 == char })
    }
    
    static var digit: Parser<Int> {
        return character.flatMap { Int(String($0)) }
    }
    
    static var number: Parser<Int> {
        return digit.many().map { $0.reduce(0, { 10 * $0 + $1 }) }
    }
    
    static var empty: Parser<Void> {
        return Parser { ((), $0) }
    }
}
