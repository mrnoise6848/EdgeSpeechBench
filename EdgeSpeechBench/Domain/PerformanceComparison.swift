import Foundation

nonisolated struct PerformanceComparison: Sendable {
    let lhs: BenchmarkRun
    let rhs: BenchmarkRun
    var mismatches: [String] {
        var reasons: [String] = []
        if lhs.sampleFingerprint != rhs.sampleFingerprint { reasons.append("Different audio content") }
        if lhs.normalizedSampleRate != rhs.normalizedSampleRate || lhs.normalizedChannels != rhs.normalizedChannels {
            reasons.append("Different normalized audio format")
        }
        if lhs.device != rhs.device { reasons.append("Different device, OS, app build or simulator context") }
        if lhs.configuration != rhs.configuration { reasons.append("Different repetition, warmup or timeout configuration") }
        if lhs.thermalStart != rhs.thermalStart || lhs.thermalEnd != rhs.thermalEnd { reasons.append("Different thermal conditions") }
        if lhs.model.version == nil || rhs.model.version == nil { reasons.append("Model asset versions unavailable; equality cannot be verified") }
        return reasons
    }
    var medianDifference: Double? {
        guard let a = lhs.summary.median, let b = rhs.summary.median else { return nil }
        return a - b
    }
    var interpretation: String {
        guard lhs.success, rhs.success, let difference = medianDifference else { return "No successful measurements to compare." }
        if difference == 0 { return "Equal measured medians for these runs." }
        let name = difference < 0 ? lhs.model.name : rhs.model.name
        return "\(name) had the faster measured median for these runs. This is not a universal model ranking."
    }
}
