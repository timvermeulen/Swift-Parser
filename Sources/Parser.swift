public struct Parser<Result, Stream: StreamType> {
    internal let parse: (Stream.Substream) -> (result: Result, remainder: Stream.Substream)?
}

extension Parser {
    public func run(_ input: Stream) -> (result: Result, remainder: Stream)? {
        guard let (result, remainder) = parse(input.asSubstream) else { return nil }
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
    
    public func map<NewResult>(_ transform: @escaping (Result) -> NewResult) -> Parser<NewResult, Stream> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> Parser<NewResult, Stream>) -> Parser<NewResult, Stream> {
        return .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
    
    public func flatMap<NewResult>(_ transform: @escaping (Result) -> NewResult?) -> Parser<NewResult, Stream> {
        return flatMap { transform($0).map { .result($0) } ?? .zero }
    }
    
    public func when(_ predicate: @escaping (Result) -> Bool) -> Parser {
        return flatMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    internal func any<Separator, C: RangeReplaceableCollection>(_: C.Type, separator: Parser<Separator, Stream>) -> Parser<C, Stream> where C.Element == Result {
        return .init { input in
            guard let (firstResult, firstRemainder) = self.parse(input) else { return (C(), input) }
            
            var remainder = firstRemainder
            var result = C()
            result.append(firstResult)
            
            while let (_, nextRemainder) = separator.parse(remainder), let (component, nextNextRemainder) = self.parse(nextRemainder) {
                result.append(component)
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    public func any<Separator>(separator: Parser<Separator, Stream>) -> Parser<[Result], Stream> {
        return any(Array.self, separator: separator)
    }
    
    public var any: Parser<[Result], Stream> {
        return any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator, Stream>) -> Parser<[Result], Stream> {
        return any(separator: separator).nonEmpty
    }
    
    public var many: Parser<[Result], Stream> {
        return many(separator: .empty)
    }
    
    public var optional: Parser<Result?, Stream> {
        return .init { input in
            guard let (result, remainder) = self.parse(input) else { return (nil, input) }
            return (result, remainder)
        }
    }
    
    public func onMatch<NewValue>(_ value: NewValue) -> Parser<NewValue, Stream> {
        return map { _ in value }
    }
    
    public var ignored: Parser<Void, Stream> {
        return onMatch(())
    }
}

extension Parser where Result: Collection {
    public var nonEmpty: Parser {
        return when { !$0.isEmpty }
    }
}

extension Parser where Result == Stream.Element {
    public static var element: Parser {
        return Parser { input in input.split() }
    }
}

extension Parser where Result == Stream.Element, Result: Equatable {
    public static func element(_ result: Result) -> Parser {
        return element(where: { $0 == result })
    }
    
    public static func element(where predicate: @escaping (Result) -> Bool) -> Parser {
        return element.when(predicate)
    }
    
    public static func not(_ result: Result) -> Parser {
        return element(where: { $0 != result })
    }
    
    public static func any<S: Sequence>(from sequence: S) -> Parser where S.Element == Result {
        return element(where: sequence.contains)
    }
    
    public static func any<S: Sequence>(notFrom sequence: S) -> Parser where S.Element == Result {
        return element(where: { !sequence.contains($0) })
    }
}

extension Parser where Result == Stream.Element, Result: Comparable {
    public static func any<Range: RangeExpression>(from range: Range) -> Parser where Range.Bound == Result {
        return element(where: range.contains)
    }
}

extension Parser where Result == Stream, Stream.Element: Equatable {
    public static func sequence(_ sequence: Stream) -> Parser {
        return Parser { input in
            var subsequence = sequence.asSubstream
            var remainder = input
            
            while let (head, tail) = subsequence.split() {
                guard let (_, newRemainder) = Parser<Stream.Element, Stream>.element(head).parse(remainder) else { return nil }
                remainder = newRemainder
                subsequence = tail
            }
            
            return (sequence, remainder)
        }
    }
}
