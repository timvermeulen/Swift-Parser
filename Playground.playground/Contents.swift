import Parser

// ^([A-G][b#]?)(min)?$

struct Key {
    var pitch: PitchClass
    var mode: Mode
}

extension PitchClass {
    init?(key: String) {
        guard let pitchClass = PitchClass.PITCH_CLASSES.joined().first(where: { $0.name == key }) else { return nil }
        self = pitchClass
    }
}

extension Mode {
    init?(abbreviation: String) {
        guard let mode = Mode.allCases.first(where: { $0.abbreviation == abbreviation }) else { return nil }
        self = mode
    }
}

let x = (Mode.init <^> "abc").compactMap { $0 }


let pitchClassParser = "A" <|> "B" <|> "C" <|> "D" <|> "E" <|> "F"
StringParser.character.where(("A"..."F").contains)
