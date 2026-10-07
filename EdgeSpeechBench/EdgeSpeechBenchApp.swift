import SwiftUI
import SwiftData

@main
struct EdgeSpeechBenchApp: App {
    private let container: Result<ModelContainer, Error>
    init() {
        container = Result {
            let schema = Schema([Item.self, BenchmarkRunRecord.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false,
                                                   cloudKitDatabase: .none)
            return try ModelContainer(for: schema, configurations: [configuration])
        }
    }
    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let store):
                ContentView().modelContainer(store)
            case .failure(let error):
                ContentUnavailableView("Local storage unavailable", systemImage: "externaldrive.badge.exclamationmark",
                                       description: Text(error.localizedDescription))
            }
        }
    }
}
