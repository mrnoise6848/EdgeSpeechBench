import Foundation

nonisolated struct WarmMeasurement: Sendable {
    let times: [Double]
    let lastResult: InferenceResult
    static func execute(model: any SpeechModel, audio: PreparedAudio, repetitions: Int, timeout: Double,
                        progress: @Sendable (Int) async -> Void) async throws -> Self {
        var times: [Double] = []
        times.reserveCapacity(repetitions)
        var result = InferenceResult(transcript: "")
        for index in 0..<repetitions {
            try Task.checkCancellation()
            try ThermalContext.checkResources()
            await progress(index + 1)
            let measured = try await BenchmarkTiming.measure { try await InferenceDeadline.run(seconds: timeout) { try await model.transcribe(audio: audio) } }
            result = measured.0
            times.append(measured.1)
        }
        return Self(times: times, lastResult: result)
    }
}

extension BenchmarkSummary {
    nonisolated var minimum: Double? { values.min() }
    nonisolated var maximum: Double? { values.max() }
    nonisolated var total: Double { values.reduce(0, +) }
    // Nearest-rank percentile, deliberately labelled for small samples.
    nonisolated var p95: Double? {
        guard !values.isEmpty else { return nil }
        return sorted[max(0, Int(ceil(Double(values.count) * 0.95)) - 1)]
    }
}
