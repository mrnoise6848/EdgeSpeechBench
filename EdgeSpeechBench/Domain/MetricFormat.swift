import Foundation

nonisolated enum MetricFormat {
    static func seconds(_ value: Double?) -> String { value.map { String(format: "%.3f s", $0) } ?? "Not available" }
    static func bytes(_ value: UInt64?) -> String {
        value.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) } ?? "Not available"
    }
}

