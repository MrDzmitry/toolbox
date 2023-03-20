import Foundation

// Start a new Task with a timeout. If the timeout expires before the operation is
// completed then the task is cancelled and an error is thrown.
extension Task where Failure == Error {
    public static func detached(priority: TaskPriority? = nil, timeout: TimeInterval, operation: @escaping @Sendable () async throws -> Success) -> Task<Success, Failure> {
        return Task.detached(priority: priority, operation: {
            return try await Task.run(operation: operation, withTimeout: timeout)
        })
    }
        
    public init(priority: TaskPriority? = nil, timeout: TimeInterval, operation: @escaping @Sendable () async throws -> Success) {
        self.init(priority: priority) {
            return try await Task.run(operation: operation, withTimeout: timeout)
        }
    }
                
    private static func run(operation: @escaping @Sendable () async throws -> Success, withTimeout timeout: TimeInterval) async throws -> Success {
        return try await withUnsafeThrowingContinuation({ (continuation: UnsafeContinuation<Success, Error>) in
            let timeoutActor = TimeoutActor()
            
            Task<Void, Never> {
                do {
                    let operationResult = try await operation()
                    if await timeoutActor.markCompleted() {
                        continuation.resume(returning: operationResult)
                    }
                }
                catch {
                    if await timeoutActor.markCompleted() {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            Task<Void, Never> {
                do {
                    try await _Concurrency.Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000_000)
                    if await timeoutActor.markCompleted() {
                        continuation.resume(throwing: TaskTimeoutError())
                    }
                }
                catch {
                    if await timeoutActor.markCompleted() {
                        continuation.resume(throwing: error)
                    }
                }
            }
        })
    }
}

public struct TaskTimeoutError: LocalizedError {
    public var errorDescription: String? = "Task timed out before completion"
}

fileprivate actor TimeoutActor {
    private var isCompleted = false
    
    func markCompleted() -> Bool {
        if self.isCompleted {
            return false
        }
        
        self.isCompleted = true
        return true
    }
}
