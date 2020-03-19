public struct Parser<Output, Stream: StreamType> {
    let parse: (Stream.Substream) -> (Output, Stream.Substream)?
}

extension Parser {
    public func run(_ input: Stream) -> (result: Output, remainder: Stream)? {
        guard let (result, remainder) = parse(input.asSubstream) else { return nil }
        return (result, Stream(remainder))
    }
}

extension Parser {
    public static func result(_ output: Output) -> Self {
        .init { input in (output, input) }
    }
    
    public static var zero: Self {
        .init { _ in nil }
    }
    
    public func map<NewOutput>(_ transform: @escaping (Output) -> NewOutput) -> Parser<NewOutput, Stream> {
        .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return (transform(output), remainder)
        }
    }
    
    public func flatMap<NewOutput>(_ transform: @escaping (Output) -> Parser<NewOutput, Stream>) -> Parser<NewOutput, Stream> {
        .init { input in
            guard let (output, remainder) = self.parse(input) else { return nil }
            return transform(output).parse(remainder)
        }
    }
    
    public func compactMap<NewOutput>(_ transform: @escaping (Output) -> NewOutput?) -> Parser<NewOutput, Stream> {
        flatMap { transform($0).map { .result($0) } ?? .zero }
    }
    
    public func `where`(_ predicate: @escaping (Output) -> Bool) -> Self {
        compactMap { Optional($0, where: predicate) }
    }
}

extension Parser {
    func any<Separator, C: RangeReplaceableCollection>(_: C.Type, separator: Parser<Separator, Stream>) -> Parser<C, Stream> where C.Element == Output {
        .init { input in
            guard let (firstOutput, firstRemainder) = self.parse(input) else { return (C(), input) }
            
            var remainder = firstRemainder
            var result = C()
            result.append(firstOutput)
            
            while let (_, nextRemainder) = separator.parse(remainder), let (component, nextNextRemainder) = self.parse(nextRemainder) {
                result.append(component)
                remainder = nextNextRemainder
            }
            
            return (result, remainder)
        }
    }
    
    public func any<Separator>(separator: Parser<Separator, Stream>) -> Parser<[Output], Stream> {
        any(Array.self, separator: separator)
    }
    
    public var any: Parser<[Output], Stream> {
        any(separator: .empty)
    }
    
    public func many<Separator>(separator: Parser<Separator, Stream>) -> Parser<[Output], Stream> {
        any(separator: separator).nonEmpty
    }
    
    public var many: Parser<[Output], Stream> {
        many(separator: .empty)
    }
    
    public var optional: Parser<Output?, Stream> {
        .init { input in
            guard let (result, remainder) = self.parse(input) else { return (nil, input) }
            return (result, remainder)
        }
    }
    
    public func onMatch<NewValue>(_ value: NewValue) -> Parser<NewValue, Stream> {
        map { _ in value }
    }
    
    public var ignored: Parser<Void, Stream> {
        onMatch(())
    }
}

extension Parser where Output: Collection {
    public var nonEmpty: Self {
        `where` { !$0.isEmpty }
    }
}

extension Parser where Output == Stream.Element {
    public static var element: Self {
        .init { input in input.split() }
    }
}

extension Parser where Output == Stream.Element, Output: Equatable {
    public static func element(_ result: Output) -> Self {
        element(where: { $0 == result })
    }
    
    public static func element(where predicate: @escaping (Output) -> Bool) -> Self {
        element.where(predicate)
    }
    
    public static func not(_ result: Output) -> Self {
        element(where: { $0 != result })
    }
    
    public static func any<S: Sequence>(from sequence: S) -> Self where S.Element == Output {
        element(where: sequence.contains)
    }
    
    public static func any<S: Sequence>(notFrom sequence: S) -> Self where S.Element == Output {
        element(where: { !sequence.contains($0) })
    }
}

extension Parser where Output == Stream.Element, Output: Comparable {
    public static func any<Range: RangeExpression>(from range: Range) -> Self where Range.Bound == Output {
        element(where: range.contains)
    }
}

extension Parser where Output == Stream, Stream.Element: Equatable {
    public static func sequence(_ sequence: Stream) -> Self {
        .init { input in
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
