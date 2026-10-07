import Foundation

nonisolated enum RealTimeFactor {
    static func calculate(inference: Double, audio: Double) -> Double? {
        guard inference.isFinite, audio.isFinite, inference >= 0, audio > 0 else { return nil }
        return inference / audio
    }
    static func interpretation(_ factor: Double?) -> String {
        guard let factor, factor.isFinite else { return "Not available" }
        if factor < 1 { return "Faster than realtime" }
        if factor > 1 { return "Slower than realtime" }
        return "Realtime"
    }
}
