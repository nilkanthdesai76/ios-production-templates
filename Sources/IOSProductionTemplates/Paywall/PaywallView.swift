import SwiftUI

// MARK: - Paywall Product Model

public struct PaywallTier: Identifiable, Hashable, Sendable {
    public let id: String
    public var title: String
    public var price: String
    public var period: String
    public var badge: String?
    public var isPopular: Bool

    public init(
        id: String,
        title: String,
        price: String,
        period: String,
        badge: String? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.period = period
        self.badge = badge
        self.isPopular = isPopular
    }
}

// MARK: - Paywall Feature Item

public struct PaywallFeature: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var icon: String
    public var title: String
    public var subtitle: String

    public init(id: UUID = UUID(), icon: String, title: String, subtitle: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

// MARK: - Production Paywall View

/// A full-featured In-App Purchase paywall supporting feature lists, subscription tiers, trial toggles, and restore purchases.
///
/// Usage:
/// ```swift
/// PaywallView(
///     tiers: sampleTiers,
///     features: sampleFeatures,
///     selectedTierId: $selectedId
/// ) { tier in
///     await purchase(tier)
/// } onRestore: {
///     await restore()
/// }
/// ```
public struct PaywallView: View {
    public var title: String
    public var subtitle: String
    public var features: [PaywallFeature]
    public var tiers: [PaywallTier]
    @Binding public var selectedTierId: String
    public var onPurchase: (PaywallTier) async -> Void
    public var onRestore: () async -> Void

    @State private var isPurchasing: Bool = false

    public init(
        title: String = "Unlock Pro",
        subtitle: String = "Get unlimited access to all premium features",
        features: [PaywallFeature],
        tiers: [PaywallTier],
        selectedTierId: Binding<String>,
        onPurchase: @escaping (PaywallTier) async -> Void,
        onRestore: @escaping () async -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.features = features
        self.tiers = tiers
        self._selectedTierId = selectedTierId
        self.onPurchase = onPurchase
        self.onRestore = onRestore
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 24)

                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Features list
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(features) { feature in
                        HStack(spacing: 14) {
                            Image(systemName: feature.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.title)
                                    .font(.system(size: 15, weight: .semibold))
                                Text(feature.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Subscription Tiers
                VStack(spacing: 10) {
                    ForEach(tiers) { tier in
                        let isSelected = selectedTierId == tier.id

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTierId = tier.id
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(tier.title)
                                            .font(.headline)
                                        if let badge = tier.badge {
                                            Text(badge)
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(tier.isPopular ? Color.orange : Color.blue)
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text(tier.period)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(tier.price)
                                    .font(.title3.weight(.bold))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(isSelected ? Color.blue.opacity(0.06) : Color(white: 0.98))
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                // Purchase CTA
                VStack(spacing: 12) {
                    Button {
                        guard let tier = tiers.first(where: { $0.id == selectedTierId }) else { return }
                        Task {
                            isPurchasing = true
                            await onPurchase(tier)
                            isPurchasing = false
                        }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Continue")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isPurchasing)

                    Button("Restore Purchases") {
                        Task {
                            await onRestore()
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
