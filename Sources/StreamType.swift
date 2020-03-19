public protocol StreamType {
    associatedtype Element
    associatedtype Substream: SubstreamType where Substream.Element == Element
    
    var asSubstream: Substream { get }
    init(_ substream: Substream)
}

public protocol SubstreamType {
    associatedtype Element
    
    func split() -> (Element, Self)?
}

extension Collection where Self: StreamType {
    public var asSubstream: SubSequence {
        self[...]
    }
}

extension Collection where Self: SubstreamType, SubSequence == Self {
    public func split() -> (Self.Element, Self)? {
        first.map { ($0, dropFirst()) }
    }
}

extension Array: StreamType {
    public typealias Substream = ArraySlice<Element>
}

extension String: StreamType {
    public typealias Substream = Substring
}

extension Substring: SubstreamType {}
extension ArraySlice: SubstreamType {}
