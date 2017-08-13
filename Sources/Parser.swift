public struct Parser<Value> {
    internal let parse: (Substring) -> (result: Value, remainder: Substring)?
}

extension Parser {
    public func run(_ string: String) -> (result: Value, remainder: String)? {
        guard let (result, remainder) = parse(string[...]) else { return nil }
        return (result, String(remainder))
    }
}

extension Parser {
    public init(value: Value) {
        self.init { input in (value, input) }
    }
    
    public func map<Result>(_ transform: @escaping (Value) -> Result) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<Result>(_ transform: @escaping (Value) -> Result?) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input), let transformed = transform(output) else { return nil }
            return (transformed, remainder)
        }
    }
    
    public func flatMap<Result>(_ transform: @escaping (Value) -> Parser<Result>) -> Parser<Result> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
}

extension Parser {
    public init(_ parser: Parser, where predicate: @escaping (Value) -> Bool) {
        self = parser.flatMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    public func any<Separator>(separator: Parser<Separator>) -> Parser<[Value]> {
        return .init { input in
            guard let (firstValue, firstRemainder) = self.parse(input) else { return ([], input) }
            
            var remainder = firstRemainder
            var result = [firstValue]
            
            while let (_, nextRemainder) = separator.parse(remainder) {
                guard let (component, nextNextRemainder) = self.parse(nextRemainder) else { break }
                result.append(component)
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    public var any: Parser<[Value]> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator>) -> Parser<[Value]> {
        return .init(any(separator: separator), where: { !$0.isEmpty })
    }
    
    public var many: Parser<[Value]> {
        return many(separator: .empty)
    }
}
