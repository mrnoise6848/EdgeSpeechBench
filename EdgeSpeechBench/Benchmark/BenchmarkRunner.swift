import Foundation

nonisolated enum BenchmarkProgress: Sendable, Equatable {
    case normalizing, cold, warmup(Int, Int), measured(Int, Int), cleaning
    var label: String {
        switch self {
        case .normalizing: "Normalizing audio"
        case .cold: "Provider cold: load, initialize, first inference"
        case .warmup(let index, let count): "Warmup \(index) / \(count)"
        case .measured(let index, let count): "Measured inference \(index) / \(count)"
        case .cleaning: "Releasing benchmark resources"
        }
    }
}

actor BenchmarkRunner {
    private let normalizer = AudioNormalizer()
    private var running = false
    func run(model: any SpeechModel, sample: AudioSample, configuration: BenchmarkConfiguration,
             device: DeviceContext, progress: @Sendable (BenchmarkProgress) async -> Void) async throws -> BenchmarkRun {
        guard !running else { throw BenchmarkError.invalidConfiguration }
        try configuration.validate()
        try ThermalContext.checkResources()
        running = true
        defer { running = false }
        let memory = MemorySampler()
        do {
            await progress(.normalizing)
            let rate = try await model.requiredSampleRate()
            let audio = try await normalizer.prepare(sample, sampleRate: rate)
            try Task.checkCancellation()
            let metadata = await model.metadata()
            let thermalStart = ThermalContext.state()
            let baseline = MemorySampler.footprint()
            await memory.start()
            await progress(.cold)
            let cold = try await ColdMeasurement.execute(model: model, audio: audio, timeout: configuration.timeoutSeconds)
            for index in 0..<configuration.warmupRuns {
                try Task.checkCancellation()
                await progress(.warmup(index + 1, configuration.warmupRuns))
                try ThermalContext.checkResources()
                _ = try await InferenceDeadline.run(seconds: configuration.timeoutSeconds) { try await model.transcribe(audio: audio) }
            }
            let warm = try await WarmMeasurement.execute(model: model, audio: audio,
                                                        repetitions: configuration.measuredRuns, timeout: configuration.timeoutSeconds) { index in
                await progress(.measured(index, configuration.measuredRuns))
            }
            let after = MemorySampler.footprint()
            let peak = await memory.stop()
            await progress(.cleaning)
            await model.unload()
            try Task.checkCancellation()
            return BenchmarkRun(id: UUID(), timestamp: Date(), model: metadata,
                                sampleName: sample.name, sampleFingerprint: audio.fingerprint,
                                audioDuration: audio.duration, normalizedSampleRate: audio.sampleRate,
                                normalizedChannels: audio.channels, configuration: configuration, device: device,
                                loadTime: cold.load, initializationTime: cold.initialization,
                                firstInferenceTime: cold.firstInference, coldStartTime: cold.total,
                                warmTimes: warm.times,
                                memory: MemoryMetrics(beforeLoadBytes: baseline, sampledPeakBytes: peak, afterInferenceBytes: after),
                                thermalStart: thermalStart, thermalEnd: ThermalContext.state(),
                                wordErrorRate: WordErrorRate.calculate(reference: sample.reference, hypothesis: warm.lastResult.transcript), success: true, error: nil)
        } catch {
            _ = await memory.stop()
            await model.unload()
            throw error
        }
    }
}
