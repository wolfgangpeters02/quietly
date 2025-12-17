import SwiftUI

extension View {
    // MARK: - Card Style
    func cardStyle(padding: CGFloat = AppConstants.UI.cardPadding) -> some View {
        self
            .padding(padding)
            .background(Color.quietly.card)
            .cornerRadius(AppConstants.UI.cornerRadius)
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
            .cornerRadius(AppConstants.UI.cornerRadius)
    }

    // MARK: - Secondary Button Style
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Color.quietly.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.quietly.secondary)
            .cornerRadius(AppConstants.UI.cornerRadius)
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
