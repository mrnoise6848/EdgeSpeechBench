import Foundation
import Speech
import AVFoundation

actor AppleSpeechModel: SpeechModel {
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var format: AVAudioFormat?
    private let alternatives: Bool
    init(alternatives: Bool = false) { self.alternatives = alternatives }

    private func makeTranscriber() -> SpeechTranscriber {
        SpeechTranscriber(locale: Locale(identifier: "en-US"),
                          preset: alternatives ? .transcriptionWithAlternatives : .transcription)
    }
    func requiredSampleRate() async throws -> Double {
        guard SpeechTranscriber.isAvailable,
              await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: "en-US")) != nil else {
            throw BenchmarkError.modelUnavailable("This device does not support English SpeechTranscriber.")
        }
        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [makeTranscriber()]) else {
            throw BenchmarkError.modelUnavailable("No compatible audio format.")
        }
        return format.sampleRate
    }
    func installAssets() async throws {
        _ = try await requiredSampleRate()
        let module = makeTranscriber()
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
            try await request.downloadAndInstall()
        }
    }
    func load() async throws {
        let module = makeTranscriber()
        guard await AssetInventory.status(forModules: [module]) == .installed else {
            throw BenchmarkError.modelUnavailable("Install English model assets before benchmarking.")
        }
        transcriber = module
        analyzer = SpeechAnalyzer(modules: [module], options: .init(priority: .userInitiated, modelRetention: .lingering))
    }
    func initialize(audio: PreparedAudio) async throws {
        guard let analyzer else { throw BenchmarkError.notLoaded }
        let file = try AVAudioFile(forReading: audio.url)
        format = file.processingFormat
        try await analyzer.prepareToAnalyze(in: format)
    }
    func transcribe(audio: PreparedAudio) async throws -> InferenceResult {
        guard format != nil else { throw BenchmarkError.notLoaded }
        // Finished analysis sessions cannot be restarted. Retain model residency via .lingering.
        if analyzer == nil {
            let module = makeTranscriber()
            transcriber = module
            analyzer = SpeechAnalyzer(modules: [module], options: .init(priority: .userInitiated, modelRetention: .lingering))
            try await analyzer?.prepareToAnalyze(in: format)
        }
        guard let analyzer, let transcriber else { throw BenchmarkError.notLoaded }
        let results = transcriber.results
        let collector = Task {
            var text = ""
            for try await result in results {
                try Task.checkCancellation()
                text += String(result.text.characters)
            }
            return text
        }
        do {
            let file = try AVAudioFile(forReading: audio.url)
            return try await withTaskCancellationHandler {
                _ = try await analyzer.analyzeSequence(from: file)
                try await analyzer.finalizeAndFinishThroughEndOfInput()
                let text = try await collector.value
                self.analyzer = nil
                self.transcriber = nil
                return InferenceResult(transcript: text)
            } onCancel: {
                collector.cancel()
                Task { await analyzer.cancelAndFinishNow() }
            }
        } catch {
            collector.cancel()
            await analyzer.cancelAndFinishNow()
            self.analyzer = nil
            self.transcriber = nil
            throw error
        }
    }
    func metadata() async -> ModelMetadata {
        ModelMetadata(name: alternatives ? "Apple SpeechTranscriber (alternatives)" : "Apple SpeechTranscriber",
                      version: nil, sizeBytes: nil, language: "en-US", backend: "SpeechAnalyzer",
                      computeConfiguration: "System managed; hardware execution unavailable",
                      inputFormat: "Mono Float32 PCM at runtime-selected rate")
    }
    func unload() async {
        await analyzer?.cancelAndFinishNow()
        analyzer = nil
        transcriber = nil
        format = nil
    }
}
