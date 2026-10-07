import SwiftUI

struct ModelMetadataView: View {
    let metadata: ModelMetadata
    var body: some View {
        LabeledContent("Model", value: metadata.name)
        LabeledContent("Version", value: metadata.version ?? "Not available")
        LabeledContent("Model size", value: metadata.sizeBytes.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .memory) } ?? "Not available")
        LabeledContent("Language", value: metadata.language)
        LabeledContent("Input", value: metadata.inputFormat)
        LabeledContent("Backend", value: metadata.backend)
        LabeledContent("Compute configuration", value: metadata.computeConfiguration)
    }
}
