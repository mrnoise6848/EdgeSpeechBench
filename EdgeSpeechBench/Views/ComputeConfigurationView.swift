import SwiftUI

struct ComputeConfigurationView: View {
    let model: ModelMetadata
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent("Compute configuration", value: model.computeConfiguration)
            Text("SpeechAnalyzer manages hardware placement. Exact CPU, GPU and Neural Engine execution is not exposed.")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}
