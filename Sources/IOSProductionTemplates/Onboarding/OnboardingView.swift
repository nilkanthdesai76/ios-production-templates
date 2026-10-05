import SwiftUI

// MARK: - Onboarding Step Model

public struct OnboardingStep: Identifiable, Sendable {
    public let id: Int
    public var icon: String
    public var iconColor: Color
    public var title: String
    public var description: String

    public init(
        id: Int,
        icon: String,
        iconColor: Color = .blue,
        title: String,
        description: String
    ) {
        self.id = id
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
}

// MARK: - Onboarding Flow View

/// A polished, multi-step onboarding wizard with animated indicators and get started completion.
///
/// Usage:
/// ```swift
/// OnboardingView(steps: sampleSteps) {
///     hasCompletedOnboarding = true
/// }
/// ```
public struct OnboardingView: View {
    public var steps: [OnboardingStep]
    public var onComplete: () -> Void

    @State private var currentStepIndex: Int = 0

    public init(steps: [OnboardingStep], onComplete: @escaping () -> Void) {
        self.steps = steps
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 32) {
            // Skip button
            HStack {
                Spacer()
                if currentStepIndex < steps.count - 1 {
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }

            Spacer()

            // Step Content
            let step = steps[currentStepIndex]

            VStack(spacing: 24) {
                Image(systemName: step.icon)
                    .font(.system(size: 72))
                    .foregroundColor(step.iconColor)
                    .frame(width: 120, height: 120)
                    .background(step.iconColor.opacity(0.12))
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))

                VStack(spacing: 12) {
                    Text(step.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(step.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .id(currentStepIndex)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentStepIndex)

            Spacer()

            // Page indicators & Next button
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: index == currentStepIndex ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStepIndex)
                    }
                }

                Button {
                    if currentStepIndex < steps.count - 1 {
                        withAnimation {
                            currentStepIndex += 1
                        }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentStepIndex < steps.count - 1 ? "Next" : "Get Started")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
