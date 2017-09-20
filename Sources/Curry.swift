public func curry<A, B>(_ f: @escaping (A) -> B) -> (A) -> B {
    return { a in f(a) }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        { b in f(a, b) }
    }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in
        { b in
            { c in f(a, b, c) }
        }
    }
}

public func curry<A, B, C, D, E>(_ f: @escaping (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in
        { b in
            { c in
                { d in f(a, b, c, d) }
            }
        }
    }
}

public func makeTuple<A>(a: A) -> A {
    return (a)
}

public func makeTuple<A, B>(a: A) -> (B) -> (A, B) {
    return { b in (a, b) }
}

public func makeTuple<A, B, C>(a: A) -> (B) -> (C) -> (A, B, C) {
    return { b in
        { c in (a, b, c) }
    }
}

public func makeTuple<A, B, C, D>(a: A) -> (B) -> (C) -> (D) -> (A, B, C, D) {
    return { b in
        { c in
            { d in (a, b, c, d) }
        }
    }
}
