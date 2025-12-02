import Foundation
import Combine

// MARK: - Publisher Extensions
extension Publisher {
    func withLatestFrom<Other: Publisher>(_ other: Other) -> AnyPublisher<Other.Output, Self.Failure> where Other.Failure == Self.Failure {
        let upstream = self
        return other
            .map { second in
                upstream.map { _ in second }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
