import SwiftUI
import UniformTypeIdentifiers

nonisolated enum MetricFormat {
    static func seconds(_ value: Double?) -> String { value.map { String(format: "%.3f s", $0) } ?? "Not available" }
    static func bytes(_ value: UInt64?) -> String {
        value.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) } ?? "Not available"
    }
}

struct ResultDetailView: View {
    let run: BenchmarkRun
    @State private var exporting = false
    @State private var document = ExportDocument()
    @State private var contentType: UTType = .json
    @State private var exportError: String?
    private func prepareExport(csv: Bool) {
        do {
            document = ExportDocument(data: csv ? BenchmarkExport.csv(run) : try BenchmarkExport.json(run))
            contentType = csv ? .commaSeparatedText : .json
            exporting = true
        } catch { exportError = error.localizedDescription }
    }
    var body: some View {
        List {
            Section("Model") { ModelMetadataView(metadata: run.model) }
            Section("Context") {
                LabeledContent("Device", value: run.device.hardware)
                LabeledContent("OS", value: run.device.os)
                LabeledContent("App build", value: run.device.appVersion)
                LabeledContent("Environment", value: run.device.isSimulator ? "Simulator — not iPhone measurements" : "Physical device")
                LabeledContent("Audio", value: run.sampleName)
                LabeledContent("Duration", value: MetricFormat.seconds(run.audioDuration))
                LabeledContent("PCM", value: "\(Int(run.normalizedSampleRate)) Hz • \(run.normalizedChannels) channel • Float32")
            }
            Section("Provider cold start") {
                LabeledContent("Load / session construction", value: MetricFormat.seconds(run.loadTime))
                LabeledContent("Runtime initialization", value: MetricFormat.seconds(run.initializationTime))
                LabeledContent("First inference", value: MetricFormat.seconds(run.firstInferenceTime))
                LabeledContent("Total provider cold", value: MetricFormat.seconds(run.coldStartTime))
                Text("Fresh provider; system model caches may already be warm.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Measured warm sessions") {
                LabeledContent("Warmups excluded", value: "\(run.configuration.warmupRuns)")
                LabeledContent("Measured runs", value: "\(run.warmTimes.count)")
                LabeledContent("Median", value: MetricFormat.seconds(run.summary.median))
                LabeledContent("Mean", value: MetricFormat.seconds(run.summary.average))
                LabeledContent("p95 (nearest rank)", value: MetricFormat.seconds(run.summary.p95))
                LabeledContent("Minimum", value: MetricFormat.seconds(run.summary.minimum))
                LabeledContent("Maximum", value: MetricFormat.seconds(run.summary.maximum))
                LabeledContent("Sample standard deviation", value: MetricFormat.seconds(run.summary.standardDeviation))
                LabeledContent("Total warm time", value: MetricFormat.seconds(run.summary.total))
                LabeledContent("RTF (median / audio)", value: run.realTimeFactor.map { String(format: "%.3fx", $0) } ?? "Not available")
                Text(RealTimeFactor.interpretation(run.realTimeFactor))
                ForEach(Array(run.warmTimes.enumerated()), id: \.offset) { index, time in
                    LabeledContent("Run \(index + 1)", value: MetricFormat.seconds(time))
                }
            }
            Section("App memory") {
                LabeledContent("Before load", value: MetricFormat.bytes(run.memory.beforeLoadBytes))
                LabeledContent("Sampled peak app footprint", value: MetricFormat.bytes(run.memory.sampledPeakBytes))
                LabeledContent("After inference", value: MetricFormat.bytes(run.memory.afterInferenceBytes))
                LabeledContent("Delta bytes", value: run.memory.deltaBytes.map(String.init) ?? "Not available")
                Text("100 ms sampling may miss brief peaks. System speech-service memory is excluded; this is not model-only memory.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Thermal / repeatability") {
                LabeledContent("Thermal start", value: run.thermalStart)
                LabeledContent("Thermal end", value: run.thermalEnd)
                Text(ThermalContext.repeatedRunNote(run.warmTimes)).font(.caption)
            }
            Section("Illustrative accuracy") {
                LabeledContent("WER (last measured transcript)", value: run.wordErrorRate.map { String(format: "%.2f%%", $0 * 100) } ?? "Not available")
                Text("Lowercase alphanumeric words; punctuation splits words. One fixed excerpt is not a production accuracy evaluation.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Execution") { ComputeConfigurationView(model: run.model) }
            Section("Readable report") {
                Text(BenchmarkReport.text(run)).font(.caption.monospaced()).textSelection(.enabled)
            }
            Section("Methodology") {
                Text("Normalization and model download are excluded. Warm timings include new analyzer session preparation, file decoding, inference and final result collection. Runs are sequential; warmups are excluded. Small-run p95 is only descriptive.")
                Text("SHA-256: \(run.sampleFingerprint)").font(.caption.monospaced()).textSelection(.enabled)
                Text(run.timestamp.formatted()).font(.caption)
            }
        }.navigationTitle("Benchmark Result")
        .toolbar {
            Menu("Export") {
                Button("JSON report") { prepareExport(csv: false) }
                Button("CSV report") { prepareExport(csv: true) }
                Button("Text report") {
                    document = ExportDocument(data: Data(BenchmarkReport.text(run).utf8))
                    contentType = .plainText
                    exporting = true
                }
            }
        }
        .fileExporter(isPresented: $exporting, document: document, contentType: contentType,
                      defaultFilename: "EdgeSpeechBench-\(run.id.uuidString)") { outcome in
            if case .failure(let error) = outcome { exportError = error.localizedDescription }
        }
        .alert("Export failed", isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
            Button("OK") { exportError = nil }
        } message: { Text(exportError ?? "") }
    }
}
