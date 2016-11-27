struct Parser<Value> {
    typealias Stream = String.CharacterView
    let parse: (Stream) -> (result: Value, remainder: Stream)?
}

extension Parser {
    func run(_ string: String) -> (result: Value, remainder: String)? {
        guard let (result, remainder) = self.parse(string.characters) else { return nil }
        return (result, String(remainder))
    }
}

extension Parser {
    init(value: Value) {
        self.init { input in (value, input) }
    }
    
    func map<Result>(_ transform: @escaping (Value) -> Result) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    func flatMap<Result>(_ transform: @escaping (Value) -> Result?) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input), let transformed = transform(output) else { return nil }
            return (transformed, remainder)
        }
    }
    
    func flatMap<Result>(_ transform: @escaping (Value) -> Parser<Result>) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
}

extension Parser {
    init(_ parser: Parser, where predicate: @escaping (Value) -> Bool) {
        self = parser.flatMap { predicate($0) ? $0 : nil }
    }
}

extension Parser {
    func any<Separator>(separator: Parser<Separator>) -> Parser<[Value]> {
        return .init { input in
            var remainder = input
            var result: [Value] = []
            
            while let (component, nextRemainder) = self.parse(remainder) {
                remainder = nextRemainder
                result.append(component)
                
                guard let (_, nextNextRemainder) = separator.parse(nextRemainder) else { break }
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    func any() -> Parser<[Value]> {
        return self.any(separator: Parsers.empty)
    }
    
    func many<Separator>(separator: Parser<Separator>) -> Parser<[Value]> {
        return .init(self.any(separator: separator), where: { !$0.isEmpty })
    }
    
    func many() -> Parser<[Value]> {
        return self.many(separator: Parsers.empty)
    }
}