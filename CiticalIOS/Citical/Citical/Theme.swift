import SwiftUI

enum Theme {
    static let orange = Color(red: 0.93, green: 0.45, blue: 0.13)
    static let orangeDark = Color(red: 0.69, green: 0.24, blue: 0.03)
    static let orangeSoft = Color(red: 0.99, green: 0.93, blue: 0.86)
    static let gold = Color(red: 0.95, green: 0.76, blue: 0.33)
    static let slate = Color(red: 0.15, green: 0.19, blue: 0.24)

    static let background = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let card = Color.white
    static let cardTint = Color(red: 0.96, green: 0.95, blue: 0.92)
    static let border = Color.black.opacity(0.08)

    static let textPrimary = Color.primary
    static let textSecondary = Color(red: 0.35, green: 0.38, blue: 0.42)
    static let success = Color(red: 0.17, green: 0.55, blue: 0.35)
    static let warning = Color(red: 0.80, green: 0.42, blue: 0.11)
    static let danger = Color(red: 0.72, green: 0.16, blue: 0.12)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Theme.orange.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Theme.orangeDark.opacity(configuration.isPressed ? 0.6 : 0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
