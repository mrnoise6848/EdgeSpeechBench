import Foundation
import Observation

@MainActor @Observable
final class BenchmarkViewModel {
    var choice: ModelChoice = .standard
    var samples = AudioCatalog.bundled()
    var selectedSampleID = "jfk"
    var configuration = BenchmarkConfiguration()
    var status = "Ready"
    var isRunning = false
    var errorMessage: String?
    var result: BenchmarkRun?
    var metadata: ModelMetadata?
    private let runner = BenchmarkRunner()
    private let importer = AudioImporter()
    private var task: Task<Void, Never>?
    var selectedSample: AudioSample? { samples.first { $0.id == selectedSampleID } }
    func refreshMetadata() async { metadata = await choice.makeProvider().metadata() }
    func start() {
        guard !isRunning, let sample = selectedSample else { return }
        let provider = choice.makeProvider()
        let configuration = configuration
        let device = DeviceInformation.capture()
        isRunning = true
        result = nil
        errorMessage = nil
        task = Task { [weak self] in
            guard let self else { return }
            defer { self.isRunning = false; self.task = nil }
            do {
                let run = try await self.runner.run(model: provider, sample: sample, configuration: configuration,
                                                     device: device) { [weak self] progress in
                    await self?.update(progress)
                }
                self.result = run
                self.status = "Completed"
            } catch is CancellationError { self.status = "Cancelled" }
            catch {
                if Task.isCancelled { self.status = "Cancelled" }
                else { self.status = "Benchmark failed"; self.errorMessage = error.localizedDescription }
            }
        }
    }
    private func update(_ progress: BenchmarkProgress) { status = progress.label }
    func cancel() { task?.cancel(); status = "Cancelling…" }
    func installAssets() {
        guard !isRunning else { return }
        let provider = choice.makeProvider()
        isRunning = true
        status = "Installing English model assets (outside benchmark)"
        task = Task { [weak self] in
            guard let self else { return }
            defer { self.isRunning = false; self.task = nil }
            do { try await provider.installAssets(); self.status = "Model assets ready" }
            catch is CancellationError { self.status = "Cancelled" }
            catch { self.status = "Installation failed"; self.errorMessage = error.localizedDescription }
        }
    }
    func importAudio(_ url: URL) async {
        guard !isRunning else { return }
        do {
            let sample = try await importer.importFile(url)
            samples.append(sample)
            selectedSampleID = sample.id
        } catch { errorMessage = error.localizedDescription }
    }
}
