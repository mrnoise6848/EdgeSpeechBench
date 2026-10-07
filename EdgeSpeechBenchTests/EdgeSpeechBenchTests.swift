import XCTest
import SwiftData
import Speech
@testable import EdgeSpeechBench

actor FixtureModel: SpeechModel {
    var calls = 0
    var unloaded = false
    var delay: Double
    init(delay: Double = 0.001) { self.delay = delay }
    func requiredSampleRate() async throws -> Double { 16000 }
    func load() async throws {}
    func initialize(audio: PreparedAudio) async throws {}
    func transcribe(audio: PreparedAudio) async throws -> InferenceResult {
        calls += 1
        try await Task.sleep(for: .seconds(delay))
        return InferenceResult(transcript: AudioCatalog.reference)
    }
    func unload() async { unloaded = true }
    func metadata() async -> ModelMetadata {
        ModelMetadata(name: "Test provider", version: "test", sizeBytes: nil, language: "en-US",
                      backend: "Test only", computeConfiguration: "Test only", inputFormat: "Float32")
    }
}

@MainActor
final class EdgeSpeechBenchTests: XCTestCase {
    func testStatisticsAndRTF() throws {
        let values = BenchmarkSummary(values: [4, 1, 2, 3])
        XCTAssertEqual(values.median, 2.5)
        XCTAssertEqual(values.average, 2.5)
        XCTAssertEqual(values.p95, 4)
        XCTAssertEqual(try XCTUnwrap(values.standardDeviation), sqrt(5.0 / 3.0), accuracy: 1e-10)
        XCTAssertNil(BenchmarkSummary(values: []).median)
        XCTAssertEqual(RealTimeFactor.calculate(inference: 3, audio: 10), 0.3)
        XCTAssertNil(RealTimeFactor.calculate(inference: 1, audio: 0))
        XCTAssertNil(RealTimeFactor.calculate(inference: .nan, audio: 10))
    }
    func testWERAndCSVEscaping() {
        XCTAssertEqual(WordErrorRate.calculate(reference: "One, two three!", hypothesis: "one four three"), 1.0 / 3.0)
        XCTAssertEqual(WordErrorRate.calculate(reference: "a", hypothesis: "a b c"), 2)
        XCTAssertNil(WordErrorRate.calculate(reference: nil, hypothesis: "a"))
        XCTAssertEqual(BenchmarkExport.escape("=formula"), "\"'=formula\"")
        XCTAssertEqual(BenchmarkExport.escape("a,\"b\""), "\"a,\"\"b\"\"\"")
    }
    func testRunnerNormalizationPersistenceAndExport() async throws {
        var stage = "load fixtures"
        do {
            let samples = AudioCatalog.bundled()
            XCTAssertEqual(samples.count, 3)
            let sample = try XCTUnwrap(samples.first)
            let normalizer = AudioNormalizer()
            stage = "normalize first input"
            let first = try await normalizer.prepare(sample, sampleRate: 16000)
            stage = "reuse normalized cache"
            let second = try await normalizer.prepare(sample, sampleRate: 16000)
            XCTAssertEqual(first.url, second.url)
            XCTAssertEqual(first.duration, 11, accuracy: 0.02)
            XCTAssertEqual(first.channels, 1)
            let model = FixtureModel()
            let config = BenchmarkConfiguration(warmupRuns: 1, measuredRuns: 3, timeoutSeconds: 10)
            var progressEvents: [BenchmarkProgress] = []
            stage = "run benchmark harness"
            let run = try await BenchmarkRunner().run(model: model, sample: sample, configuration: config,
                                                      device: DeviceInformation.capture()) { event in
                await MainActor.run { progressEvents.append(event) }
            }
            let calls = await model.calls
            let unloaded = await model.unloaded
            XCTAssertEqual(calls, 5) // one cold + one excluded warmup + three measured
            XCTAssertTrue(unloaded)
            XCTAssertEqual(run.warmTimes.count, 3)
            XCTAssertTrue(run.warmTimes.allSatisfy { $0 > 0 })
            XCTAssertEqual(run.wordErrorRate, 0)
            XCTAssertTrue(progressEvents.contains(.warmup(1, 1)))
            XCTAssertTrue(progressEvents.contains(.measured(3, 3)))
            let schema = Schema([Item.self, BenchmarkRunRecord.self])
            stage = "create in-memory SwiftData container"
            let storage = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)])
            let context = ModelContext(storage)
            stage = "save SwiftData record"
            try BenchmarkStore.save(run, in: context)
            let records = try context.fetch(FetchDescriptor<BenchmarkRunRecord>())
            XCTAssertEqual(records.count, 1)
            XCTAssertEqual(try records[0].decode().id, run.id)
            XCTAssertTrue(PerformanceComparison(lhs: run, rhs: run).mismatches.isEmpty)
            stage = "export JSON"
            let exported = try XCTUnwrap(JSONSerialization.jsonObject(with: BenchmarkExport.json(run)) as? [String: Any])
            XCTAssertNil(exported["transcript"])
            XCTAssertNil(exported["url"])
            XCTAssertNotNil(exported["warmTimes"])
            XCTAssertTrue(String(decoding: BenchmarkExport.csv(run), as: UTF8.self).contains("sha256"))
            stage = "delete SwiftData record"
            try BenchmarkStore.delete(records, in: context)
            XCTAssertEqual(try context.fetchCount(FetchDescriptor<BenchmarkRunRecord>()), 0)
        } catch { XCTFail("\(stage): \(error)") }
    }
    func testCancellationCleanupAndInvalidAudio() async throws {
        let sample = try XCTUnwrap(AudioCatalog.bundled().first)
        let model = FixtureModel(delay: 30)
        let task = Task {
            try await BenchmarkRunner().run(model: model, sample: sample, configuration: BenchmarkConfiguration(),
                                             device: DeviceInformation.capture()) { _ in }
        }
        for _ in 0..<500 {
            if await model.calls > 0 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let started = await model.calls
        XCTAssertGreaterThan(started, 0, "Cancellation must reach active inference")
        task.cancel()
        do { _ = try await task.value; XCTFail("Cancelled run succeeded") } catch {}
        let unloaded = await model.unloaded
        XCTAssertTrue(unloaded)
        let bad = AudioSample(id: "missing", name: "Missing", url: URL(filePath: "/nonexistent/audio.wav"), reference: nil, source: "Test")
        do { _ = try await AudioNormalizer().prepare(bad, sampleRate: 16000); XCTFail("Invalid audio accepted") } catch {}
    }
    func testDeadlineAndInvalidConfiguration() async throws {
        do {
            _ = try await InferenceDeadline.run(seconds: 0.01) { try await Task.sleep(for: .seconds(30)); return 1 }
            XCTFail("Deadline not enforced")
        } catch BenchmarkError.timedOut {} catch { XCTFail("Unexpected error: \(error)") }
        XCTAssertThrowsError(try BenchmarkConfiguration(warmupRuns: -1).validate())
    }
    func testRealModelWhenInstalled() async throws {
        guard SpeechTranscriber.isAvailable else { throw XCTSkip("SpeechTranscriber unavailable on this runtime") }
        let module = SpeechTranscriber(locale: Locale(identifier: "en-US"), preset: .transcription)
        guard await AssetInventory.status(forModules: [module]) == .installed else {
            throw XCTSkip("Install English assets on a compatible physical device; tests never download assets")
        }
        let model = AppleSpeechModel()
        let sample = try XCTUnwrap(AudioCatalog.bundled().first)
        let run = try await BenchmarkRunner().run(model: model, sample: sample,
                                                 configuration: BenchmarkConfiguration(warmupRuns: 1, measuredRuns: 2),
                                                 device: DeviceInformation.capture()) { _ in }
        XCTAssertTrue(run.success)
        XCTAssertNotNil(run.realTimeFactor)
        XCTAssertEqual(run.warmTimes.count, 2)
    }
}
