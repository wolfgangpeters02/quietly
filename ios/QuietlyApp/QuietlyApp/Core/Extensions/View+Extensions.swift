import SwiftUI

extension View {
    // MARK: - Modern Card Style (layered shadows, continuous corners)
    func modernCard(
        padding: CGFloat = AppConstants.UI.cardPadding,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self
            .padding(padding)
            .background(Color.quietly.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            .shadow(color: Color.quietly.shadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Glass Card Style
    func glassCard(
        padding: CGFloat = AppConstants.UI.cardPadding,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: - Safe Area Background
    func safeAreaBackground(_ color: Color) -> some View {
        self.background(color.ignoresSafeArea())
    }

    // MARK: - Continuous Corners
    func continuousCorners(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    // MARK: - Legacy Card Style
    func cardStyle(padding: CGFloat = AppConstants.UI.cardPadding) -> some View {
        self
            .padding(padding)
            .background(Color.quietly.card)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius, style: .continuous))
            .shadow(color: Color.quietly.shadow, radius: 4, x: 0, y: 2)
    }

    // MARK: - Primary Button Style
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Color.quietly.primaryForeground)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.quietly.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius, style: .continuous))
    }

    // MARK: - Secondary Button Style
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Color.quietly.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.quietly.secondary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius, style: .continuous))
    }

    // MARK: - Conditional Modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Hide Keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Loading Overlay
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }

    // MARK: - Shake Animation
    func shake(_ isShaking: Binding<Bool>) -> some View {
        self.modifier(ShakeEffect(shakes: isShaking.wrappedValue ? 2 : 0))
            .animation(.default, value: isShaking.wrappedValue)
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    init(shakes: Int) {
        animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// MARK: - Placeholder Modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Dismiss Keyboard on Tap
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Custom Rounded Text Field Style
struct QuietlyTextFieldStyle: TextFieldStyle {
    var width: CGFloat? = nil

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.quietly.card)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.quietly.cardBorder, lineWidth: 1)
            )
            .frame(width: width)
    }
}

extension TextFieldStyle where Self == QuietlyTextFieldStyle {
    static var quietly: QuietlyTextFieldStyle { QuietlyTextFieldStyle() }

    static func quietly(width: CGFloat) -> QuietlyTextFieldStyle {
        QuietlyTextFieldStyle(width: width)
    }
}
