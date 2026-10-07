import Foundation
import AVFoundation
import CryptoKit

actor AudioNormalizer {
    private var cleaned = false
    private let cacheRoot = URL.cachesDirectory.appending(path: "BenchmarkPCM", directoryHint: .isDirectory)
        .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    nonisolated static func clearStaleCacheAtLaunch() {
        try? FileManager.default.removeItem(at: URL.cachesDirectory.appending(path: "BenchmarkPCM", directoryHint: .isDirectory))
    }
    deinit { try? FileManager.default.removeItem(at: cacheRoot) }
    private var cache: [String: PreparedAudio] = [:]
    func prepare(_ sample: AudioSample, sampleRate: Double) throws -> PreparedAudio {
        guard sampleRate.isFinite, sampleRate > 0 else { throw BenchmarkError.invalidAudio("Invalid target rate.") }
        if !cleaned {
            try FileManager.default.createDirectory(at: cacheRoot, withIntermediateDirectories: true)
            cleaned = true
        }
        let hash = try fingerprint(sample.url)
        let key = "\(hash)-\(sampleRate)"
        if let cached = cache[key], FileManager.default.fileExists(atPath: cached.url.path) { return cached }
        let input: AVAudioFile
        do { input = try AVAudioFile(forReading: sample.url) }
        catch { throw BenchmarkError.invalidAudio("Cannot open source: \(error)") }
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
        let output: AVAudioFile
        do { output = try AVAudioFile(forWriting: url, settings: target.settings) }
        catch { throw BenchmarkError.invalidAudio("Cannot create normalized file: \(error)") }
        let conversionInput = ConverterInput(file: input, buffer: inputBuffer)
        while true {
            try Task.checkCancellation()
            var conversionError: NSError?
            let status = converter.convert(to: outputBuffer, error: &conversionError) { requested, state in
                conversionInput.read(requested: requested, state: state)
            }
            if let error = conversionInput.error { throw BenchmarkError.invalidAudio("Cannot read PCM: \(error)") }
            if let conversionError { throw BenchmarkError.invalidAudio("Converter failed: \(conversionError)") }
            if outputBuffer.frameLength > 0 {
                do { try output.write(from: outputBuffer) }
                catch { throw BenchmarkError.invalidAudio("Cannot write PCM: \(error)") }
            }
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

// AVAudioConverter invokes its input callback synchronously during convert(). This
// owner is private to that call; its PCM buffer is never shared with another task.
nonisolated private final class ConverterInput: @unchecked Sendable {
    let file: AVAudioFile
    let buffer: AVAudioPCMBuffer
    var error: Error?
    init(file: AVAudioFile, buffer: AVAudioPCMBuffer) { self.file = file; self.buffer = buffer }
    func read(requested: AVAudioPacketCount, state: UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioBuffer? {
        guard file.framePosition < file.length else {
            state.pointee = .endOfStream
            return nil
        }
        guard requested > 0 else {
            state.pointee = .noDataNow
            return nil
        }
        do {
            let remaining = AVAudioFrameCount(min(Int64(buffer.frameCapacity), file.length - file.framePosition))
            try file.read(into: buffer, frameCount: min(requested, remaining))
            state.pointee = buffer.frameLength == 0 ? .endOfStream : .haveData
            return buffer.frameLength == 0 ? nil : buffer
        } catch {
            self.error = error
            state.pointee = .endOfStream
            return nil
        }
    }
}
