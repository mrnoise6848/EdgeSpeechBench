import Foundation

nonisolated enum ThermalContext {
    static func state() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: "Not available"
        }
    }
    static func checkResources() throws {
        guard ProcessInfo.processInfo.thermalState != .critical else { throw BenchmarkError.resourcePressure }
    }
    static func repeatedRunNote(_ times: [Double]) -> String {
        guard times.count >= 4 else { return "Too few runs to describe a repeated-run trend." }
        let split = times.count / 2
        let early = times.prefix(split).reduce(0, +) / Double(split)
        let late = times.suffix(times.count - split).reduce(0, +) / Double(times.count - split)
        guard early > 0 else { return "Trend unavailable." }
        if late > early * 1.2 {
            return "Later-session mean exceeded early-session mean by more than 20%. Cause is not established; this does not prove thermal throttling."
        }
        return "No increase above the descriptive 20% threshold between early and later session means."
    }
}
