import Foundation

nonisolated struct BenchmarkConfiguration: Codable, Sendable, Equatable {
    var warmupRuns = 2
    var measuredRuns = 5
    var timeoutSeconds: Double = 120
    func validate() throws {
        guard (0...5).contains(warmupRuns), (2...20).contains(measuredRuns),
              timeoutSeconds.isFinite, (10...600).contains(timeoutSeconds) else {
            throw BenchmarkError.invalidConfiguration
        }
    }
}

nonisolated struct ModelMetadata: Codable, Sendable, Equatable {
    let name: String
    let version: String?
    let sizeBytes: Int64?
    let language: String
    let backend: String
    let computeConfiguration: String
    let inputFormat: String
}

nonisolated struct AudioSample: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let name: String
    let url: URL
    let reference: String?
    let source: String
}

nonisolated struct PreparedAudio: Sendable {
    let url: URL
    let duration: Double
    let sampleRate: Double
    let channels: UInt32
    let fingerprint: String
}

nonisolated struct InferenceResult: Sendable {
    let transcript: String
}

nonisolated struct MemoryMetrics: Codable, Sendable {
    var beforeLoadBytes: UInt64?
    var sampledPeakBytes: UInt64?
    var afterInferenceBytes: UInt64?
    var deltaBytes: Int64? {
        guard let beforeLoadBytes, let afterInferenceBytes else { return nil }
        return Int64(afterInferenceBytes) - Int64(beforeLoadBytes)
    }
}

nonisolated struct DeviceContext: Codable, Sendable, Equatable {
    let hardware: String
    let os: String
    let appVersion: String
    let isSimulator: Bool
}

nonisolated struct BenchmarkRun: Identifiable, Codable, Sendable {
    var schemaVersion = 1
    let id: UUID
    let timestamp: Date
    let model: ModelMetadata
    let sampleName: String
    let sampleFingerprint: String
    let audioDuration: Double
    let normalizedSampleRate: Double
    let normalizedChannels: UInt32
    let configuration: BenchmarkConfiguration
    let device: DeviceContext
    let loadTime: Double
    let initializationTime: Double
    let firstInferenceTime: Double
    let coldStartTime: Double
    let warmTimes: [Double]
    let memory: MemoryMetrics
    let thermalStart: String
    let thermalEnd: String
    let wordErrorRate: Double?
    let success: Bool
    let error: String?
    var summary: BenchmarkSummary { BenchmarkSummary(values: warmTimes) }
    var realTimeFactor: Double? {
        guard audioDuration > 0, let median = summary.median else { return nil }
        return RealTimeFactor.calculate(inference: median, audio: audioDuration)
    }
}

nonisolated enum BenchmarkError: LocalizedError, Sendable {
    case invalidConfiguration, invalidAudio(String), modelUnavailable(String), notLoaded, resourcePressure, timedOut
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: "Choose 2–20 measured runs, 0–5 warmups, and a 10–600 second timeout."
        case .invalidAudio(let reason): "Invalid audio: \(reason)"
        case .modelUnavailable(let reason): "Model unavailable: \(reason)"
        case .notLoaded: "Prepare the model before inference."
        case .timedOut: "The model operation exceeded its time limit. Try shorter audio or run again after releasing resources."
        case .resourcePressure: "Benchmark stopped because of resource or thermal pressure."
        }
    }
}

nonisolated struct BenchmarkSummary: Sendable {
    let values: [Double]
    var sorted: [Double] { values.sorted() }
    var average: Double? { values.isEmpty ? nil : values.reduce(0, +) / Double(values.count) }
    var median: Double? {
        let s = sorted
        guard !s.isEmpty else { return nil }
        return s.count.isMultiple(of: 2) ? (s[s.count / 2 - 1] + s[s.count / 2]) / 2 : s[s.count / 2]
    }
}
