import SwiftUI

nonisolated enum MetricFormat {
    static func seconds(_ value: Double?) -> String { value.map { String(format: "%.3f s", $0) } ?? "Not available" }
    static func bytes(_ value: UInt64?) -> String {
        value.map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .memory) } ?? "Not available"
    }
}

struct ResultDetailView: View {
    let run: BenchmarkRun
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
            Section("Execution") { ComputeConfigurationView(model: run.model) }
            Section("Methodology") {
                Text("Normalization and model download are excluded. Warm timings include new analyzer session preparation, file decoding, inference and final result collection. Runs are sequential; warmups are excluded. Small-run p95 is only descriptive.")
                Text("SHA-256: \(run.sampleFingerprint)").font(.caption.monospaced()).textSelection(.enabled)
                Text(run.timestamp.formatted()).font(.caption)
            }
        }.navigationTitle("Benchmark Result")
    }
}
