import Foundation

public enum WhiteKey: String {
    case A, B, C, D, E, F, G
}

public enum PitchClass: Equatable {
    
    case A_FLAT
    case A
    case B_FLAT
    case B
    case C
    case D_FLAT
    case D
    case E_FLAT
    case E
    case F
    case G_FLAT
    case G
    case G_SHARP
    case A_SHARP
    case C_SHARP
    case D_SHARP
    case F_SHARP
    
    public static func == (lhs: PitchClass, rhs: PitchClass) -> Bool {
        return lhs.midiOffset == rhs.midiOffset
    }
    
    public var midiOffset: Int {
        switch self {
        case .A_FLAT:
            return 8
        case .A:
            return 9
        case .B_FLAT:
            return 10
        case .B:
            return 11
        case .C:
            return 0
        case .D_FLAT:
            return 1
        case .D:
            return 2
        case .E_FLAT:
            return 3
        case .E:
            return 4
        case .F:
            return 5
        case .G_FLAT:
            return 6
        case .G:
            return 7
        case .G_SHARP:
            return 8
        case .A_SHARP:
            return 10
        case .C_SHARP:
            return 1
        case .D_SHARP:
            return 3
        case .F_SHARP:
            return 6
        }
    }
    
    public var whiteKey: WhiteKey {
        switch self {
        case .A_FLAT:
            return .A
        case .A:
            return .A
        case .B_FLAT:
            return .B
        case .B:
            return .B
        case .C:
            return .C
        case .D_FLAT:
            return .D
        case .D:
            return .D
        case .E_FLAT:
            return .E
        case .E:
            return .E
        case .F:
            return .F
        case .G_FLAT:
            return .G
        case .G:
            return .G
        case .G_SHARP:
            return .G
        case .A_SHARP:
            return .A
        case .C_SHARP:
            return .C
        case .D_SHARP:
            return .D
        case .F_SHARP:
            return .F
        }
    }
    
    public var baseName: String {
        return self.whiteKey.rawValue
    }
    
    public var fancyName: String {
        return "\(baseName)\(flat ? "♭" : "")\(sharp ? "♯" : "")"
    }
    
    public var name: String {
        return "\(baseName)\(flat ? "b" : "")\(sharp ? "#" : "")"
    }
    
    public var flat: Bool {
        switch self {
        case .A_FLAT, .B_FLAT, .D_FLAT, .E_FLAT, .G_FLAT:
            return true
        default:
            return false
        }
    }
    
    public var sharp: Bool {
        switch self {
        case .A_SHARP, .C_SHARP, .D_SHARP, .F_SHARP, .G_SHARP:
            return true
        default:
            return false
        }
    }
    
    public static let PITCH_CLASSES = [[C], [D_FLAT, C_SHARP], [D], [E_FLAT, D_SHARP], [E], [F], [F_SHARP, G_FLAT], [G], [A_FLAT, G_SHARP], [A], [B_FLAT, A_SHARP], [B]]
}

public enum Mode {
    case major
    case minor
    case ionian
    case dorian
    case phrygian
    case lydian
    case mixolydian
    case aeolian
    case locrian
    
    public var abbreviation: String {
        switch self {
        case .major:
            return ""
        case .minor:
            return "min"
        case .ionian:
            return "ion"
        case .dorian:
            return "dor"
        case .phrygian:
            return "phr"
        case .lydian:
            return "lyd"
        case .mixolydian:
            return "mix"
        case .aeolian:
            return "aeo"
        case .locrian:
            return "loc"
        }
    }
    
    public var keyModes: Int {
        switch self {
        case .major:
            return 0
        case .minor:
            return 3
        case .ionian:
            return 0
        case .dorian:
            return -2
        case .phrygian:
            return -4
        case .lydian:
            return -5
        case .mixolydian:
            return -7
        case .aeolian:
            return 3
        case .locrian:
            return 1
        }
    }
    
    public static let allCases = [Mode.major, .minor, .ionian, .dorian, .phrygian, .lydian, mixolydian, .aeolian, .locrian]
}
