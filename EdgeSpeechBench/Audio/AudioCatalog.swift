import Foundation
import AVFoundation

nonisolated enum AudioCatalog {
    static let reference = "And so my fellow Americans ask not what your country can do for you ask what you can do for your country"
    static func bundled(in bundle: Bundle = .main) -> [AudioSample] {
        [("jfk", "JFK • original", reference),
         ("jfk-repeated", "JFK • three repetitions", Array(repeating: reference, count: 3).joined(separator: " ")),
         ("jfk-quiet", "JFK • reduced amplitude", reference)].compactMap { key, name, transcript in
            guard let url = bundle.url(forResource: key, withExtension: "wav") else { return nil }
            return AudioSample(id: key, name: name, url: url, reference: transcript,
                               source: "Whisper test fixture / JFK speech")
        }
    }
}

actor AudioImporter {
    func importFile(_ source: URL) throws -> AudioSample {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }
        let attributes = try source.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard attributes.isRegularFile == true, let bytes = attributes.fileSize, bytes <= 100_000_000 else {
            throw BenchmarkError.invalidAudio("Choose a regular audio file up to 100 MB.")
        }
        let file = try AVAudioFile(forReading: source)
        try Self.validate(file)
        let root = URL.documentsDirectory.appending(path: "ImportedAudio", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let id = UUID().uuidString
        let target = root.appending(path: id).appendingPathExtension(source.pathExtension)
        try FileManager.default.copyItem(at: source, to: target)
        return AudioSample(id: id, name: source.deletingPathExtension().lastPathComponent,
                           url: target, reference: nil, source: "Local import")
    }
    nonisolated static func validate(_ file: AVAudioFile) throws {
        let format = file.processingFormat
        guard format.sampleRate.isFinite, (8000...192000).contains(format.sampleRate),
              (1...2).contains(format.channelCount), file.length > 0,
              Double(file.length) / format.sampleRate <= 180 else {
            throw BenchmarkError.invalidAudio("Use mono/stereo audio, 8–192 kHz, up to 180 seconds.")
        }
    }
}
