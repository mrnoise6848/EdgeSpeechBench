import SwiftUI

struct PrivacyView: View {
    var body: some View {
        List {
            Section("Local processing") {
                Text("Audio and speech recognition stay on this device. No account or analytics is used.")
                Text("Installing English model assets may download files from Apple. Downloads are separate from benchmarking.")
            }
            Section("Stored data") {
                Text("History stores measurements, input fingerprints, model configuration and anonymous device/OS context. Audio and transcripts are not in result records.")
                Text("Imported audio remains in the app sandbox until the app is removed. Deleting a result deletes its metadata only.")
            }
            Section("Export") { Text("JSON, CSV and text exports contain benchmark metadata only. You choose the destination in Files.") }
        }.navigationTitle("Privacy")
    }
}
