import SwiftUI

// Visual language from Section 3 of the PRD.
enum Theme {
    static let background = Color(hex: 0xF5F3EE)
    static let card = Color.white
    static let accent = Color(hex: 0xC9A84C)
    static let verifiedGreen = Color(red: 0.20, green: 0.55, blue: 0.30)
    static let flagRed = Color(red: 0.75, green: 0.20, blue: 0.20)
    static let cardCornerRadius: CGFloat = 12

    static func categoryColor(for category: ReceiptCategory) -> Color {
        switch category {
        case .groceries: return Color(red: 0.55, green: 0.75, blue: 0.55)
        case .dining: return Color(red: 0.85, green: 0.65, blue: 0.35)
        case .transport: return Color(red: 0.45, green: 0.60, blue: 0.85)
        case .electronics: return Color(red: 0.85, green: 0.40, blue: 0.40)
        case .health: return Color(red: 0.60, green: 0.60, blue: 0.60)
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
