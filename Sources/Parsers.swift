public enum Parsers {
    public static var character: Parser<Character> {
        return Parser { input in
            guard let first = input.first else { return nil }
            return (first, input.dropFirst())
        }
    }
    
    public static func character(_ char: Character) -> Parser<Character> {
        return Parser(character, where: { $0 == char })
    }
    
    public static var digit: Parser<Int> {
        return character.flatMap { Int(String($0)) }
    }
    
    public static var number: Parser<Int> {
        return digit.many().map { $0.reduce(0, { 10 * $0 + $1 }) }
    }
    
    public static var empty: Parser<Void> {
        return Parser { ((), $0) }
    }
}
