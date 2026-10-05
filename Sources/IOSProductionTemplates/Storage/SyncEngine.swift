import Foundation

// MARK: - Sync State

public enum SyncStatus: Equatable, Sendable {
    case idle
    case syncing
    case success(Date)
    case failed(String)
}

// MARK: - Syncable Item Protocol

public protocol SyncableItem: Identifiable, Sendable {
    var id: String { get }
    var updatedAt: Date { get }
    var isDirty: Bool { get set }
}

// MARK: - Offline First Sync Engine

/// A lightweight, resilient offline-first synchronization engine managing pending mutations and server reconciliation.
///
/// Usage:
/// ```swift
/// let engine = SyncEngine<Note>()
/// await engine.sync { dirtyItems in
///     try await api.pushMutations(dirtyItems)
/// } pull: {
///     try await api.fetchUpdates()
/// }
/// ```
public actor SyncEngine<Item: SyncableItem> {
    private(set) public var status: SyncStatus = .idle
    private var pendingQueue: [Item] = []

    public init() {}

    public func enqueue(_ item: Item) {
        if let idx = pendingQueue.firstIndex(where: { $0.id == item.id }) {
            pendingQueue[idx] = item
        } else {
            pendingQueue.append(item)
        }
    }

    public var pendingCount: Int {
        pendingQueue.count
    }

    public func sync(
        push: ([Item]) async throws -> Void,
        pull: () async throws -> [Item]
    ) async -> Result<[Item], Error> {
        status = .syncing

        do {
            if !pendingQueue.isEmpty {
                try await push(pendingQueue)
                pendingQueue.removeAll()
            }

            let remoteItems = try await pull()
            status = .success(Date())
            return .success(remoteItems)
        } catch {
            status = .failed(error.localizedDescription)
            return .failure(error)
        }
    }
}
