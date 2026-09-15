import SwiftUI

enum ActionButtonStyle {
    case filled
    case outlined
    case outlinedDestructive
}

struct ActionButton: View {
    let title: String
    var style: ActionButtonStyle = .filled
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(background)
        .foregroundColor(foreground)
        .overlay(
            Capsule().stroke(borderColor, lineWidth: style == .filled ? 0 : 1.5)
        )
        .clipShape(Capsule())
    }

    private var background: Color {
        switch style {
        case .filled: return .black
        case .outlined, .outlinedDestructive: return .clear
        }
    }

    private var foreground: Color {
        switch style {
        case .filled: return .white
        case .outlined: return .black
        case .outlinedDestructive: return Theme.flagRed
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled: return .clear
        case .outlined: return .black
        case .outlinedDestructive: return Theme.flagRed
        }
    }
}
