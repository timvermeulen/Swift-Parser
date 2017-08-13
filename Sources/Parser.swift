public struct Parser<Stream: StreamType, Result> {
    internal let parse: (Stream.SubSequence) -> (result: Result, remainder: Stream.SubSequence)?
}

extension Parser {
    public func run(_ input: Stream) -> (result: Result, remainder: Stream)? {
        guard let (result, remainder) = parse(input[...]) else { return nil }
        return (result, Stream(remainder))
    }
}

extension Parser {
    public static func result(_ output: Result) -> Parser {
        return Parser { input in
            (output, input)
        }
    }
    
    public static var zero: Parser {
        return Parser { _ in nil }
    }
    
    public func map<NewResult>(_ transform: @escaping (Result) -> NewResult) -> Parser<Stream, NewResult> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> Parser<Stream, NewResult>) -> Parser<Stream, NewResult> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> NewResult?) -> Parser<Stream, NewResult> {
        return flatMap { transform($0).map { .result($0) } ?? .zero }
    }
    
    public func filter(_ predicate: @escaping (Result) -> Bool) -> Parser {
        return flatMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    public func any<Separator>(separator: Parser<Stream, Separator>) -> Parser<Stream, [Result]> {
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
    
    public var any: Parser<Stream, [Result]> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Stream, Separator>) -> Parser<Stream, [Result]> {
        return any(separator: separator).nonEmpty
    }
    
    public var many: Parser<Stream, [Result]> {
        return many(separator: .empty)
    }
    
    public static func ?? (left: Parser, right: @escaping @autoclosure () -> Parser) -> Parser {
        return Parser { input in
            left.parse(input) ?? right().parse(input)
        }
    }
    
    public var optional: Parser<Stream, Result?> {
        return .init { input in
            guard let (result, remainder) = self.parse(input) else { return (nil, input) }
            return (result, remainder)
        }
    }
}

extension Parser where Result: Collection {
    public var nonEmpty: Parser {
        return filter { !$0.isEmpty }
    }
}

extension Parser where Result == Stream.Element {
    public static var item: Parser {
        return Parser { input in
            guard let first = input.first else { return nil }
            return (first, input.dropFirst())
        }
    }
}
