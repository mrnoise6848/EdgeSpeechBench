import Foundation

nonisolated enum BenchmarkExport {
    static func json(_ run: BenchmarkRun) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(run)
    }
    static func csv(_ run: BenchmarkRun) -> Data {
        let header = ["run_id", "timestamp", "model", "model_version", "device", "os", "app_build", "simulator", "sample", "sha256", "audio_seconds", "sample_rate", "channels", "warmups", "measured_runs", "load_seconds", "initialization_seconds", "first_inference_seconds", "cold_total_seconds", "warm_median_seconds", "warm_mean_seconds", "warm_p95_seconds", "warm_stddev_seconds", "rtf", "app_before_bytes", "app_sampled_peak_bytes", "app_after_bytes", "backend", "compute_configuration", "thermal_start", "thermal_end", "wer", "warm_times_seconds"]
        let fields = [run.id.uuidString, run.timestamp.ISO8601Format(), run.model.name, run.model.version ?? "Not available", run.device.hardware, run.device.os, run.device.appVersion, String(run.device.isSimulator), run.sampleName, run.sampleFingerprint, String(run.audioDuration), String(run.normalizedSampleRate), String(run.normalizedChannels), String(run.configuration.warmupRuns), String(run.warmTimes.count), String(run.loadTime), String(run.initializationTime), String(run.firstInferenceTime), String(run.coldStartTime), number(run.summary.median), number(run.summary.average), number(run.summary.p95), number(run.summary.standardDeviation), number(run.realTimeFactor), run.memory.beforeLoadBytes.map(String.init) ?? "", run.memory.sampledPeakBytes.map(String.init) ?? "", run.memory.afterInferenceBytes.map(String.init) ?? "", run.model.backend, run.model.computeConfiguration, run.thermalStart, run.thermalEnd, number(run.wordErrorRate), run.warmTimes.map { String($0) }.joined(separator: ";")]
        return Data((header.map(escape).joined(separator: ",") + "\r\n" + fields.map(escape).joined(separator: ",") + "\r\n").utf8)
    }
    private static func number(_ value: Double?) -> String { value.map { String($0) } ?? "" }
    static func escape(_ value: String) -> String {
        var safe = value
        if let first = safe.first, "=+-@\t\r\n".contains(first) { safe = "'" + safe }
        return "\"" + safe.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
