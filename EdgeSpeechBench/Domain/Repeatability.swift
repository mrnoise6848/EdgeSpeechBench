import Foundation

extension BenchmarkSummary {
    nonisolated var standardDeviation: Double? {
        guard values.count >= 2, let mean = average else { return nil }
        return sqrt(values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count - 1))
    }
    nonisolated var coefficientOfVariation: Double? {
        guard let mean = average, mean > 0, let deviation = standardDeviation else { return nil }
        return deviation / mean
    }
}
