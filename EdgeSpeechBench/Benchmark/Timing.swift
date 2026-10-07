import Foundation

nonisolated enum BenchmarkTiming {
    static func seconds(_ duration: Duration) -> Double {
        let parts = duration.components
        return Double(parts.seconds) + Double(parts.attoseconds) / 1e18
    }
    static func measure<T: Sendable>(_ operation: () async throws -> T) async rethrows -> (T, Double) {
        let clock = ContinuousClock()
        let start = clock.now
        let value = try await operation()
        return (value, seconds(start.duration(to: clock.now)))
    }
}

nonisolated struct ColdMeasurement: Sendable {
    let load: Double
    let initialization: Double
    let firstInference: Double
    let total: Double
    let result: InferenceResult
    static func execute(model: any SpeechModel, audio: PreparedAudio) async throws -> Self {
        let clock = ContinuousClock()
        let start = clock.now
        let (_, load) = try await BenchmarkTiming.measure { try await model.load() }
        try Task.checkCancellation()
        let (_, initialization) = try await BenchmarkTiming.measure { try await model.initialize(audio: audio) }
        let (result, inference) = try await BenchmarkTiming.measure { try await model.transcribe(audio: audio) }
        return Self(load: load, initialization: initialization, firstInference: inference,
                    total: BenchmarkTiming.seconds(start.duration(to: clock.now)), result: result)
    }
}
