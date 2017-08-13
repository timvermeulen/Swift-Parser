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

infix operator <^>: ApplicativePrecedence
infix operator >>-: MonadicPrecedenceLeft
infix operator <*>: ApplicativePrecedence
infix operator <* : ApplicativeSequencePrecedence
infix operator  *>: ApplicativeSequencePrecedence

public func <^> <Stream, A, B>(left: @escaping (A) -> B, right: Parser<A, Stream>) -> Parser<B, Stream> {
    return right.map(left)
}

public func >>- <Stream, A, B>(left: Parser<A, Stream>, right: @escaping (A) -> B?) -> Parser<B, Stream> {
    return left.flatMap(right)
}

public func <*> <Stream, A, B>(left: Parser<(A) -> B, Stream>, right: Parser<A, Stream>) -> Parser<B, Stream> {
    return Parser { input in
        left.parse(input).flatMap { function, remainder1 in
            right.parse(remainder1).map { parameter, remainder2 in
                (function(parameter), remainder2)
            }
        }
    }
}

public func <* <Stream, A, B>(left: Parser<A, Stream>, right: Parser<B, Stream>) -> Parser<A, Stream> {
    return Parser { input in
        left.parse(input).flatMap { result, remainder1 in
            right.parse(remainder1).map { _, remainder2 in
                (result, remainder2)
            }
        }
    }
}

public func *> <Stream, A, B>(left: Parser<A, Stream>, right: Parser<B, Stream>) -> Parser<B, Stream> {
    return Parser { input in
        left.parse(input).flatMap { _, remainder1 in
            right.parse(remainder1).map { result, remainder2 in
                (result, remainder2)
            }
        }
    }
}
