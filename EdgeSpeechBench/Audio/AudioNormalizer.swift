import Foundation
import AVFoundation
import CryptoKit

actor AudioNormalizer {
    private var cleaned = false
    private let cacheRoot = URL.cachesDirectory.appending(path: "BenchmarkPCM", directoryHint: .isDirectory)
    private var cache: [String: PreparedAudio] = [:]
    func prepare(_ sample: AudioSample, sampleRate: Double) throws -> PreparedAudio {
        guard sampleRate.isFinite, sampleRate > 0 else { throw BenchmarkError.invalidAudio("Invalid target rate.") }
        if !cleaned {
            try? FileManager.default.removeItem(at: cacheRoot)
            try FileManager.default.createDirectory(at: cacheRoot, withIntermediateDirectories: true)
            cleaned = true
        }
        let hash = try fingerprint(sample.url)
        let key = "\(hash)-\(sampleRate)"
        if let cached = cache[key], FileManager.default.fileExists(atPath: cached.url.path) { return cached }
        let input = try AVAudioFile(forReading: sample.url)
        try AudioImporter.validate(input)
        guard let target = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate,
                                        channels: 1, interleaved: false),
              let converter = AVAudioConverter(from: input.processingFormat, to: target),
              let inputBuffer = AVAudioPCMBuffer(pcmFormat: input.processingFormat, frameCapacity: 4096),
              let outputBuffer = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: 8192) else {
            throw BenchmarkError.invalidAudio("Audio converter could not be created.")
        }
        let url = cacheRoot.appending(path: "normalized-\(UUID().uuidString).caf")
        var completed = false
        defer { if !completed { try? FileManager.default.removeItem(at: url) } }
        let output = try AVAudioFile(forWriting: url, settings: target.settings)
        var readError: Error?
        while true {
            try Task.checkCancellation()
            var conversionError: NSError?
            let status = converter.convert(to: outputBuffer, error: &conversionError) { _, state in
                do {
                    try input.read(into: inputBuffer)
                    state.pointee = inputBuffer.frameLength == 0 ? .endOfStream : .haveData
                    return inputBuffer.frameLength == 0 ? nil : inputBuffer
                } catch {
                    readError = error
                    state.pointee = .endOfStream
                    return nil
                }
            }
            if let readError { throw readError }
            if let conversionError { throw conversionError }
            if outputBuffer.frameLength > 0 { try output.write(from: outputBuffer) }
            if status == .endOfStream { break }
            if status == .error { throw BenchmarkError.invalidAudio("PCM conversion failed.") }
        }
        guard output.length > 0 else { throw BenchmarkError.invalidAudio("No decoded frames.") }
        let prepared = PreparedAudio(url: url, duration: Double(output.length) / sampleRate,
                                     sampleRate: sampleRate, channels: 1, fingerprint: hash)
        if cache.count >= 4, let old = cache.keys.sorted().first, let value = cache.removeValue(forKey: old) {
            try? FileManager.default.removeItem(at: value.url)
        }
        cache[key] = prepared
        completed = true
        return prepared
    }
    private func fingerprint(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hash = SHA256()
        while let data = try handle.read(upToCount: 65536), !data.isEmpty {
            try Task.checkCancellation()
            hash.update(data: data)
        }
        return hash.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
