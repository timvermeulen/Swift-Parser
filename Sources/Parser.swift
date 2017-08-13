public struct Parser<Result, Stream: StreamType, State> {
    internal let parse: (inout State, Stream.SubSequence) -> (result: Result, remainder: Stream.SubSequence)?
    
    init(parse: @escaping (inout State, Stream.SubSequence) -> (result: Result, remainder: Stream.SubSequence)?) {
        self.parse = parse
    }
}

extension Parser {
    public func run(_ input: Stream, state: State) -> (result: Result, remainder: Stream, state: State)? {
        var state = state
        guard let (result, remainder) = parse(&state, input[...]) else { return nil }
        return (result, Stream(remainder), state)
    }
}

extension Parser where State == Void {
    public func run(_ input: Stream) -> (result: Result, remainder: Stream)? {
        guard let (result, remainder, _) = run(input, state: ()) else { return nil }
        return (result, remainder)
    }
}

extension Parser {
    public static func result(_ output: Result) -> Parser {
        return Parser { _, input in
            (output, input)
        }
    }
    
    public static var zero: Parser {
        return Parser { _, _ in nil }
    }
    
    public func map<NewResult>(_ transform: @escaping (Result) -> NewResult) -> Parser<NewResult, Stream, State> {
        return .init { state, input in
            guard let (output, remainder) = self.parse(&state, input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> Parser<NewResult, Stream, State>) -> Parser<NewResult, Stream, State> {
        return .init { state, input in
            guard let (output, remainder) = self.parse(&state, input) else { return nil }
            return transform(output).parse(&state, remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> NewResult?) -> Parser<NewResult, Stream, State> {
        return flatMap { transform($0).map { .result($0) } ?? .zero }
    }
    
    func filter(_ predicate: @escaping (Result) -> Bool) -> Parser {
        return flatMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    public func any<Separator>(separator: Parser<Separator, Stream, State>) -> Parser<[Result], Stream, State> {
        return .init { state, input in
            guard let (firstResult, firstRemainder) = self.parse(&state, input) else { return ([], input) }
            
            var remainder = firstRemainder
            var result = [firstResult]
            
            while let (_, nextRemainder) = separator.parse(&state, remainder), let (component, nextNextRemainder) = self.parse(&state, nextRemainder) {
                result.append(component)
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    public var any: Parser<[Result], Stream, State> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator, Stream, State>) -> Parser<[Result], Stream, State> {
        return any(separator: separator).nonEmpty
    }
    
    public var many: Parser<[Result], Stream, State> {
        return many(separator: .empty)
    }
    
    public static func ?? (left: Parser, right: @escaping @autoclosure () -> Parser) -> Parser {
        return Parser { state, input in
            left.parse(&state, input) ?? right().parse(&state, input)
        }
    }
    
    public var optional: Parser<Result?, Stream, State> {
        return .init { state, input in
            guard let (result, remainder) = self.parse(&state, input) else { return (nil, input) }
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
        return Parser { _, input in
            guard let first = input.first else { return nil }
            return (first, input.dropFirst())
        }
    }
}
