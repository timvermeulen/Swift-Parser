extension FixedWidthInteger {
    init?(_ character: Character, radix: Int = 10) {
        self.init(String(character), radix: radix)
    }
}
