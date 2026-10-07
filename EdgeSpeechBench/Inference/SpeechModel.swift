import Foundation

nonisolated protocol SpeechModel: Actor {
    func requiredSampleRate() async throws -> Double
    func load() async throws
    func initialize(audio: PreparedAudio) async throws
    func transcribe(audio: PreparedAudio) async throws -> InferenceResult
    func unload() async
    func metadata() async -> ModelMetadata
}

nonisolated enum ModelChoice: String, CaseIterable, Identifiable, Sendable {
    case standard, alternatives
    var id: String { rawValue }
    var title: String {
        switch self {
        case .standard: "Apple Speech • transcription"
        case .alternatives: "Apple Speech • alternatives"
        }
    }
    func makeProvider() -> AppleSpeechModel { AppleSpeechModel(alternatives: self == .alternatives) }
}
