import Foundation

nonisolated enum BenchmarkReport {
    static func text(_ run: BenchmarkRun) -> String {
        """
        EdgeSpeechBench • measured benchmark report
        Run: \(run.id.uuidString)
        Date: \(run.timestamp.ISO8601Format())
        Model: \(run.model.name)
        Asset version: \(run.model.version ?? "Not available")
        Device: \(run.device.hardware)
        OS: \(run.device.os)
        App: \(run.device.appVersion)
        Environment: \(run.device.isSimulator ? "Simulator (not iPhone performance)" : "Physical device")
        Audio: \(run.sampleName), \(MetricFormat.seconds(run.audioDuration))
        Normalized PCM: \(run.normalizedSampleRate) Hz, \(run.normalizedChannels) channel(s), Float32
        Audio SHA-256: \(run.sampleFingerprint)
        Load: \(MetricFormat.seconds(run.loadTime))
        Initialization: \(MetricFormat.seconds(run.initializationTime))
        First inference: \(MetricFormat.seconds(run.firstInferenceTime))
        Provider cold total: \(MetricFormat.seconds(run.coldStartTime))
        Warmups excluded: \(run.configuration.warmupRuns)
        Measured warm runs: \(run.warmTimes.count)
        Warm median: \(MetricFormat.seconds(run.summary.median))
        Warm mean: \(MetricFormat.seconds(run.summary.average))
        p95 (nearest rank): \(MetricFormat.seconds(run.summary.p95))
        Sample standard deviation: \(MetricFormat.seconds(run.summary.standardDeviation))
        RTF: \(run.realTimeFactor.map { String(format: "%.4fx", $0) } ?? "Not available")
        Sampled peak app footprint: \(MetricFormat.bytes(run.memory.sampledPeakBytes))
        Configuration: \(run.model.computeConfiguration)
        Thermal: \(run.thermalStart) → \(run.thermalEnd)
        Repeatability: \(ThermalContext.repeatedRunNote(run.warmTimes))
        WER: \(run.wordErrorRate.map { String(format: "%.2f%%", $0 * 100) } ?? "Not available")

        Methodology: monotonic wall clock; one provider-cold session, excluded
        warmups, then sequential measured file sessions. Asset download and audio
        normalization are excluded. Warm sessions include analyzer preparation,
        file decoding and final result collection. RTF = warm median / audio duration.

        Limitations: system caches cannot be flushed; provider-cold is not guaranteed
        OS-cold. Small-sample p95 is descriptive. App memory is sampled every 100 ms;
        model/service memory and exact hardware placement are unavailable. System
        model asset versions are unavailable. Thermal states are coarse OS signals.
        WER is an illustrative fixture score, not production accuracy.
        """
    }
}
