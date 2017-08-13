public struct Parser<Result> {
    internal let parse: (Substring) -> (result: Result, remainder: Substring)?
}

extension Parser {
    public func run(_ string: String) -> (result: Result, remainder: String)? {
        guard let (result, remainder) = parse(string[...]) else { return nil }
        return (result, String(remainder))
    }
}

extension Parser {
    public init(value: Result) {
        self.init { input in (value, input) }
    }
    
    public func map<NewResult>(_ transform: @escaping (Result) -> NewResult) -> Parser<NewResult> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> NewResult?) -> Parser<NewResult> {
        return .init { input in
            guard let (output, remainder) = self.parse(input), let transformed = transform(output) else { return nil }
            return (transformed, remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> Parser<NewResult>) -> Parser<NewResult> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
}

extension Parser {
    public init(_ parser: Parser, where predicate: @escaping (Result) -> Bool) {
        self = parser.flatMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    public func any<Separator>(separator: Parser<Separator>) -> Parser<[Result]> {
        return .init { input in
            guard let (firstResult, firstRemainder) = self.parse(input) else { return ([], input) }
            
            var remainder = firstRemainder
            var result = [firstResult]
            
            while let (_, nextRemainder) = separator.parse(remainder), let (component, nextNextRemainder) = self.parse(nextRemainder) {
                result.append(component)
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    public var any: Parser<[Result]> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator>) -> Parser<[Result]> {
        return .init(any(separator: separator), where: { !$0.isEmpty })
    }
    
    public var many: Parser<[Result]> {
        return many(separator: .empty)
    }
    
    static func ?? (left: Parser, right: @escaping @autoclosure () -> Parser) -> Parser {
        return Parser { input in
            left.parse(input) ?? right().parse(input)
        }
    }
    
    var optional: Parser<Result?> {
        return .init { input in
            guard let (result, remainder) = self.parse(input) else { return (nil, input) }
            return (result, remainder)
        }
    }
}

extension Parser where Result: Collection {
    var nonEmpty: Parser {
        return Parser { input in
            self.parse(input).flatMap { Optional($0, where: { !$0.result.isEmpty }) }
        }
    }
}
