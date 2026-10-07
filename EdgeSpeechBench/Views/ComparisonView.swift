import SwiftUI

struct ComparisonView: View {
    let comparison: PerformanceComparison
    var body: some View {
        List {
            Section("Measured comparison") {
                Text(comparison.interpretation)
                ForEach([comparison.lhs, comparison.rhs]) { run in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(run.model.name).font(.headline)
                        Text(run.timestamp.formatted()).font(.caption)
                        Text("Warm median: \(run.summary.median.map { String(format: "%.3f s", $0) } ?? "Not available")")
                        Text("RTF: \(run.realTimeFactor.map { String(format: "%.3fx", $0) } ?? "Not available")")
                        Text("Sampled peak app memory: \(run.memory.sampledPeakBytes.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) } ?? "Not available")")
                    }
                }
            }
            Section("Comparability notes") {
                if comparison.mismatches.isEmpty { Text("Recorded conditions match.") }
                ForEach(comparison.mismatches, id: \.self) { Text($0) }
            }
        }.navigationTitle("Compare")
    }
}
