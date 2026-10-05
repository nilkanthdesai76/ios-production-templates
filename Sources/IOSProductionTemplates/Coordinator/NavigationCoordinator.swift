import SwiftUI

// MARK: - Navigation Route

public protocol AppRoute: Hashable, Identifiable {
    var id: String { get }
}

// MARK: - Navigation Coordinator

/// A decoupled navigation coordinator managing programmatic navigation stacks, sheets, and full-screen covers.
///
/// Usage:
/// ```swift
/// @StateObject var coordinator = NavigationCoordinator<MyRoute>()
///
/// CoordinatorHost(coordinator: coordinator) { route in
///     destinationView(for: route)
/// }
/// ```
@MainActor
public final class NavigationCoordinator<Route: AppRoute>: ObservableObject {
    @Published public var path: [Route] = []
    @Published public var presentedSheet: Route?
    @Published public var presentedCover: Route?

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func presentSheet(_ route: Route) {
        presentedSheet = route
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func presentCover(_ route: Route) {
        presentedCover = route
    }

    public func dismissCover() {
        presentedCover = nil
    }
}

// MARK: - Coordinator Host View

public struct CoordinatorHost<Route: AppRoute, RootContent: View, DestinationContent: View>: View {
    @ObservedObject public var coordinator: NavigationCoordinator<Route>
    public var root: () -> RootContent
    public var destination: (Route) -> DestinationContent

    public init(
        coordinator: NavigationCoordinator<Route>,
        @ViewBuilder root: @escaping () -> RootContent,
        @ViewBuilder destination: @escaping (Route) -> DestinationContent
    ) {
        self.coordinator = coordinator
        self.root = root
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            destination(route)
        }
        #if os(iOS)
        .fullScreenCover(item: $coordinator.presentedCover) { route in
            destination(route)
        }
        #endif
    }
}
