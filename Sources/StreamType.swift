public protocol StreamType: Collection where SubSequence: Collection {
    init(_ subsequence: SubSequence)
}

extension Array: StreamType {}
extension ArraySlice: StreamType {}
extension String: StreamType {}
extension Substring: StreamType {}
