import XCTest
import SwiftUI
@testable import IOSProductionTemplates

enum TestRoute: AppRoute {
    case detail(String)
    case settings

    var id: String {
        switch self {
        case .detail(let s): return "detail_\(s)"
        case .settings: return "settings"
        }
    }
}

struct TestItem: SyncableItem {
    var id: String
    var updatedAt: Date
    var isDirty: Bool
}

final class IOSProductionTemplatesTests: XCTestCase {

    func testVersion() {
        XCTAssertEqual(IOSProductionTemplates.version, "1.0.0")
    }

    func testPaywallTierCreation() {
        let tier = PaywallTier(id: "annual", title: "Annual", price: "$49.99", period: "per year", badge: "Best Value", isPopular: true)
        XCTAssertEqual(tier.id, "annual")
        XCTAssertEqual(tier.price, "$49.99")
        XCTAssertTrue(tier.isPopular)
    }

    func testOnboardingStepCreation() {
        let step = OnboardingStep(id: 1, icon: "star.fill", title: "Welcome", description: "Get started")
        XCTAssertEqual(step.id, 1)
        XCTAssertEqual(step.title, "Welcome")
    }

    @MainActor
    func testNavigationCoordinator() {
        let coordinator = NavigationCoordinator<TestRoute>()
        XCTAssertTrue(coordinator.path.isEmpty)

        coordinator.push(.detail("123"))
        XCTAssertEqual(coordinator.path.count, 1)

        coordinator.push(.settings)
        XCTAssertEqual(coordinator.path.count, 2)

        coordinator.pop()
        XCTAssertEqual(coordinator.path.count, 1)

        coordinator.popToRoot()
        XCTAssertTrue(coordinator.path.isEmpty)
    }

    func testSyncEngineEnqueue() async {
        let engine = SyncEngine<TestItem>()
        let item1 = TestItem(id: "1", updatedAt: Date(), isDirty: true)
        let item2 = TestItem(id: "2", updatedAt: Date(), isDirty: true)

        await engine.enqueue(item1)
        await engine.enqueue(item2)

        let count = await engine.pendingCount
        XCTAssertEqual(count, 2)
    }
}
