import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var model = BenchmarkViewModel()
    @State private var importing = false
    @State private var storageError: String?
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("How fast does speech AI run on this device?").font(.headline)
                    Text("Local inference • measured performance • reproducible audio").font(.caption).foregroundStyle(.secondary)
                }
                Section("Configuration") {
                    Picker("Model preset", selection: $model.choice) {
                        ForEach(ModelChoice.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Audio sample", selection: $model.selectedSampleID) {
                        ForEach(model.samples) { Text($0.name).tag($0.id) }
                    }
                    Button("Import local audio") { importing = true }
                    Stepper("Warmups: \(model.configuration.warmupRuns)", value: $model.configuration.warmupRuns, in: 0...5)
                    Stepper("Measured runs: \(model.configuration.measuredRuns)", value: $model.configuration.measuredRuns, in: 2...20)
                }.disabled(model.isRunning)
                Section("Run") {
                    Text(model.status).accessibilityIdentifier("benchmarkStatus")
                    if model.isRunning {
                        Button("Cancel benchmark", role: .destructive) { model.cancel() }
                    } else {
                        Button("Run Benchmark") { model.start() }
                            .disabled(model.selectedSample == nil).accessibilityIdentifier("runBenchmark")
                        Button("Install English model assets") { model.installAssets() }
                    }
                    Text("Asset installation may download Apple's model. Benchmarking requires installed assets and runs locally.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if let result = model.result {
                    Section("Latest result") {
                        LabeledContent("RTF", value: result.realTimeFactor.map { String(format: "%.3fx", $0) } ?? "Not available")
                        LabeledContent("Warm median", value: result.summary.median.map { String(format: "%.3f s", $0) } ?? "Not available")
                        NavigationLink("View result and report") { ResultDetailView(run: result) }
                    }
                }
                Section {
                    NavigationLink("Benchmark History") { HistoryView() }
                        .disabled(model.isRunning)
                }
                if let metadata = model.metadata {
                    Section("Model information") { ModelMetadataView(metadata: metadata) }
                }
            }
            .navigationTitle("EdgeSpeechBench")
            .task(id: model.choice) { await model.refreshMetadata() }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.audio]) { outcome in
                switch outcome {
                case .success(let url): Task { await model.importAudio(url) }
                case .failure(let error): model.errorMessage = error.localizedDescription
                }
            }
            .onChange(of: model.result?.id) {
                guard let run = model.result else { return }
                do { try BenchmarkStore.save(run, in: context) }
                catch { storageError = "Measurements are available, but saving failed: \(error.localizedDescription)" }
            }
            .alert("Operation failed", isPresented: Binding(get: { model.errorMessage != nil || storageError != nil }, set: {
                if !$0 { model.errorMessage = nil; storageError = nil }
            })) {
                Button("OK") { model.errorMessage = nil; storageError = nil }
            } message: { Text(storageError ?? model.errorMessage ?? "") }
        }
    }
}

#Preview {
    ContentView().modelContainer(for: [Item.self, BenchmarkRunRecord.self], inMemory: true)
}
