import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BenchmarkRunRecord.timestamp, order: .reverse) private var records: [BenchmarkRunRecord]
    @State private var selected: Set<UUID> = []
    @State private var errorMessage: String?
    var body: some View {
        List {
            if records.isEmpty { ContentUnavailableView("No benchmarks yet", systemImage: "clock", description: Text("Run a benchmark to save real measurements.")) }
            ForEach(records) { record in
                HStack {
                    Button {
                        if selected.contains(record.runID) { selected.remove(record.runID) }
                        else if selected.count < 2 { selected.insert(record.runID) }
                    } label: {
                        Image(systemName: selected.contains(record.runID) ? "checkmark.circle.fill" : "circle")
                    }.buttonStyle(.borderless).accessibilityLabel("Select \(record.modelName) for comparison")
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(record.modelName).font(.headline)
                            Text(record.sampleName).font(.subheadline)
                            Text(record.timestamp.formatted()).font(.caption).foregroundStyle(.secondary)
                            if let run = try? record.decode(), let rtf = run.realTimeFactor {
                                Text(String(format: "RTF %.3fx • %@", rtf, run.device.hardware)).font(.caption.monospaced())
                            }
                        }
                    }
                }
            }.onDelete { offsets in
                do {
                    let deleted = offsets.map { records[$0] }
                    try BenchmarkStore.delete(deleted, in: context)
                    selected.subtract(deleted.map(\.runID))
                } catch { errorMessage = error.localizedDescription }
            }
        }
        .navigationTitle("Benchmark History")
        .toolbar {
            EditButton()
            if selected.count == 2 {
                NavigationLink("Compare") {
                    let pair = records.filter { selected.contains($0.runID) }
                    if pair.count == 2, let a = try? pair[0].decode(), let b = try? pair[1].decode() {
                        ComparisonView(comparison: PerformanceComparison(lhs: a, rhs: b))
                    } else { Text("Stored result could not be decoded.") }
                }
            }
        }
        .alert("Storage error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

struct RecordDetailView: View {
    let record: BenchmarkRunRecord
    var body: some View {
        if let run = try? record.decode() { ResultDetailView(run: run) }
        else { ContentUnavailableView("Result unavailable", systemImage: "exclamationmark.triangle", description: Text("The stored payload is corrupt or uses an unsupported schema.")) }
    }
}

