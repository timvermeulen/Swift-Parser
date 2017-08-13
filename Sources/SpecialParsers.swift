extension Parser where Result == Character {
    public static var character: Parser {
        return Parser { input in
            guard let first = input.first else { return nil }
            return (first, input.dropFirst())
        }
    }
    
    public static func character(_ char: Character) -> Parser {
        return Parser(character, where: { $0 == char })
    }
}

extension Parser where Result == Int {
    public static var digit: Parser {
        return Parser<Character>.character.flatMap { Result($0) }
    }
    
    public static var number: Parser {
        return digit.many.map { $0.reduce(0, { 10 * $0 + $1 }) }
    }
}

extension Parser where Result == Void {
    public static var empty: Parser {
        return Parser { ((), $0) }
    }
}