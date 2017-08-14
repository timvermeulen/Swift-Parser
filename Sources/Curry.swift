public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { x in
        { y in f(x, y) }
    }
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { x in
        { y in
            { z in f(x, y, z) }
        }
    }
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
