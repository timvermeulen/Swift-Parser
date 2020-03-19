precedencegroup MonadicPrecedenceLeft {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup ApplicativeSequencePrecedence {
    associativity: left
    higherThan: ApplicativePrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup AlternativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

infix operator <^> : ApplicativePrecedence
infix operator >>- : MonadicPrecedenceLeft
infix operator <*> : ApplicativePrecedence
infix operator <*  : ApplicativeSequencePrecedence
infix operator  *> : ApplicativeSequencePrecedence
infix operator <|> : AlternativePrecedence

extension Parser {
    public static func <^> <T>(left: @escaping (Output) -> T, right: Parser) -> Parser<T, Stream> {
        right.map(left)
    }
    
    public static func <*> <T>(left: Parser<(Output) -> T, Stream>, right: Parser) -> Parser<T, Stream> {
        left.flatMap { $0 <^> right }
    }
    
    public static func <* <T>(left: Parser, right: Parser<T, Stream>) -> Self {
        .init { input in
            left.parse(input).flatMap { result, remainder1 in
                right.parse(remainder1).map { _, remainder2 in
                    (result, remainder2)
                }
            }
        }
    }
    
    public static func *> <T>(left: Parser<T, Stream>, right: Parser) -> Self {
        .init { input in
            left.parse(input).flatMap { _, remainder1 in
                right.parse(remainder1).map { result, remainder2 in
                    (result, remainder2)
                }
            }
        }
    }
    
    public static func <|> (left: Parser, right: @escaping @autoclosure () -> Parser) -> Self {
        .init { input in
            left.parse(input) ?? right().parse(input)
        }
    }
}
