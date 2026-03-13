import SwiftUI

enum Theme {
    // Orangish palette
    static let orange = Color(red: 0.98, green: 0.45, blue: 0.14)
    static let orangeDeep = Color(red: 0.90, green: 0.32, blue: 0.10)
    static let background = Color(red: 1.00, green: 0.97, blue: 0.94)
    static let card = Color.white
    static let textPrimary = Color(red: 0.14, green: 0.10, blue: 0.10)
    static let textSecondary = Color(red: 0.36, green: 0.28, blue: 0.26)
    static let border = Color.black.opacity(0.08)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Theme.orange, Theme.orangeDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}

